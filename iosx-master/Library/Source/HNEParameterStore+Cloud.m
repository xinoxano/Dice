//
//  HoneParameterStore+Cloud.m
//  HoneExample
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import "HNEParameterStore+Cloud.h"
#import "HNEParameterStore+Private.h"
#import "HNE.h"
#import "HNEError.h"
#import "HNE+Private.h"
#import <HNEYACYAML/HNEYACYAML.h>



@implementation HNEParameterStore (Cloud)

- (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL success, BOOL valuesChanged, NSError *error))completionBlock
{
	void (^completer)(BOOL success, BOOL cbValuesChanged, NSError *error) = ^void(BOOL cbSuccess, BOOL cbValuesChanged, NSError *cbError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (completionBlock) { completionBlock(cbSuccess, cbValuesChanged, cbError); }
		});
	};
    
    if (self.hone.status == HNELibraryStatusProductionMode) {
        completer(NO, NO, [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeOperationNotAllowedInProductionMode userInfo:nil]);
        return;
    }
	
	// assume that we have a valid app ID and are in development mode by this point.
	// step 1 - fetch manifest
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://hone.tools/v1/projects/%@/manifest", self.hone.appId]]];
	req.HTTPMethod = @"GET";
	
	NSURL *manifestEtagUrl = [[self cloudDocumentFolder] URLByAppendingPathComponent:@"manifest.yaml.etag"];
	NSError *stringError = nil;
	NSString *manifestEtag = [NSString stringWithContentsOfURL:manifestEtagUrl encoding:NSUTF8StringEncoding error:&stringError];
	
	if (manifestEtag) {
		[req addValue:manifestEtag forHTTPHeaderField:@"If-None-Match"];
	}
	
	[[self.cloudServiceSession dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
	{
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		
		if (httpResponse.statusCode == 200) {
			
			NSDictionary *manifestDictionary = [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:data];
			
			if ([manifestDictionary[@"format"] isEqualToNumber:@(1)]) {
				
				NSURL *documentFolder = [self cloudDocumentFolder];
				
				// Correct format version. Write to disk and attempt to download resources.

				[data writeToURL:[[self cloudDocumentFolder] URLByAppendingPathComponent:@"manifest.yaml"] atomically:YES];
				
				NSString *eTag = [httpResponse allHeaderFields][@"Etag"];
				if (eTag) {
					[eTag writeToURL:[documentFolder URLByAppendingPathComponent:@"manifest.yaml.etag"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
				}
				
				__block NSInteger pendingDownloads = 0;
				
				for (NSString *themeKey in [manifestDictionary[@"resources"] allKeys]) {
					
					NSDictionary *themeDict = manifestDictionary[@"resources"][themeKey];
					
					NSFileManager *fm = [NSFileManager defaultManager];
					
					NSURL *themeFolder = [documentFolder URLByAppendingPathComponent:themeKey];
					
					[fm createDirectoryAtURL:themeFolder withIntermediateDirectories:NO attributes:nil error:nil];
					
					for (NSString *resourceKey in [themeDict allKeys]) {
						
						NSString *resourceChecksum = themeDict[resourceKey];
						
						NSData *resourceChecksumData = [NSData dataWithContentsOfURL:[themeFolder URLByAppendingPathComponent:[resourceKey stringByAppendingString:@".etag"]]];
						
						NSString *storedResourceChecksum = [[NSString alloc] initWithData:resourceChecksumData encoding:NSUTF8StringEncoding];
						
						if ([resourceChecksum isEqualToString:storedResourceChecksum]) {
							// We have the correct version of this resource stored. Do nothing.
						} else {
							
							// Either we don’t have the resource, or we have an old version. So, download a new one.
							// Note we are not passing etag because already have done validation
							// by this point and determined that we don’t have the resource version
							// contained in the manifest, so we probably need it.
							
							pendingDownloads++;
							
                            NSURL *downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://hone.tools/v1/projects/%@/resources/%@/%@", self.hone.appId, [themeKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], resourceKey]];
							NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:downloadURL];
							req.HTTPMethod = @"GET";
							
							[[self.cloudServiceSession dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
							
								NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
								
								if (httpResponse.statusCode == 200) {
									
									[data writeToURL:[themeFolder URLByAppendingPathComponent:resourceKey] atomically:YES];
									
									NSString *resourceETag = [httpResponse allHeaderFields][@"Etag"];
									if (resourceETag) {
										[resourceETag writeToURL:[themeFolder URLByAppendingPathComponent:[resourceKey stringByAppendingString:@".etag"]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
									}

									
								} else {
									// Error downloading an individual resource. Maybe should report this.
								}
								
								pendingDownloads--;
								if (!pendingDownloads) {
									// This was the last download that was completed. Apply the values, and then call the success callback.
									
									[self runBlockThatAffectsValues:^{
										[self loadHoneDocumentAtURL:documentFolder forStoreLevel:HNEParameterStoreLevelCloud error:nil];
									}];
									
									completer(YES, YES, nil);
								}
							
							}] resume];
							
						}
						
					}
					
				}
								
				if (!pendingDownloads) {
					// Didn’t have to do any downloads, already have all the resources. Call the success callback.
					completer(YES, NO, nil);
				}

				
			} else {
				
				NSError *e = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidDocumentFormatVersion userInfo:nil];
				completer(NO, NO, e);
				
			}
			
			
		} else if (httpResponse.statusCode == 304) {
			// manifest not modified, nothing to do
			
			completer(YES, NO, nil);
		} else {
			
			// Some HTTP error. Tell the caller about that.
			
			NSError *e = error;
			
			if (!e) { e = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeCloudNetworkError userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"HTTP error %ld when refreshing manifest from cloud", (long)httpResponse.statusCode]}]; }
			
			completer(NO, NO, e);
		}
		
	}] resume];
	
}

- (NSURL *)cloudDocumentFolder
{
	NSString *appId = self.hone.appId;
	if (!appId) { return nil; }
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *cacheFolder = [fm URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
	
	NSURL *honeFolder = [cacheFolder URLByAppendingPathComponent:@"tools.hone.cloudCache"];
	NSURL *documentFolder = [honeFolder URLByAppendingPathComponent:appId];
	
	[fm createDirectoryAtURL:documentFolder withIntermediateDirectories:YES attributes:nil error:nil];
	
	return documentFolder;
}



#pragma mark - NSURLSessionDelegate
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//#warning only activate this method for testing with charlesproxy etc
//    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
//}

@end
