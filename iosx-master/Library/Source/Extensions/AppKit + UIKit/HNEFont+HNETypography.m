//
//  HNEFont+HNETypography.m
//  Hone
//
//  Created by Jaanus Kase on 02.07.14.
//
//

#import "HNE.h"
#import "HNEFont+HNETypography.h"
#import "HNEShared.h"
#import <CoreText/CoreText.h>



static NSString * const FontNumberSpacingAttribute      = @"number_spacing";
static NSString * const FontNumberSpacingProportional   = @"proportional";
static NSString * const FontNumberSpacingMonospaced     = @"monospaced";

static NSString * const FontNumberStyleAttribute        = @"number_style";
static NSString * const FontNumberStyleOldstyle         = @"oldstyle";
static NSString * const FontNumberStyleRegular          = @"regular";



@implementation HNEFont (HNETypography)

+ (HNEFont *)fontWithHNESerializedRepresentation:(NSDictionary *)representation
{
    NSString *fontName = representation[@"typeface"];
    NSNumber *fontSize = representation[@"size"];
    CGFloat fontSizeFloat = [fontSize floatValue];
    
//		//    “An array of dictionaries representing non-default font feature settings. Each dictionary
//		//    contains UIFontFeatureTypeIdentifierKey and UIFontFeatureSelectorIdentifierKey.”
//		// this blog post describes how to query the features: http://blog.amyworrall.com/post/46329875785/core-text-and-upper-case-numbers
//		
//		/*
//		 CTFeatureTypeExclusive = 1;
//		 CTFeatureTypeIdentifier = 6;
//		 CTFeatureTypeName = "Number Spacing";
//		 CTFeatureTypeNameID = "-700";
//		 CTFeatureTypeSelectors =         (
//		 {
//		 CTFeatureSelectorIdentifier = 0;
//		 CTFeatureSelectorName = "Monospaced Numbers";
//		 CTFeatureSelectorNameID = "-701";
//		 },
//		 {
//		 CTFeatureSelectorIdentifier = 1;
//		 CTFeatureSelectorName = "Proportional Numbers";
//		 CTFeatureSelectorNameID = "-702";
//		 },
//		 {
//		 CTFeatureSelectorDefault = 1;
//		 CTFeatureSelectorIdentifier = 4;
//		 CTFeatureSelectorName = "No Change";
//		 CTFeatureSelectorNameID = "-705";
//		 }
//		 );
//		 
//		 {
//		 CTFeatureTypeExclusive = 1;
//		 CTFeatureTypeIdentifier = 21;
//		 CTFeatureTypeName = "Number Case";
//		 CTFeatureTypeNameID = "-2200";
//		 CTFeatureTypeSelectors =         (
//		 {
//		 CTFeatureSelectorIdentifier = 0;
//		 CTFeatureSelectorName = "Old-Style Figures";
//		 CTFeatureSelectorNameID = "-2201";
//		 },
//		 {
//		 CTFeatureSelectorDefault = 1;
//		 CTFeatureSelectorIdentifier = 2;
//		 CTFeatureSelectorName = "No Change";
//		 CTFeatureSelectorNameID = "-2203";
//		 }
//		 );
//		 */
    
	if (fontName && fontSize) {
        NSMutableArray *advancedFeatures = [NSMutableArray array];
        
        NSString *numberSpacing = representation[FontNumberSpacingAttribute];
        if (!numberSpacing) {
            numberSpacing = FontNumberSpacingProportional;
        }
        
        if ([numberSpacing isEqualToString:FontNumberSpacingProportional]) {
            [advancedFeatures addObject:@{
                                          HNEFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                          HNEFontFeatureSelectorIdentifierKey: @(kProportionalNumbersSelector)
                                          }];
        }
        else if ([numberSpacing isEqualToString:FontNumberSpacingMonospaced]) {
            [advancedFeatures addObject:@{
                                          HNEFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                          HNEFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)
                                          }];
        }
        else {
			[NSException raise:NSInvalidArgumentException format:@"Invalid font descriptor attribute value for number spacing: %@", numberSpacing];
        }
        
        NSString *numberStyle = representation[FontNumberStyleAttribute];
        if ([numberStyle isEqualToString:FontNumberStyleOldstyle]) {
            [advancedFeatures addObject:@{
                                          HNEFontFeatureTypeIdentifierKey: @(kNumberCaseType),
                                          HNEFontFeatureSelectorIdentifierKey: @(kLowerCaseNumbersSelector)
                                          }];
        }
        else if ([numberStyle isEqualToString:FontNumberStyleRegular]) {
            [advancedFeatures addObject:@{
                                          HNEFontFeatureTypeIdentifierKey: @(kNumberCaseType),
                                          HNEFontFeatureSelectorIdentifierKey: @(kUpperCaseNumbersSelector)
                                          }];
        }
        else if (numberStyle) {
			[NSException raise:NSInvalidArgumentException format:@"Invalid font descriptor attribute value for number style: %@", numberStyle];
        }
        
        if (advancedFeatures.count) {
            
            HNEFontDescriptor *descriptor = [HNEFontDescriptor fontDescriptorWithName:fontName size:fontSizeFloat];
            
            // If there were any advanced features defined, create the font with the fontdescriptor mechanism. Otherwise, fall through to below simple mechanism.
            HNEFontDescriptor *fontDescriptor = [descriptor fontDescriptorByAddingAttributes: @{ HNEFontFeatureSettingsAttribute: advancedFeatures }];
            HNEFont *describedFont = [HNEFont fontWithDescriptor:fontDescriptor size:fontSizeFloat];
            if (! describedFont) {
                return nil;
            }
            return describedFont;
            
        }
        else {
            // Either we did not need advanced typography, or this version does not support them.
            HNEFont *font = [HNEFont fontWithName:fontName size:fontSizeFloat];
            return font;
        }
    }
	
    return nil;
	
}

- (NSDictionary *)HNEserializedRepresentation
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[@"typeface"] = self.fontName;
	dict[@"size"] = @(self.pointSize);
	
	HNEFontDescriptor *descriptor = self.fontDescriptor;
	NSDictionary *fontAttributes = descriptor.fontAttributes;
	NSArray *fontFeatures = fontAttributes[HNEFontFeatureSettingsAttribute];
    
    for (NSDictionary *feature in fontFeatures) {
        
        if ([feature[HNEFontFeatureTypeIdentifierKey] isEqualToNumber:@(kNumberCaseType)]) {
            if ([feature[HNEFontFeatureSelectorIdentifierKey] isEqualToNumber:@(kLowerCaseNumbersSelector)]) {
                dict[FontNumberStyleAttribute] = FontNumberStyleOldstyle;
            } else if ([feature[HNEFontFeatureSelectorIdentifierKey] isEqualToNumber:@(kUpperCaseNumbersSelector)]) {
                dict[FontNumberStyleAttribute] = FontNumberStyleRegular;
            }
        }
        
        if ([feature[HNEFontFeatureTypeIdentifierKey] isEqualToNumber:@(kNumberSpacingType)]) {
            if ([feature[HNEFontFeatureSelectorIdentifierKey] isEqualToNumber:@(kProportionalNumbersSelector)]) {
                dict[FontNumberSpacingAttribute] = FontNumberSpacingProportional;
            } else if ([feature[HNEFontFeatureSelectorIdentifierKey] isEqualToNumber:@(kMonospacedNumbersSelector)]) {
                dict[FontNumberSpacingAttribute] = FontNumberSpacingMonospaced;
            }
        }        
    }
		
	return dict;
}

@end
