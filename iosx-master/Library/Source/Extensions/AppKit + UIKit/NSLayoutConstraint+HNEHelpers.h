//
//  NSLayoutConstraint+Helpers.h
//  ZClient-Mac
//
//  Created by Daniel Eggert on 5/7/13.
//  Copyright (c) 2013 Zeta Project Germany GmbH. All rights reserved.
//

#import <TargetConditionals.h>

#if (TARGET_OS_IPHONE)

#import <UIKit/UIKit.h>

@compatibility_alias HNELCHView UIView;
typedef UILayoutPriority HNELCHLayoutPriority;
typedef UIEdgeInsets HNELCHEdgeInsets;

#else

#import <Cocoa/Cocoa.h>

@compatibility_alias HNELCHView NSView;
typedef NSLayoutPriority HNELCHLayoutPriority;
typedef NSEdgeInsets HNELCHEdgeInsets;

#endif



@interface NSLayoutConstraint (HNEHelpersGeneric)

+ (instancetype)HNEconstraintWithItem:(HNELCHView *)view1 attribute:(NSLayoutAttribute)attr toItem:(HNELCHView *)view2;
+ (instancetype)HNEconstraintWithItem:(HNELCHView *)view1 attribute:(NSLayoutAttribute)attr toItem:(HNELCHView *)view2 constant:(CGFloat)c;

@end



@interface NSLayoutConstraint (HNEHelpersRelative)

+ (instancetype)HNEconstraintForEqualWidthWithItem:(HNELCHView *)view1 toItem:(HNELCHView *)view2;
+ (instancetype)HNEconstraintForEqualHeightWithItem:(HNELCHView *)view1 toItem:(HNELCHView *)view2;

+ (NSArray *)HNEconstraintsHorizontallyFittingItem:(HNELCHView *)view1 withItem:(HNELCHView *)view2;
+ (NSArray *)HNEconstraintsVerticallyFittingItem:(HNELCHView *)view1 withItem:(HNELCHView *)view2;

@end



@interface HNELCHView (HNELayoutConstraintsHelpersAbsolute)

- (NSArray *)HNEaddConstraintsForSize:(CGSize)size;
- (NSLayoutConstraint *)HNEaddConstraintForWidth:(CGFloat)width;
- (NSLayoutConstraint *)HNEaddConstraintForHeight:(CGFloat)height;
- (NSLayoutConstraint *)HNEaddConstraintForMaxWidth:(CGFloat)width;
- (NSLayoutConstraint *)HNEaddConstraintForMaxHeight:(CGFloat)height;
- (NSLayoutConstraint *)HNEaddConstraintForMinWidth:(CGFloat)width;
- (NSLayoutConstraint *)HNEaddConstraintForMinHeight:(CGFloat)height;
- (NSLayoutConstraint *)HNEaddConstraintForHeightAsMultipleOfWidth:(CGFloat)multiplier;
- (NSLayoutConstraint *)HNEaddConstraintForWidthAsMultipleOfHeight:(CGFloat)multiplier;



#if (!TARGET_OS_IPHONE)
// upstream APIs only available on OSX
- (void)HNEsetContentCompressionResistancePriority:(NSLayoutPriority)priority;
- (void)HNEsetContentHuggingPriority:(NSLayoutPriority)priority;
#endif

@end



@interface HNELCHView (HNELayoutConstraintsHelpersRelative)

/**
 C.f. "Constraints May Cross View Hierarchies" documentation. */
- (HNELCHView *)HNEsuperviewCommonWithView:(HNELCHView *)otherView;

/** Note the ordering! */
- (NSLayoutConstraint *)HNEaddConstraintWithAttribute:(NSLayoutAttribute)attr constant:(CGFloat)c toView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintFromView:(HNELCHView *)otherView constant:(CGFloat)c attribute:(NSLayoutAttribute)attr;

- (NSLayoutConstraint *)HNEaddConstraintForEqualWidthToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForEqualHeightToView:(HNELCHView *)otherView;

- (NSArray *)HNEaddConstraintsFittingToView:(HNELCHView *)otherView;
- (NSArray *)HNEaddConstraintsFittingToView:(HNELCHView *)otherView edgeInsets:(HNELCHEdgeInsets)insets;
- (NSArray *)HNEaddConstraintsHorizontallyFittingToView:(HNELCHView *)otherView;
- (NSArray *)HNEaddConstraintsVerticallyFittingToView:(HNELCHView *)otherView;

- (NSLayoutConstraint *)HNEaddConstraintsCenteringToView:(HNELCHView *)otherView;

- (NSArray *)HNEaddConstraintsForRightMargin:(CGFloat)rightMargin leftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForMinRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForMaxRightMargin:(CGFloat)rightMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForMinLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForMaxLeftMargin:(CGFloat)leftMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEAddConstraintforBaseline:(CGFloat)baseline relativeToView:(HNELCHView *)otherView;

- (NSLayoutConstraint *)HNEaddConstraintForTopMargin:(CGFloat)topMargin relativeToView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForBottomMargin:(CGFloat)bottomMargin relativeToView:(HNELCHView *)otherView;

- (NSLayoutConstraint *)HNEaddConstraintForAligningHorizontallyWithView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForAligningHorizontallyWithView:(HNELCHView *)otherView offset:(CGFloat)offset;

- (NSLayoutConstraint *)HNEaddConstraintForAligningVerticallyWithView:(HNELCHView *)otherView;
- (NSLayoutConstraint *)HNEaddConstraintForAligningVerticallyWithView:(HNELCHView *)otherView offset:(CGFloat)offset;

- (NSLayoutConstraint *)HNEaddConstraintForAligningTopToBottomOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningBottomToTopOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningTopToTopOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningBottomToBottomOfView:(HNELCHView *)otherView distance:(CGFloat)c;


- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView minDistance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToRightOfView:(HNELCHView *)otherView maxDistance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningLeftToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningRightToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningRightToRightOfView:(HNELCHView *)otherView distance:(CGFloat)c;
- (NSLayoutConstraint *)HNEaddConstraintForAligningCenterToLeftOfView:(HNELCHView *)otherView distance:(CGFloat)c;

- (NSArray*)HNEaddConstraintsForStackingViewsVertically:(NSArray*)views withSpacing:(CGFloat)spacing bottomMargin:(CGFloat)bottomMargin;
- (NSArray*)HNEaddConstraintsForStackingViewsHorizontally:(NSArray*)views withSpacing:(CGFloat)spacing;

/// Add constraints to position a view in the given view with constants dictionary containing any subset of “top”, “bottom”, “left”, “right”, “height” and “width” keys
- (NSArray *)HNEaddConstraintsForPositioningInView:(HNELCHView *)otherView withLayoutConstants:(NSDictionary *)constants;

@end
