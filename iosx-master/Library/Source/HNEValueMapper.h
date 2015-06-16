//
//  HNEValueMapper.h
//  Hone-iosx
//
//  Created by Jaanus Kase on 17/11/14.
//
//

#import <Foundation/Foundation.h>

/**
 Transform some Hone values into their appropriate native representations and apply them in Hone’s “object binding” mode.
 
 Most of the time, Hone object binding works great with transparent key-value coding, but some values need special handling.
 A good example is some CALayer properties that need to be represented as CGColorRef-s instead of Hone’s native NSColor/UIColor
 representation. This mapping could be manually done with Hone’s block-based APIs, but since these cases are pretty standard,
 we save users this trouble, and automatically map these values.
 */
@interface HNEValueMapper : NSObject

+ (instancetype)sharedValueMapper;

/// YES if the mapper did some the transformation and application, NO if it didn’t apply the value in any way.
- (BOOL)didApplyHoneValue:(id)nativeValue valueIdentifier:(NSString *)valueIdentifier toObject:(id)object;

@end
