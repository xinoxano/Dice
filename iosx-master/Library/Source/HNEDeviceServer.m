//
//  HNEDeviceServer.m
//  Hone
//
//  Created by Jaanus Kase on 16.05.14.
//
//

#import "HNEDeviceServer.h"

// model
#import "HNE+Private.h"
#import "HNEDocumentParameter.h"
#import "HNERegisteredCallback.h"
#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEDocumentObject.h"

// helpers
#import "GCDWebServer.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerDataResponse.h"
#import "GCDWebServerErrorResponse.h"
#import "HNEShared.h"


#if !TARGET_OS_IPHONE

@interface NSWindow (JKScreenShot)

- (NSData *)pngScreenshotData;

@end

@implementation NSWindow (JKScreenshot)

- (NSData *)pngScreenshotData
{
	// This can be kCGWindowImageBoundsIgnoreFraming if you don’t want to include ornamentation like the shadow
	CGWindowImageOption imageOptions = kCGWindowImageDefault;
	
	CGWindowID windowID = (CGWindowID)[self windowNumber];
	CGWindowListOption singleWindowListOptions = kCGWindowListOptionIncludingWindow;
	CGRect imageBounds = CGRectNull;
	CGImageRef windowImage = CGWindowListCreateImage(imageBounds, singleWindowListOptions, windowID, imageOptions);
	NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
	NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:nil];
	CFRelease(windowImage);
	return pngData;
}

@end

#endif




@interface HNEDeviceServer () {
	GCDWebServer *gcdWebServer;
}

@property (weak, nonatomic) HNE *hone;

@end



@implementation HNEDeviceServer

- (instancetype)initWithHone:(HNE *)hone
{
	if (self = [super init]) {
		_hone = hone;
		gcdWebServer = [[GCDWebServer alloc] init];
		[GCDWebServer setLogLevel:kGCDWebServerLogLevel_Exception];
	}
	return self;
}

- (void)startServer
{
	if (gcdWebServer.running) { return; }
	
	__weak HNEDeviceServer *weakSelf = self;
	
	// Default response
	[gcdWebServer addDefaultHandlerForMethod:@"GET"
								requestClass:[GCDWebServerRequest class]
								processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	 {
		 return [GCDWebServerErrorResponse responseWithClientError:kGCDWebServerHTTPStatusCode_BadRequest message:@"Nothing here."];
	 }];
	
	// device info
	[gcdWebServer addHandlerForMethod:@"GET"
								 path:@"/v1/device_info"
						 requestClass:[GCDWebServerDataRequest class]
						 processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	{
		return [weakSelf v1DeviceInfoResponseForRequest:(GCDWebServerDataRequest *)request withTalkback:NO];
	}];
	
	// device info with talkback
	[gcdWebServer addHandlerForMethod:@"PUT"
								 path:@"/v1/device_session_start"
						 requestClass:[GCDWebServerDataRequest class]
						 processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	 {
		 return [weakSelf v1DeviceInfoResponseForRequest:(GCDWebServerDataRequest *)request withTalkback:YES];
	 }];
	
	// object list
	[gcdWebServer addHandlerForMethod:@"GET"
								 path:@"/v1/objects"
						 requestClass:[GCDWebServerRequest class]
						 processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	{
		return [weakSelf v1ObjectsResponseForRequest:request];
	}];
	
	// app png representation
	[gcdWebServer addHandlerForMethod:@"GET"
								 path:@"/v1/png_representation"
						 requestClass:[GCDWebServerRequest class]
						 processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	{
		return [weakSelf v1AppPngRepresentation];
	}];
    
    // fonts representation
    [gcdWebServer addHandlerForMethod:@"GET"
                                 path:@"/v1/fonts"
                         requestClass:[GCDWebServerRequest class]
                         processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
     {
         return [weakSelf v1DeviceFonts];
     }];
	
	// put parameter value
	[gcdWebServer addHandlerForMethod:@"PUT"
							pathRegex:@"/v1/objects/.+/parameters(/.+)?"
						 requestClass:[GCDWebServerDataRequest class]
						 processBlock:^GCDWebServerResponse *(GCDWebServerRequest *request)
	{
		return [weakSelf v1PutObjectParametersForRequest:(GCDWebServerDataRequest *)request];
	}];
	
	NSError *serverStartError = nil;
	
	[gcdWebServer startWithOptions:@{
									 GCDWebServerOption_Port: @(0),
									 GCDWebServerOption_BonjourType: @"_hone._tcp",
									 GCDWebServerOption_BonjourName: @""
									 } error:&serverStartError];
	if (serverStartError) {
		NSLog(@"Error starting Hone HTTP server: %@", serverStartError);
	}

}

