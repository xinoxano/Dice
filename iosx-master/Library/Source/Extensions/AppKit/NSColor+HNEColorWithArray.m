//
//  NSColor+ColorWithArray.m
//  Hone
//
//  Created by Jaanus Kase on 26.06.14.
//
//

#import "NSColor+HNEColorWithArray.h"

@implementation NSColor (HNEColorWithArray)

+ (NSColor *)HNEcolorWithRGBAArray:(NSArray *)array
{
	CGFloat r, g, b, a;

#if CGFLOAT_IS_DOUBLE
	r = [array[0] doubleValue];
	g = [array[1] doubleValue];
	b = [array[2] doubleValue];
	a = [array[3] doubleValue];
#else
	r = [array[0] floatValue];
	g = [array[1] floatValue];
	b = [array[2] floatValue];
	a = [array[3] floatValue];
#endif
	
	return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
}

@end
