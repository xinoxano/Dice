//
//  HNE+iOS.m
//  Hone
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import "HNE.h"
#import "HNE+iOS.h"
#import "HNE+Private.h"
#import "HNEDeveloperViewController.h"



@implementation HNE (iOS)

+ (void)bindUIColorIdentifier:(NSString *)identifier
				 defaultValue:(UIColor *)defaultValue
					   object:(id)observer
						block:(void (^)(id observer, UIColor *value))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeColor
					  defaultValue:defaultValue
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

+ (void)bindUIFontIdentifier:(NSString *)identifier
				defaultValue:(UIFont *)defaultValue
					  object:(id)observer
					   block:(void (^)(id, UIFont *))block
{
	[[self sharedHone] registerParameter:identifier
					   forDataType:HNETypeFont
					  defaultValue:defaultValue
						  observer:observer
						   options:nil
		   blockIsSimpleAssignment:NO
							 block:(void (^)(id obj, id value))block];
}

+ (void)bindUIColorIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindUIColorIdentifier:identifier defaultValue:[object valueForKeyPath:keyPath] object:object block:^(id observer, UIColor *value) {
		[observer setValue:value forKeyPath:keyPath];
	}];
}

+ (void)bindUIFontIdentifier:(NSString *)identifier object:(id)object keyPath:(NSString *)keyPath
{
	[self bindUIFontIdentifier:identifier defaultValue:[object valueForKeyPath:keyPath] object:object block:^(id observer, UIFont *value) {
		[observer setValue:value forKeyPath:keyPath];
	}];
}


+ (void)prepareDeveloperUiWithViewController:(UIViewController *)vc view:(UIView *)view
{
	// Don’t do this in production mode.
	if ([HNE sharedHone].status == HNELibraryStatusProductionMode) { return; }
	
	[HNE sharedHone].iosDevUiViewController = vc;
	UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentHoneDeveloperUi:)];
	tapper.numberOfTapsRequired = 2;
	tapper.numberOfTouchesRequired = 2;
	[view addGestureRecognizer:tapper];
}

+ (void)presentHoneDeveloperUi:(UITapGestureRecognizer *)tapper
{
	if (tapper.state == UIGestureRecognizerStateRecognized) {
		
		if (![HNE sharedHone].iosDevUiViewController) { return; }
		
		UIViewController *devVc = [HNEDeveloperViewController containedViewControllerForPresentation];
		[[HNE sharedHone].iosDevUiViewController presentViewController:devVc animated:YES completion:nil];
	}
}

@end



@implementation UIColor (HNEGetter)

+ (UIColor *)colorWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
}

+ (UIColor *)colorWithHoneIdentifier:(NSString *)identifier defaultValue:(UIColor *)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeColor defaultValue:defaultValue observer:nil options:nil  blockIsSimpleAssignment:YES block:nil];
	return [self colorWithHoneIdentifier:identifier];
}

@end



@implementation UIFont (HNEGetter)

+ (UIFont *)fontWithHoneIdentifier:(NSString *)identifier
{
	return [[HNE sharedHone] objectNativeValueForHoneIdentifier:identifier];
}

+ (UIFont *)fontWithHoneIdentifier:(NSString *)identifier defaultValue:(UIFont *)defaultValue
{
	[[HNE sharedHone] registerParameter:identifier forDataType:HNETypeFont defaultValue:defaultValue observer:nil options:nil  blockIsSimpleAssignment:YES block:nil];
	return [self fontWithHoneIdentifier:identifier];
}

@end
