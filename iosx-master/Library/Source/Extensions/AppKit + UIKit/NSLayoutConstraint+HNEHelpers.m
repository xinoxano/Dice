//
//  NSLayoutConstraint+Helpers.m
//  ZClient-Mac
//
//  Created by Daniel Eggert on 5/7/13.
//  Copyright (c) 2013 Zeta Project Germany GmbH. All rights reserved.
//

#import "NSLayoutConstraint+HNEHelpers.h"

@implementation NSLayoutConstraint (Helpers)

+ (instancetype)HNEconstraintWithItem:(HNELCHView *)view1 attribute:(NSLayoutAttribute)attr toItem:(HNELCHView *)view2;
{
    NSLayoutConstraint *constraint = [self HNEconstraintWithItem:view1 attribute:attr toItem:view2 constant:0];
    return constraint;
}

+ (instancetype)HNEconstraintWithItem:(HNELCHView *)view1 attribute:(NSLayoutAttribute)attr toItem:(HNELCHView *)view2 constant:(CGFloat)c;
{
    NSLayoutConstraint *constraint = [self constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1 constant:c];
    return constraint;
}

+ (instancetype)HNEconstraintWithItem:(HNELCHView *)view attribute:(NSLayoutAttribute)attr constant:(CGFloat)c;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view attribute:attr relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:c];
    return constraint;
}

+ (instancetype)HNEconstraintForEqualWidthWithItem:(HNELCHView *)view1 toItem:(HNELCHView *)view2;
{
    return [self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeWidth toItem:view2];
}

+ (instancetype)HNEconstraintForEqualHeightWithItem:(HNELCHView *)view1 toItem:(HNELCHView *)view2;
{
    return [self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeHeight toItem:view2];
}

+ (NSArray *)HNEconstraintsHorizontallyFittingItem:(HNELCHView *)view1 withItem:(HNELCHView *)view2;
{
    return @[[self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeLeft toItem:view2],
             [self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeRight toItem:view2]];
}

+ (NSArray *)HNEconstraintsVerticallyFittingItem:(HNELCHView *)view1 withItem:(HNELCHView *)view2;
{
    return @[[self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeTop toItem:view2],
             [self HNEconstraintWithItem:view1 attribute:NSLayoutAttributeBottom toItem:view2]];
}

@end



#pragma mark -

@implementation HNELCHView (LayoutConstraintsHelpersAbsolute)

- (NSArray *)HNEaddConstraintsForSize:(CGSize)size
{
    NSLayoutConstraint *withConstraint = [self HNEaddConstraintForWidth:size.width];
    NSLayoutConstraint *heightConstraint = [self HNEaddConstraintForHeight:size.height];
    
    return @[withConstraint, heightConstraint];
}

- (NSLayoutConstraint *)HNEaddConstraintForHeight:(CGFloat)height;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeHeight constant:height];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForWidth:(CGFloat)width;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeWidth constant:width];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMaxWidth:(CGFloat)width;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMaxHeight:(CGFloat)height;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMinWidth:(CGFloat)width;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMinHeight:(CGFloat)height;
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForHeightAsMultipleOfWidth:(CGFloat)multiplier
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:multiplier constant:0];
    [self addConstraint:constraint];
    return constraint;

}


- (NSLayoutConstraint *)HNEaddConstraintForWidthAsMultipleOfHeight:(CGFloat)multiplier
{
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:multiplier constant:0];
    [self addConstraint:constraint];
    return constraint;
   
}



#if !TARGET_OS_IPHONE

- (void)HNEsetContentCompressionResistancePriority:(NSLayoutPriority)priority;
{
    [self setContentCompressionResistancePriority:priority forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setContentCompressionResistancePriority:priority forOrientation:NSLayoutConstraintOrientationVertical];
}

- (void)HNEsetContentHuggingPriority:(NSLayoutPriority)priority;
{
    [self setContentHuggingPriority:priority forOrientation:NSLayoutConstraintOrientationHorizontal];
    [self setContentHuggingPriority:priority forOrientation:NSLayoutConstraintOrientationVertical];
}

#endif



@end



#pragma mark -

@implementation HNELCHView (LayoutConstraintsHelpersRelative)

