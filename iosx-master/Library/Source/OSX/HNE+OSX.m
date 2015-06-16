//
//  HNE+OSX.m
//  Hone
//
//  Created by Jaanus Kase on 02.07.14.
//
//

#import "HNE.h"
#import "HNE+OSX.h"
#import "HNE+Private.h"

@implementation HNE (OSX)

+ (void)bindNSColorIdentifier:(NSString *)identifier
				 defaultValue:(NSColor *)defaultValue
					   object:(id)observer
						block:(void (^)(id observer, NSColor *value))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeColor
					  defaultValue:defaultValue
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

+ (void)bindNSFontIdentifier:(NSString *)identifier
				defaultValue:(NSFont *)defaultValue
					  object:(id)observer
					   block:(void (^)(id, NSFont *))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeFont
					  defaultValue:defaultValue
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

+ (void)bindNSColorIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindNSColorIdentifier:identifier defaultValue:[object valueForKeyPath:keyPath] object:object block:^(id observer, NSColor *value) {
		[observer setValue:value forKeyPath:keyPath];
	}];
}

+ (void)bindNSFontIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindNSFontIdentifier:identifier defaultValue:[object valueForKeyPath:keyPath] object:object block:^(id observer, NSFont *value) {
		[observer setValue:value forKeyPath:keyPath];
	}];
}

@end


@implementation NSColor (HNEGetter)

+ (NSColor *)colorWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
}

+ (NSColor *)colorWithHoneIdentifier:(NSString *)identifier defaultValue:(NSColor *)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeColor defaultValue:defaultValue observer:nil options:nil  blockIsSimpleAssignment:YES block:nil];
	return [self colorWithHoneIdentifier:identifier];
}

@end



@implementation NSFont (HNEGetter)

+ (NSFont *)fontWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
}

+ (NSFont *)fontWithHoneIdentifier:(NSString *)identifier defaultValue:(NSFont *)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeFont defaultValue:defaultValue observer:nil options:nil  blockIsSimpleAssignment:YES block:nil];
	return [self fontWithHoneIdentifier:identifier];
}

@end