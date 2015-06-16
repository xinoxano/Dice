//
//  HNEFont+HNETypography.h
//  Hone
//
//  Created by Jaanus Kase on 02.07.14.
//
//

//#if (TARGET_OS_IPHONE)
//#import <UIKit/UIKit.h>
//#else
//#import <AppKit/AppKit.h>
//#endif

#import "HNEShared.h"


@interface HNEFont (HNETypography)

+ (HNEFont *)fontWithHNESerializedRepresentation:(NSDictionary *)representation;

- (NSDictionary *)HNEserializedRepresentation;

@end
