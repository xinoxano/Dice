//
//  HNE.h
//  Hone
//
//  Created by Jaanus Kase on 18.12.13.
//
//

#import <Foundation/Foundation.h>

#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif


typedef NS_ENUM(NSInteger, HNELibraryStatus) {
    
    /// The library has not yet been started.
    HNELibraryStatusNotStarted,
    
    /// The library is running in development/design mode. Values can be modified live or downlaoded from cloud.
    HNELibraryStatusDevelopmentMode,
    
    /// The library is running in production mode. Live editing and cloud interfaces are disabled, only values from code and bundled document are available.
    HNELibraryStatusProductionMode
};


/*!
 @class HNE
 @abstract Hone is a configuration mechanism for externalizing parameters that affect your app’s look and behavior.
 @discussion You use Hone to externalize parameters driving the look and behavior of your app.
 
 During design phase, engineers and designers can experiment with them, changing them in real time from other devices over the Bonjour connection implemented by the Hone library, or pulling them from the cloud server.
 
 During production phase, Hone loads the document bundled with the app, and uses the default values specified in the code.
 */

@interface HNE : NSObject

/*!
 @group Starting Hone
 */

/*!
 Initializes the Hone system. You should call this fairly early in your application lifecycle, before any code that would need to access Hone values has a chance to run. This method captures the app identifier and secret to talk to the cloud service, but does not talk to the cloud service until explicitly requested to do so by the user.
 
 @param appIdentifier The app identifier that you obtain from the Hone web app.
 @param appSecret The app secret that you obtain from the Hone web app.
 @param documentURL The URL of the Hone document that is bundled in your app. Can be nil if you haven’t yet bundled a Hone document.
 @param developmentMode YES if the app is built for development mode, NO if this is the production version. Both the development and production versions use the default values specified from the code, and overload them with the values from the Hone document bundled with the app. Additionally, the development version starts a server to receive values in real time pushed from the Hone tool, and can download values from the Hone cloud service if requested by the user.
 @param error If there are any errors starting Hone, they are reported here.
 @result YES if all good, NO if there was an error starting Hone. In the latter case, error will contain more info.
 */
+ (BOOL)startWithAppIdentifier:(NSString *)appIdentifier
					 appSecret:(NSString *)appSecret
				   documentURL:(NSURL *)documentURL
			   developmentMode:(BOOL)developmentMode
						 error:(out NSError **)error;


/*!
 Shared instance of the library.
 
 Most of the time, you interact with Hone using the class methods that save you some typing. You can use the instance’s status property to get or set the current library state.
 */
+ (instancetype)sharedHone;

/*!
 Whether the library has been started, or if so, which mode is it running in.
 
 You can set this between production and development modes at any time, but you can’t go back to notStarted.
 */
@property (nonatomic, assign) HNELibraryStatus status;

/*!
 @group Themes
 */

/*! Activate the specified themes.
 
 @param themes
 List of NSString theme names to activate.
 
 Themes are sets of configuration parameters for a particular situation. There is always a “default” theme in a Hone document. In addition, it can contain other themes, whose semantics are up to you.
 
 The order is important, value lookup will happen in exactly this order. If no matching value is found from any themes, the value from “default” is used. You shouldn’t specify “default” in this list, it’s always implied to be the last one/fallback. Pass nil or empty array to clear out any themes and just use the default.
 */
+ (void)activateThemes:(NSArray *)themes;

/*!
 @group Exposing parameters
 */

/*!
 Expose a value to be managed by Hone.
 
 @param identifier The identifier to use in the Hone system. Can be either “parameterName”, or keypath-style “categoryName.parameterName”. In the former case, category name is automatically derived from the class name of the object.
 @param object The application object responsible for this value. Hone keeps a weak reference to this object to track the lifecycle of the parameter. Any value changes are only attempted if this object is still valid.
 @param keyPath The keypath of the Hone-managed parameter within the object. For example, of object is a view controller, and it has a NSLayoutConstraint property, then you can expose the constant to Hone by using object “self” and keyPath “constraintPropertyName.constant”.
 */
+ (void)bindCGFloatIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
+ (void)bindNSIntegerIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
+ (void)bindNSStringIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
+ (void)bindBOOLIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;

/*!
 Expose a value to be managed by Hone, and run a block every time the value changes.
 
 @param identifier The identifier to use in the Hone system. Can be either “parameterName”, or keypath-style “categoryName.parameterName”. In the former case, category name is automatically derived from the class name of the object.
 @param defaultValue The default value to use.
 @param object The application object responsible for this value. Hone keeps a weak reference to this object to track the lifecycle of the parameter. Any value changes are only attempted if this object is still valid.
 @param block The block to run when the value of the parameter changes. It gets two parameters: first, the object passed in the previous parameter, and second, the new value. The block is immediately run on registration (i.e when doing the binding with this call) and subsequently, every time the value changes (e.g new value is received over local network, or switching themes changes the value).
 */

+ (void)bindCGFloatIdentifier:(NSString *)identifier defaultValue:(CGFloat)defaultValue object:(id)object block:(void (^)(id observer, CGFloat value))block;
+ (void)bindNSIntegerIdentifier:(NSString *)identifier defaultValue:(NSInteger)defaultValue object:(id)object block:(void (^)(id observer, NSInteger value))block;
+ (void)bindNSStringIdentifier:(NSString *)identifier defaultValue:(NSString *)defaultValue object:(id)object block:(void (^)(id observer, NSString *value))block;
+ (void)bindBOOLIdentifier:(NSString *)identifier defaultValue:(BOOL)defaultValue object:(id)object block:(void (^)(id observer, BOOL value))block;

/*!
 Run a block every time the value of given Hone identifiers change.
 
 @param identifiers NSStrings of the Hone identifiers to watch. Can be either complete identifiers like “category.parameter”, or a whole category like “category”. Can also be nil to watch all changes.
 @param object The application object interested in the values. Hone keeps a weak reference to this object. The block is run only if this object is still valid.
 @param block The block to run when any of the given values change. It gets two parameters: first, the object passed in the previous parameter, and second, array of the Hone identifier names that actually changed. The block is NOT run when registering the watcher: it is only run when the value actually changes.
 */
+ (void)watchIdentifiers:(NSArray *)identifiers object:(id)object block:(void (^)(id observer, NSArray *changedIdentifiers))block;

// Update from cloud service. valuesChanged = if anything changed at all
+ (void)updateFromCloudWithCompletionBlock:(void (^)(BOOL success, BOOL valuesChanged, NSError *error))completionBlock;

@end


// Value accessors

@interface NSString (HNEGetter)

+ (NSString *)stringWithHoneIdentifier:(NSString *)identifier;
+ (NSString *)stringWithHoneIdentifier:(NSString *)identifier defaultValue:(NSString *)defaultValue;

@end



@interface HNE (PrimitiveValueGetters)

+ (BOOL)BOOLWithHoneIdentifier:(NSString *)identifier;
+ (BOOL)BOOLWithHoneIdentifier:(NSString *)identifier defaultValue:(BOOL)defaultValue;

+ (CGFloat)CGFloatWithHoneIdentifier:(NSString *)identifier;
+ (CGFloat)CGFloatWithHoneIdentifier:(NSString *)identifier defaultValue:(CGFloat)defaultValue;

+ (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier;
+ (NSInteger)NSIntegerWithHoneIdentifier:(NSString *)identifier defaultValue:(NSInteger)defaultValue;

@end
