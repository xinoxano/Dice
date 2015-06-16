//
//  Hone.h
//  HoneExample
//
//  Created by Jaanus Kase on 18.12.13.
//
//

#import <Foundation/Foundation.h>
#import "HNE.h"
#import "HNEShared.h"
#import "HNEType.h"



@class HNEDeviceServer, HNEParameterStore, HNERegisteredWatcher;



FOUNDATION_EXPORT NSString *const IDENTIFIER_CLASS_NAME;
FOUNDATION_EXPORT NSString *const IDENTIFIER_PARAMETER_NAME;



@interface HNE ()

@property (strong, nonatomic) HNEDeviceServer *server;

/// Callbacks (HoneRegisteredCallback) that the app has registered through its lifecycle.
@property (strong, nonatomic) NSMapTable *registeredCallbacks;

/// HNERegisteredWatcher watchers that the app has registered through its lifecycle.
@property (strong, nonatomic) NSMapTable *registeredWatchers;

/// Parameter value change watchers

@property (strong, nonatomic) HNEParameterStore *parameterStore;

/// Mappings between objects and GUIDs.
@property (strong, nonatomic) NSMapTable *guidToObject;
@property (strong, nonatomic) NSMapTable *objectToGuid;

- (void)registerParameter:(NSString *)identifier
			  forDataType:(HNEType)dataType
			 defaultValue:(id)defaultValue
				 observer:(id)observer
				  options:(NSDictionary *)options
  blockIsSimpleAssignment:(BOOL)blockIsSimpleAssignment
					block:(void (^)(id obj, id value))block;

- (void)registerGuidForObject:(id)observer;

- (void)registerWatcher:(HNERegisteredWatcher *)watcher;

- (id)objectNativeValueForHoneIdentifier:(NSString *)identifier;

/// Unique device identifier for Hone in the context of this device and app. Lets us correlate different app running session in the Hone desktop tool.
@property (strong, nonatomic) NSUUID *deviceUuid;

/// Talk back to the desktop app who is listening at this url
@property (copy, nonatomic) NSString *deviceTalkbackUrl;

@property (copy, nonatomic) NSString *appId;
@property (copy, nonatomic) NSString *appToken;

#if TARGET_OS_IPHONE
/// View controller of the owning application, that will modally present the Hone UI.
@property (weak, nonatomic) UIViewController *iosDevUiViewController;
#endif



#pragma mark - Private instance methods

- (BOOL)startWithAppIdentifier:(NSString *)appIdentifier
                     appSecret:(NSString *)appSecret
                   documentURL:(NSURL *)documentURL
               developmentMode:(BOOL)developmentMode
                         error:(out NSError **)error;

- (void)watchIdentifiers:(NSArray *)identifiers object:(id)observer block:(void (^)(id, NSArray *))block;
- (void)bindNSIntegerIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
- (void)bindNSStringIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
- (void)bindNSIntegerIdentifier:(NSString *)identifier
					  defaultValue:(NSInteger)defaultValue
						 object:(id)observer
							 block:(void (^)(id observer, NSInteger value))block;
- (void)bindNSStringIdentifier:(NSString *)identifier
                   defaultValue:(NSString *)defaultValue
                         object:(id)observer
                          block:(void (^)(id observer, NSString *value))block;

- (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier;
- (NSString *)NSStringWithHoneIdentifier:(NSString *)identifier;
- (void)activateThemes:(NSArray *)themes;

- (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL success, BOOL valuesChanged, NSError *error))completionBlock;

- (void)startServer;
- (void)stopServer;

@end



@interface NSString (HNEPrivateExtensions)

/// Parse a Hone keypath-like identifier into
- (NSDictionary *)parsedIdentifier;

@end
