//
//  HNETestView.m
//  HoneExample
//
//  Created by Jaanus Kase on 26.02.14.
//
//

#import "HNETestView.h"
#import <HoneIOS/HoneIOS.h>
#import <QuartzCore/QuartzCore.h>



CGFloat DegreesToRadians(CGFloat degrees)
{
	return degrees * M_PI / 180;
};


@interface HNETestView ()

@property UILabel *label;

@end


@implementation HNETestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self setup];
		
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	[HNE bindCGFloatIdentifier:@"oneBox.rotation"
					  defaultValue:0
						   object:self
							  block:^(HNETestView *v, CGFloat value)
	 {
		 v.transform = CGAffineTransformMakeRotation(DegreesToRadians(value));
	 }];
	
	self.label = [[UILabel alloc] initWithFrame:self.bounds];
	self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	self.label.backgroundColor = [UIColor clearColor];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.text = @"Wat 01234 56789";
	self.label.font = [UIFont fontWithName:@"ChoplinLight" size:14];
	self.label.numberOfLines = 0;
	[self addSubview:self.label];
	self.layer.masksToBounds = YES;
		
	self.backgroundColor = [UIColor yellowColor];
    
    [self bindToHoneObject:@"oneBox" options:@{ HNEIgnoredValueIdentifiers: [NSSet setWithArray:@[
                                                                             @"size",
                                                                             @"rotation",
                                                                             @"firstAnimationLength",
                                                                             @"secondAnimationLength",
                                                                             @"animationAlpha",
                                                                             @"animationScale"] ]}];
}

@end