- (HNELCHView *)HNEsuperviewCommonWithView:(HNELCHView *)otherView;
{
    // Check common case 1st:
    if (otherView.superview == self.superview) {
        return self.superview;
    }
    
    id chainA[10];
    size_t chainALength = 0;
    id chainB[10];
    size_t chainBLength = 0;
    
    // Slightly brute force:
    chainA[chainALength++] = otherView;
    chainB[chainBLength++] = self;
    do {
        // Check
        for (size_t i = 0; i < chainALength; ++i) {
            for (size_t j = 0; j < chainBLength; ++j) {
                if (chainA[i] == chainB[j]) {
                    return chainA[i];
                }
            }
        }
        BOOL const addToA = chainALength < (sizeof(chainA) / sizeof(*chainA));
        if (addToA) {
            HNELCHView *view = chainA[chainALength - 1];
            chainA[chainALength++] = view.superview;
        }
        BOOL const addToB = chainBLength < (sizeof(chainB) / sizeof(*chainB));
        if (addToB) {
            HNELCHView *view = chainB[chainBLength - 1];
            chainB[chainBLength++] = view.superview;
        }
        if (!addToA && !addToB) {
            break;
        }
    } while (YES);
    return nil;
}

- (NSLayoutConstraint *)HNEaddConstraintWithAttribute:(NSLayoutAttribute)attr constant:(CGFloat)c toView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:attr toItem:otherView constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintFromView:(HNELCHView *)otherView constant:(CGFloat)c attribute:(NSLayoutAttribute)attr;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:attr toItem:self constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForEqualWidthToView:(id)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintForEqualWidthWithItem:self toItem:otherView];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForEqualHeightToView:(id)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintForEqualHeightWithItem:self toItem:otherView];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSArray *)HNEaddConstraintsCenteringToView:(HNELCHView *)otherView
{
    NSLayoutConstraint *hConstraint = [self HNEaddConstraintForAligningHorizontallyWithView:otherView];
    NSLayoutConstraint *vConstraint = [self HNEaddConstraintForAligningVerticallyWithView:otherView];
    
    return @[hConstraint, vConstraint];
}

- (NSArray *)HNEaddConstraintsFittingToView:(HNELCHView *)otherView;
{
    return [[self HNEaddConstraintsHorizontallyFittingToView:otherView] arrayByAddingObjectsFromArray:
            [self HNEaddConstraintsVerticallyFittingToView:otherView]];
}

- (NSArray *)HNEaddConstraintsFittingToView:(HNELCHView *)otherView edgeInsets:(HNELCHEdgeInsets)insets;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    
    NSLayoutConstraint *left = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeLeft toItem:otherView constant:insets.left];
    NSLayoutConstraint *right = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeRight toItem:self constant:insets.right];
    NSLayoutConstraint *top = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeTop toItem:otherView constant:insets.top];
    NSLayoutConstraint *bottom = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeBottom toItem:self constant:insets.bottom];
    
    NSArray *constraints = @[left, right, top, bottom];
    [superview addConstraints:constraints];
    
    return constraints;
}

- (NSArray *)HNEaddConstraintsHorizontallyFittingToView:(id)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSArray *constraints = [NSLayoutConstraint HNEconstraintsHorizontallyFittingItem:self withItem:otherView];
    [superview addConstraints:constraints];
    return constraints;
}

- (NSArray *)HNEaddConstraintsVerticallyFittingToView:(id)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSArray *constraints = [NSLayoutConstraint HNEconstraintsVerticallyFittingItem:self withItem:otherView];
    [superview addConstraints:constraints];
    return constraints;
}

- (NSArray *)HNEaddConstraintsForRightMargin:(CGFloat)rightMargin leftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeLeft toItem:otherView constant:leftMargin];
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeRight toItem:self constant:rightMargin];

    NSArray *constraints = @[constraint1, constraint2];
    [superview addConstraints:constraints];
    
    return constraints;
}

- (NSLayoutConstraint *)HNEaddConstraintForRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeRight toItem:self constant:rightMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMinRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:otherView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:rightMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMaxRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:otherView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:rightMargin];
    [superview addConstraint:constraint];
    return constraint;
}



