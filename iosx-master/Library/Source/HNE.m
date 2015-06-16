//
//  Hone.m
//  HoneExample
//
//  Created by Jaanus Kase on 18.12.13.
//
//

#import "HNE.h"
#import "HNE+Private.h"
#import "HNERegisteredCallback.h"
#import "HNERegisteredWatcher.h"
#import "HNEShared.h"
#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEParameterStore+Cloud.h"
#import "HNEDocumentParameter.h"
#import "HNEDocumentParameter+Private.h"
#import "HNEDeviceServer.h"
#import "HNEError.h"
#import "HNEFont+HNETypography.h"



NSString *const IDENTIFIER_CLASS_NAME = @"Class";
NSString *const IDENTIFIER_PARAMETER_NAME = @"Parameter";



@implementation HNE

#pragma mark - Singleton, object lifecycle

+ (instancetype)sharedHone {
	static HNE *singleton;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		singleton = [[self alloc] init];
	});
	return singleton;
}

- (id)init
{
	if (self = [super init]) {
        _status = HNELibraryStatusNotStarted;
		self.registeredCallbacks = [NSMapTable weakToStrongObjectsMapTable];
		self.registeredWatchers = [NSMapTable weakToStrongObjectsMapTable];
		self.objectToGuid = [NSMapTable weakToStrongObjectsMapTable];
		self.guidToObject = [NSMapTable strongToWeakObjectsMapTable];
		
		self.parameterStore = [[HNEParameterStore alloc] initWithHone:self];
		
		NSString *deviceUuidKey = @"tools.hone.deviceUuid";
		
		NSString *uuidString = [[NSUserDefaults standardUserDefaults] objectForKey:deviceUuidKey];
		if (!uuidString) {
			self.deviceUuid = [NSUUID UUID];
			[[NSUserDefaults standardUserDefaults] setObject:self.deviceUuid.UUIDString forKey:deviceUuidKey];
		} else {
			self.deviceUuid = [[NSUUID alloc] initWithUUIDString:uuidString];
		}
	}
	return self;
}


#pragma mark - Public API - starting

+ (BOOL)startWithAppIdentifier:(NSString *)appIdentifier
                     appSecret:(NSString *)appSecret
                   documentURL:(NSURL *)documentURL
               developmentMode:(BOOL)developmentMode
                         error:(out NSError *__autoreleasing *)error
{
    return [[self sharedHone] startWithAppIdentifier:appIdentifier
                              appSecret:appSecret
                            documentURL:documentURL
                        developmentMode:developmentMode
                                  error:error];
}

- (BOOL)startWithAppIdentifier:(NSString *)appIdentifier
					 appSecret:(NSString *)appSecret
				   documentURL:(NSURL *)documentURL
			   developmentMode:(BOOL)developmentMode
						 error:(out NSError *__autoreleasing *)error
{
    
    if (_status != HNELibraryStatusNotStarted) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidStartRequest userInfo:nil];
        }
        return NO;
    }
    
    if (developmentMode) {
        _status = HNELibraryStatusDevelopmentMode;
    } else {
        _status = HNELibraryStatusProductionMode;
    }
	
	if (!appIdentifier) {
		if (error != NULL) {
			*error = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidStartParameters userInfo:nil];
		}
		return NO;
	}
	
	self.appId = appIdentifier;
	self.appToken = appSecret;
	
	HNEParameterStore *parameterStore = self.parameterStore;
	
	if (developmentMode) {
		
		// App secret is required in development mode for cloud communication
		if (!appSecret) {
			if (error != NULL) {
				*error = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidStartParameters userInfo:nil];
			}
			return NO;
		}

        [self startServer];
		
		NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
		
		if (appSecret) {
			urlSessionConfiguration.HTTPAdditionalHeaders = @{@"Authorization": [@"Bearer " stringByAppendingString:appSecret]};
		}
		
		urlSessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		
		parameterStore.cloudServiceSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:parameterStore delegateQueue:nil];
		
		// Try to load the cloud store. Maybe its there, maybe not.
		NSURL *cloudDocumentFolder = parameterStore.cloudDocumentFolder;
		if (cloudDocumentFolder) {
			[parameterStore loadHoneDocumentAtURL:cloudDocumentFolder forStoreLevel:HNEParameterStoreLevelCloud error:nil];
		}
	}
				
	if (documentURL) {
		return [self.parameterStore loadHoneDocumentAtURL:documentURL forStoreLevel:HNEParameterStoreLevelDocument error:error];
	}
	
	return YES;
}


#pragma mark - Public API - register with options