- (void)stopServer
{
	[gcdWebServer stop];
}


#pragma mark - Web request handlers

- (GCDWebServerResponse *)v1DeviceInfoResponseForRequest:(GCDWebServerDataRequest *)request withTalkback:(BOOL)withTalkback
{
	if (withTalkback) {
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.data options:0 error:nil];
		self.hone.deviceTalkbackUrl = json[@"device_talkback_url"];
	}
	
#if TARGET_OS_IPHONE
	NSString *deviceName = [UIDevice currentDevice].name;
    NSString *projectName = [NSBundle mainBundle].bundleIdentifier;
#else
	NSProcessInfo *process = [NSProcessInfo processInfo];
	NSString *deviceName = [process hostName];
    NSString *projectName = [process processName];
#endif
	
	NSDictionary *deviceInfo =
  @{
	@"device_name": deviceName,
	@"device_guid": self.hone.deviceUuid.UUIDString,
	@"project_id": self.hone.appId,
    @"project_name": projectName
	};
	
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:0 error:nil];
	return [GCDWebServerDataResponse responseWithData:jsonData contentType:@"application/json"];
}

- (GCDWebServerResponse *)v1ObjectsResponseForRequest:(GCDWebServerRequest *)request
{
	NSMutableArray *objectDicts = [NSMutableArray array];
	for (HNEDocumentObject *o in self.hone.parameterStore.mergedDocumentObjects) {
		[objectDicts addObject:[o dictionaryRepresentation]];
	}
	
	NSError *jsonError = nil;
	NSData *objectData = [NSJSONSerialization dataWithJSONObject:objectDicts options:NSJSONWritingPrettyPrinted error:&jsonError];
	if (!jsonError) {
		return [GCDWebServerDataResponse responseWithData:objectData contentType:@"application/json"];
	} else {
		return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError
												  underlyingError:jsonError
														  message:@"Error encoding application objects"];
	}
}

- (GCDWebServerResponse *)v1AppPngRepresentation
{
#if TARGET_OS_IPHONE
	__block UIImage *i;
	dispatch_sync(dispatch_get_main_queue(), ^{
		
		UIWindow *window = [UIApplication sharedApplication].keyWindow;
		
		UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, window.screen.scale);
		[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
		
		i = UIGraphicsGetImageFromCurrentImageContext();
		
		UIGraphicsEndImageContext();
	});
	
	NSData *png = UIImagePNGRepresentation(i);
#else
	
	// Use a heuristic: grab the biggest window
	
	__block NSData *png = nil;
	dispatch_sync(dispatch_get_main_queue(), ^{
		CGFloat maxWindowArea = 0;
		for (NSWindow *window in [NSApp windows]) {
			CGFloat area = window.frame.size.width * window.frame.size.height;
			if (window.isVisible && (area > maxWindowArea)) {
				maxWindowArea = area;
					png = window.pngScreenshotData;
			}
		}
	});
	
#endif

	if (png) {
		return [GCDWebServerDataResponse responseWithData:png contentType:@"image/png"];
	}
	
	return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError message:@"Could not generate PNG representation for app"];
}

