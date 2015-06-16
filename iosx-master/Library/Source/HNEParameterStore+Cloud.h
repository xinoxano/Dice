//
//  HoneParameterStore+Cloud.h
//  HoneExample
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import "HNEParameterStore.h"

@interface HNEParameterStore (Cloud) <NSURLSessionDelegate>

- (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL success, BOOL valuesChanged, NSError *error))completionBlock;

- (NSURL *)cloudDocumentFolder;

@end
