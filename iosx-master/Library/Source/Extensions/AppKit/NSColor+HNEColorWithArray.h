//
//  NSColor+ColorWithArray.h
//  Hone
//
//  Created by Jaanus Kase on 26.06.14.
//
//

#import <Cocoa/Cocoa.h>

@interface NSColor (HNEColorWithArray)

/// Construct a color out of the given RGBA values passed as array
+ (NSColor *)HNEcolorWithRGBAArray:(NSArray *)array;

@end