- (GCDWebServerResponse *)v1PutObjectParametersForRequest:(GCDWebServerDataRequest *)request
{
	// Received new parameters for a class.
	// 1. store new parameters
	// 2. run all callbacks
	// 3. run general observers for the affected class
	
//	NSLog(@"Processing parameter put request, request content length is %llu, received %llu", requestContentLength, requestContentLengthReceived);
	NSError *jsonError = nil;
	NSArray *a = [NSJSONSerialization JSONObjectWithData:request.data options:0 error:&jsonError];
	if (jsonError) {
		NSLog(@"error processing json: %@", jsonError);
		return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError
												  underlyingError:jsonError
														  message:@"Error parsing parameters"];
		
	}
	
	NSString *path = request.path;

	// store new parameter values in the bonjour store
	
	static NSRegularExpression *parameterMatcher;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSError *regexError = nil;
		parameterMatcher = [NSRegularExpression regularExpressionWithPattern:@"/v1/objects/(.+)/parameters(/(.+))?" options:0 error:&regexError];
		if (regexError) { NSLog(@"Error constructing parameter regex matcher: %@", regexError); }
	});
	
	NSString *themeName = nil;
	NSArray *matches = [parameterMatcher matchesInString:path options:0 range:NSMakeRange(0, path.length)];
	NSTextCheckingResult *match = matches[0];
	NSString *className = [path substringWithRange:[match rangeAtIndex:1]];
	if (match.numberOfRanges > 3) {
		NSRange themeRange = [match rangeAtIndex:3];
		if (themeRange.location != NSNotFound) {
			themeName = [path substringWithRange:themeRange];
		}
	}
		
	for (NSDictionary *dict in a) {
		HNEDocumentParameter *parameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:dict];
		
		NSError *parameterError = nil;
		if ([HNEDocumentParameter isValueValid:parameter.value forDataType:parameter.dataType error:&parameterError]) {
			[self.hone.parameterStore setParameter:parameter inClass:className theme:themeName storeLevel:HNEParameterStoreLevelBonjour];
		} else {
			[self.hone.parameterStore talkbackParameterValueWithParameter:parameter class:className theme:themeName error:@"Trying to set an invalid parameter value."];
		}
	}
	
	if (a.count) {
		[[NSNotificationCenter defaultCenter] postNotificationName:HNEDidReceiveValuesFromLocalNetworkNotification object:self];
	}
	
	return [GCDWebServerResponse responseWithStatusCode:200];
}

- (GCDWebServerResponse *)v1DeviceFonts
{
    NSMutableArray *fonts = [NSMutableArray array];
    
#if (TARGET_OS_IPHONE)
    
    NSArray *fontFamilies = [UIFont familyNames];
    for (NSString *family in fontFamilies) {
        NSArray *familyMembers = [UIFont fontNamesForFamilyName:family];
        [fonts addObject:@{ family: familyMembers }];
    }
    
#else
    NSArray *fontFamilies = [[NSFontManager sharedFontManager] availableFontFamilies];
    for (NSString *family in fontFamilies) {
        NSArray *familyMembers = [[NSFontManager sharedFontManager] availableMembersOfFontFamily:family];
        
        NSMutableArray *familyMemberNames = [NSMutableArray array];
        for (NSArray *familyMember in familyMembers) {
            [familyMemberNames addObject:familyMember[0]];
        }
        [fonts addObject:@{ family: familyMemberNames }];
    }
    
#endif
    
    // TODO: OSX
    
    NSError *jsonError = nil;
    NSData *fontData = [NSJSONSerialization dataWithJSONObject:fonts options:0 error:&jsonError];
    if (!jsonError) {
        return [GCDWebServerDataResponse responseWithData:fontData contentType:@"application/json"];
    }
    
    return [GCDWebServerErrorResponse responseWithServerError:kGCDWebServerHTTPStatusCode_InternalServerError
                                              underlyingError:jsonError
                                                      message:@"Error retrieving device fonts"];
}



@end
