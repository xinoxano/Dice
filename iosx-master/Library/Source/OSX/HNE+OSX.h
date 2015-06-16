//
//  HNE+OSX.h
//  Hone
//
//  Created by Jaanus Kase on 02.07.14.
//
//

#import "HNE.h"



@interface HNE (OSX)

+ (void)bindNSColorIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;
+ (void)bindNSFontIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath;

+ (void)bindNSFontIdentifier:(NSString *)identifier defaultValue:(NSFont *)defaultValue object:(id)object block:(void (^)(id observer, NSFont *value))block;
+ (void)bindNSColorIdentifier:(NSString *)identifier defaultValue:(NSColor *)defaultValue object:(id)object block:(void (^)(id observer, NSColor *value))block;

@end



@interface NSColor (HNEGetter)

+ (NSColor *)colorWithHoneIdentifier:(NSString *)identifier;
+ (NSColor *)colorWithHoneIdentifier:(NSString *)identifier defaultValue:(NSColor *)defaultValue;

@end



@interface NSFont (HNEGetter)

+ (NSFont *)fontWithHoneIdentifier:(NSString *)identifier;
+ (NSFont *)fontWithHoneIdentifier:(NSString *)identifier defaultValue:(NSFont *)defaultValue;

@end