+ (void)bindCGFloatIdentifier:(NSString *)identifier
					defaultValue:(CGFloat)defaultValue
						object:(id)observer
						   block:(void (^)(id observer, CGFloat value))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeFloat
					  defaultValue:[NSNumber numberWithFloat:defaultValue]
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

+ (void)bindNSIntegerIdentifier:(NSString *)identifier
					  defaultValue:(NSInteger)defaultValue
						  object:(id)observer
							 block:(void (^)(id observer, NSInteger value))block
{
	[[self sharedHone] bindNSIntegerIdentifier:identifier
							defaultValue:defaultValue
								  object:observer block:block];
}

+ (void)bindBOOLIdentifier:(NSString *)identifier
					  defaultValue:(BOOL)defaultValue
						 object:(id)observer
							 block:(void (^)(id observer, BOOL value))block
{
	[[self sharedHone] bindBOOLIdentifier:identifier
							defaultValue:defaultValue
								  object:observer block:block];
}

+ (void)bindNSStringIdentifier:(NSString *)identifier
					  defaultValue:(NSString *)defaultValue
						  object:(id)observer
							 block:(void (^)(id observer, NSString *value))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeString
					  defaultValue:defaultValue
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}



#pragma mark - Public API - keypath registration

+ (void)bindCGFloatIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindCGFloatIdentifier:identifier defaultValue:[[object valueForKeyPath:keyPath] floatValue] object:object block:^(id observer, CGFloat value) {
		[observer setValue:@(value) forKeyPath:keyPath];
	}];
}

+ (void)bindNSIntegerIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[[self sharedHone] bindNSIntegerIdentifier:identifier object:object keyPath:keyPath];
}

+ (void)bindBOOLIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[[self sharedHone] bindBOOLIdentifier:identifier object:object keyPath:keyPath];
}

+ (void)bindNSStringIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
    [[self sharedHone] bindNSStringIdentifier:identifier object:object keyPath:keyPath];
}



#pragma mark - Public API - themes

+ (void)activateThemes:(NSArray *)themes
{
	[[HNE sharedHone] activateThemes:themes];
}



#pragma mark - Public API - update from cloud

+ (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL, BOOL, NSError *))completionBlock
{
	[[HNE sharedHone] updateFromCloudWithCompletionBlock:completionBlock];
}



#pragma mark - Public API - watch parameters

+ (void)watchIdentifiers:(NSArray *)identifiers object:(id)object block:(void (^)(id, NSArray *))block
{
	[[HNE sharedHone] watchIdentifiers:identifiers object:object block:block];
}



#pragma mark - Private API - instance methods

- (void)bindNSIntegerIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindNSIntegerIdentifier:identifier defaultValue:[[object valueForKeyPath:keyPath] integerValue] object:object block:^(id observer, NSInteger value) {
		[observer setValue:@(value) forKeyPath:keyPath];
	}];
}

- (void)bindNSStringIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
    [self bindNSStringIdentifier:identifier defaultValue:[object valueForKeyPath:keyPath] object:object block:^(id observer, NSString *value) {
        [observer setValue:value forKeyPath:keyPath];
    }];
}


- (void)bindNSIntegerIdentifier:(NSString *)identifier
					  defaultValue:(NSInteger)defaultValue
						 object:(id)observer
							 block:(void (^)(id observer, NSInteger value))block
{
	[self registerParameter:identifier
					   forDataType:HNETypeInt
					  defaultValue:[NSNumber numberWithInteger:defaultValue]
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

- (void)bindNSStringIdentifier:(NSString *)identifier
                  defaultValue:(NSString *)defaultValue
                        object:(id)observer
                         block:(void (^)(id observer, NSString *value))block
{
    [self registerParameter:identifier
                             forDataType:HNETypeString
                            defaultValue:defaultValue
                                observer:observer
                                 options:nil
                 blockIsSimpleAssignment:NO
                                   block:(void (^)(id obj, id value))block];
}

- (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier
{
	NSNumber *n = [self objectNativeValueForHoneIdentifier:identifier];
	return [n integerValue];
}

- (NSString *)NSStringWithHoneIdentifier:(NSString *)identifier
{
    NSString *s = [self objectNativeValueForHoneIdentifier:identifier];
    return s;
}

- (void)bindBOOLIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindBOOLIdentifier:identifier defaultValue:[[object valueForKeyPath:keyPath] boolValue] object:object block:^(id observer, BOOL value) {
		[observer setValue:@(value) forKeyPath:keyPath];
	}];
}


- (void)bindBOOLIdentifier:(NSString *)identifier
					  defaultValue:(BOOL)defaultValue
						 object:(id)observer
							 block:(void (^)(id observer, BOOL value))block
{
	[self registerParameter:identifier
				forDataType:HNETypeBool
			   defaultValue:[NSNumber numberWithBool:defaultValue]
				   observer:observer
					options:nil
	blockIsSimpleAssignment:NO
					  block:(void (^)(id obj, id value))block];
}

- (BOOL)BOOLWithHoneIdentifier:(NSString *)identifier
{
	NSNumber *n = [self objectNativeValueForHoneIdentifier:identifier];
	return [n boolValue];
}

- (void)activateThemes:(NSArray *)themes
{
	[self.parameterStore activateThemes:themes];
}

- (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL, BOOL, NSError *))completionBlock
{
    [self.parameterStore updateFromCloudWithCompletionBlock:completionBlock];
}