- (NSLayoutConstraint *)HNEaddConstraintForLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeLeft toItem:otherView constant:leftMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMinLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:otherView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:leftMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForMaxLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:otherView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:leftMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEAddConstraintforBaseline:(CGFloat)baseline relativeToView:(HNELCHView *)otherView
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeBaseline toItem:otherView constant:baseline];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForTopMargin:(CGFloat)topMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeTop toItem:otherView constant:topMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForBottomMargin:(CGFloat)bottomMargin relativeToView:(HNELCHView *)otherView;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeBottom toItem:self constant:bottomMargin];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningHorizontallyWithView:(HNELCHView *)otherView
{
    return [self HNEaddConstraintForAligningHorizontallyWithView:otherView offset:0];
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningHorizontallyWithView:(HNELCHView *)otherView offset:(CGFloat)offset;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:otherView attribute:NSLayoutAttributeCenterX toItem:self constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningVerticallyWithView:(HNELCHView *)otherView;
{
    return [self HNEaddConstraintForAligningVerticallyWithView:otherView offset:0];
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningVerticallyWithView:(HNELCHView *)otherView offset:(CGFloat)offset;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint HNEconstraintWithItem:self attribute:NSLayoutAttributeCenterY toItem:otherView constant:offset];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningTopToBottomOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeBottom multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningBottomToTopOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
//    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeTop multiplier:1 constant:c];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:otherView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningBottomToBottomOfView:(HNELCHView *)otherView distance:(CGFloat)c
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:otherView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningTopToTopOfView:(HNELCHView *)otherView distance:(CGFloat)c
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:otherView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}


- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeRight multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView maxDistance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationLessThanOrEqual toItem:otherView attribute:NSLayoutAttributeRight multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView minDistance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:otherView attribute:NSLayoutAttributeRight multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeLeft multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningRightToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeLeft multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningRightToRightOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeRight multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)HNEaddConstraintForAligningCenterToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;
{
    HNELCHView *superview = [self HNEsuperviewCommonWithView:otherView];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:otherView attribute:NSLayoutAttributeLeft multiplier:1 constant:c];
    [superview addConstraint:constraint];
    return constraint;
}

- (NSArray*)HNEaddConstraintsForStackingViewsVertically:(NSArray*)views withSpacing:(CGFloat)spacing bottomMargin:(CGFloat)bottomMargin
{
    NSMutableArray* constraints = [NSMutableArray array];
    HNELCHView *previousView = nil;
    for (HNELCHView *view in views) {
        if (previousView) {
            NSLayoutConstraint* constraint = [view HNEaddConstraintForAligningTopToBottomOfView:previousView distance:spacing];
            [constraints addObject:constraint];
        }
        previousView = view;
    }
    NSLayoutConstraint* constraint = [views.lastObject HNEaddConstraintForBottomMargin:bottomMargin relativeToView:self];
    [constraints addObject:constraint];
    return constraints;
}

- (NSArray*)HNEaddConstraintsForStackingViewsHorizontally:(NSArray*)views withSpacing:(CGFloat)spacing
{
    NSMutableArray* constraints = [NSMutableArray array];
    HNELCHView *previousView = nil;
    for (HNELCHView *view in views) {
        if (previousView) {
            NSLayoutConstraint* constraint = [view HNEaddConstraintForAligningLeftToRightOfView:previousView distance:spacing];
            [constraints addObject:constraint];
        }
        previousView = view;
    }
    NSLayoutConstraint* constraint = [views.lastObject HNEaddConstraintForRightMargin:0 relativeToView:self];
    [constraints addObject:constraint];
    return constraints;
}

- (NSArray *)HNEaddConstraintsForPositioningInView:(HNELCHView *)otherView withLayoutConstants:(NSDictionary *)constants
{
    NSMutableArray *constraints = [NSMutableArray array];
    
    if (constants[@"top"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForTopMargin:[constants[@"top"] floatValue] relativeToView:otherView];
        [constraints addObject:constraint];
    }
    
    if (constants[@"bottom"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForBottomMargin:[constants[@"bottom"] floatValue] relativeToView:otherView];
        [constraints addObject:constraint];
    }
    
    if (constants[@"left"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForLeftMargin:[constants[@"left"] floatValue] relativeToView:otherView];
        [constraints addObject:constraint];
    }
    
    if (constants[@"right"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForRightMargin:[constants[@"right"] floatValue] relativeToView:otherView];
        [constraints addObject:constraint];
    }

    if (constants[@"height"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForHeight:[constants[@"height"] floatValue]];
        [constraints addObject:constraint];
    }

    if (constants[@"width"]) {
        NSLayoutConstraint *constraint = [self HNEaddConstraintForWidth:[constants[@"width"] floatValue]];
        [constraints addObject:constraint];
    }
    
    return constraints;
}



@end
