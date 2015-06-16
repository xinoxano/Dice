//
//  HNE+iOS.h
//  Hone
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import "HNE.h"

@interface HNE (iOS)

+ (void)bindUIColorIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
+ (void)bindUIFontIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;

+ (void)bindUIFontIdentifier:(NSString *)identifier defaultValue:(UIFont *)defaultValue object:(id)object block:(void (^)(id observer, UIFont *value))block;
+ (void)bindUIColorIdentifier:(NSString *)identifier defaultValue:(UIColor *)defaultValue object:(id)object block:(void (^)(id observer, UIColor *value))block;


/*!
 @abstract Easy method to present the Hone developer UI in your app.
 @discussion
 Assign the indicated view to receive the Hone activation gesture (two-finger double-tap). When this happens, the indicated view controller modally presents the Hone developer UI.
 
 Only intended to be used in development mode. This will silently fail (do nothing) in production mode, since users should not have access to Hone’s design-time features in production mode.
 
 @param viewController The view controller of your app that will modally present the Hone developer UI.
 @param view The view where the Hone developer UI gesture (two-finger double-tap) will be registered.
*/
+ (void)prepareDeveloperUiWithViewController:(UIViewController *)viewController view:(UIView *)view;

@end

@interface UIColor (HNEGetter)

+ (UIColor *)colorWithHoneIdentifier:(NSString *)identifier;
+ (UIColor *)colorWithHoneIdentifier:(NSString *)identifier defaultValue:(UIColor *)defaultValue;

@end

@interface UIFont (HNEGetter)

+ (UIFont *)fontWithHoneIdentifier:(NSString *)identifier;
+ (UIFont *)fontWithHoneIdentifier:(NSString *)identifier defaultValue:(UIFont *)defaultValue;

@end