#pragma mark - Utilities

- (void)watchIdentifiers:(NSArray *)identifiers object:(id)observer block:(void (^)(id, NSArray *))block
{
	if (!block) {
		[NSException raise:NSInvalidArgumentException format:@"No callback block specified for Hone identifier watcher registration"];
		return;
	}
	
	HNERegisteredWatcher *watcher = [[HNERegisteredWatcher alloc] init];
	watcher.watchedIdentifiers = identifiers;
	watcher.watcherCallbackBlock = block;
	watcher.observer = observer;
	
    dispatch_async(self.parameterStore.parameterStoreModifierQueue, ^{
        [self registerWatcher:watcher];
    });
}

- (void)registerWatcher:(HNERegisteredWatcher *)watcher
{
    NSMutableSet *currentWatchers = [self.registeredWatchers objectForKey:watcher.observer];
    if (!currentWatchers) { currentWatchers = [NSMutableSet set]; }
    [currentWatchers addObject:watcher];
    
    [self.registeredWatchers setObject:currentWatchers forKey:watcher.observer];
}

- (void)registerParameter:(NSString *)identifier
			  forDataType:(HNEType)dataType
			 defaultValue:(id)defaultValue
				 observer:(id)observer
				  options:(NSDictionary *)options
  blockIsSimpleAssignment:(BOOL)blockIsSimpleAssignment // YES: value assignment only, so can dispatch_sync. NO: complex callback which may be recursive, so must run async.
					block:(void (^)(id obj, id value))block
{
	
	// Extract the class and parameter name from the ID
	
	NSDictionary *parsedIdentifier = [identifier parsedIdentifier];
	NSString *className = parsedIdentifier[IDENTIFIER_CLASS_NAME] ? parsedIdentifier[IDENTIFIER_CLASS_NAME] : NSStringFromClass([observer class]);
	NSString *parameterName = parsedIdentifier[IDENTIFIER_PARAMETER_NAME];	
	
	// Set the default value
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = dataType;
	p.name = parameterName;
	p.nativeValue = defaultValue;
	[self.parameterStore setParameter:p inClass:className theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	// If there is no callback, then bail out, we’re done
	
	if (!block) { return; }
	
	// The rest of this deals with registering the callback

    // Create the callback object
    HNERegisteredCallback *callback = [[HNERegisteredCallback alloc] initWithHone:self];
    callback.observer = observer;
    callback.valueDataType = dataType;
    callback.valueIdentifier = parameterName;
    callback.callbackBlock = block;
    callback.objectClass = className;
    
    // Prepare the registration
	void (^callbackRegistrator)(void) = ^void(void) {
				
		NSMutableSet *currentCallbacks = [self.registeredCallbacks objectForKey:observer];
		if (!currentCallbacks) { currentCallbacks = [NSMutableSet set]; }
		[currentCallbacks addObject:callback];
		
		[self.registeredCallbacks setObject:currentCallbacks forKey:observer];
		
		[self registerGuidForObject:observer];
	};
	
    // Register the callback in known callbacks
	if (blockIsSimpleAssignment) {
		dispatch_sync(self.parameterStore.parameterStoreModifierQueue, callbackRegistrator);
	} else {
		dispatch_async(self.parameterStore.parameterStoreModifierQueue, callbackRegistrator);
	}
	
    // Synchronously run the initial callback
    HNEDocumentParameter *callbackP = [self.parameterStore documentParameterForIdentifier:parameterName inClass:className usedTheme:nil];
    [callback runWithParameter:callbackP];

}

- (void)registerGuidForObject:(id)observer
{
	if (![self.objectToGuid objectForKey:observer]) {
		NSUUID *guid = [NSUUID UUID];
		[self.objectToGuid setObject:guid forKey:observer];
		[self.guidToObject setObject:observer forKey:guid];
	}
}

- (id)objectNativeValueForHoneIdentifier:(NSString *)identifier
{
	NSDictionary *params = [identifier parsedIdentifier];
	NSString *c = params[IDENTIFIER_CLASS_NAME];
	NSString *p = params[IDENTIFIER_PARAMETER_NAME];
	if (!c || !p) {
		[NSException raise:NSInvalidArgumentException format:@"Invalid Hone identifier %@", identifier];
		return nil;
	}
	HNEDocumentParameter *parameter = [self.parameterStore documentParameterForIdentifier:p inClass:c usedTheme:nil];
	if (!parameter) {
		[NSException raise:NSInvalidArgumentException format:@"Hone value for the identifier %@ not found in parameter store", identifier];
		return nil;
	}
	
	// Do this kind of lookup to consider themed values
	return [self.parameterStore parameterNativeValueForIdentifier:p inClass:c];
}



#pragma mark - State

- (void)setStatus:(HNELibraryStatus)status
{
    if (_status != status) {
        
        if (_status == HNELibraryStatusNotStarted) {
            // Attempting to set status with the setter when the library has not yet been started.
            // This should fail.
            [NSException raise:NSInternalInconsistencyException format:@"Attempting to change Hone status before starting the library is not allowed."];
        }
        
        if (status == HNELibraryStatusNotStarted) {
            // Can’t go back to “not started” state.
            [NSException raise:NSInvalidArgumentException format:@"Attempting to change Hone status back to NotStarted is not allowed."];
        }
        
        _status = status;
        
        if (status == HNELibraryStatusDevelopmentMode) {
            [self startServer];
        } else {
            [self stopServer];
        }
    }
}


#pragma mark - Server

- (void)startServer
{
	if (self.status == HNELibraryStatusProductionMode) {
		[NSException raise:NSInternalInconsistencyException format:@"Attempting to start Hone Bonjour server in production mode is not allowed"];
	}
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.server = [[HNEDeviceServer alloc] initWithHone:self];
    });
	[self.server startServer];
}

