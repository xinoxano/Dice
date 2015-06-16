//
//  HNEValueMapper.m
//  Hone-iosx
//
//  Created by Jaanus Kase on 17/11/14.
//
//

#import "HNEValueMapper.h"
#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define HNEValueMapperView UIView
#define HNEValueMapperColor UIColor
#else
#import <AppKit/AppKit.h>
#define HNEValueMapperView NSView
#define HNEValueMapperColor NSColor
#endif



@implementation HNEValueMapper

+ (instancetype)sharedValueMapper
{
    static dispatch_once_t onceToken;
    static HNEValueMapper *singleton;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (BOOL)didApplyHoneValue:(id)nativeValue valueIdentifier:(NSString *)valueIdentifier toObject:(id)object
{
    
//#if (TARGET_OS_IPHONE)
    // iOS special cases
//#else
    // OSX special cases
//#endif
    
    // The view-and-layer stuff can be handled in this way, with crossplatform code.
    // If later we need platform specific handling, should use the branching shown above.

    if ([object isKindOfClass:[HNEValueMapperView class]]) {
        if ([valueIdentifier isEqualToString:@"layer.borderColor"]) {
            ((HNEValueMapperView *)object).layer.borderColor = ((HNEValueMapperColor *)nativeValue).CGColor;
            return YES;
        }
        if ([valueIdentifier isEqualToString:@"layer.backgroundColor"]) {
            ((HNEValueMapperView *)object).layer.backgroundColor = ((HNEValueMapperColor *)nativeValue).CGColor;
            return YES;
        }
        if ([valueIdentifier isEqualToString:@"layer.shadowColor"]) {
            ((HNEValueMapperView *)object).layer.shadowColor = ((HNEValueMapperColor *)nativeValue).CGColor;
            return YES;
        }
    }
    
    return NO;
}

@end
