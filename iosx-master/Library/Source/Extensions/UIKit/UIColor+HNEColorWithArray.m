//
//  UIColor+ColorWithArray.m
//  Hone
//
//  Created by Jaanus Kase on 29.06.14.
//
//

#import "UIColor+HNEColorWithArray.h"

@implementation UIColor (HNEColorWithArray)

+ (UIColor *)HNEcolorWithRGBAArray:(NSArray *)array
{
	CGFloat r = [array[0] floatValue];
	CGFloat g = [array[1] floatValue];
	CGFloat b = [array[2] floatValue];
	CGFloat a = [array[3] floatValue];
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