- (void)stopServer
{
	[self.server stopServer];
}



@end



@implementation NSString (HNEPrivateExtensions)

- (NSDictionary *)parsedIdentifier
{
    NSRange rangeOfSeparator = [self rangeOfString:@"."];
    
    if (rangeOfSeparator.location != NSNotFound) {
        
        NSString *className = [self substringWithRange:NSMakeRange(0, rangeOfSeparator.location)];
        NSString *parameterName = [self substringWithRange:NSMakeRange(rangeOfSeparator.location + 1, self.length - rangeOfSeparator.location - 1)];
        
        return @{
                 IDENTIFIER_CLASS_NAME: className,
                 IDENTIFIER_PARAMETER_NAME: parameterName
                 };
        
    }
    
    return @{ IDENTIFIER_PARAMETER_NAME: self };    
}

@end



@implementation NSString (HNEGetter)

+ (NSString *)stringWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
}

+ (NSString *)stringWithHoneIdentifier:(NSString *)identifier defaultValue:(NSString *)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeString defaultValue:defaultValue observer:nil options:nil blockIsSimpleAssignment:YES block:nil];
	return [self stringWithHoneIdentifier:identifier];
}

@end



@implementation HNE (PrimitiveValueGetters)

+ (CGFloat)CGFloatWithHoneIdentifier:(NSString *)identifier
{
	NSNumber *n = [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
	return [n floatValue];
}

+ (CGFloat)CGFloatWithHoneIdentifier:(NSString *)identifier defaultValue:(CGFloat)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeFloat defaultValue:@(defaultValue) observer:nil options:nil blockIsSimpleAssignment:YES block:nil];
	return [self CGFloatWithHoneIdentifier:identifier];
}

+ (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] NSIntegerWithHoneIdentifier:identifier];
}

+ (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier defaultValue:(NSInteger)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeInt defaultValue:@(defaultValue) observer:nil options:nil blockIsSimpleAssignment:YES block:nil];
	return [self NSIntegerWithHoneIdentifier:identifier];
}

+ (BOOL)BOOLWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] BOOLWithHoneIdentifier:identifier];
}

+ (BOOL)BOOLWithHoneIdentifier:(NSString *)identifier defaultValue:(BOOL)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeBool defaultValue:@(defaultValue) observer:nil options:nil blockIsSimpleAssignment:YES block:nil];
	return [self BOOLWithHoneIdentifier:identifier];
}

@end
