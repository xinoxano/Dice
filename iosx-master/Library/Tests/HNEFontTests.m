//
//  HNEFontTests.m
//  Hone
//
//  Created by Jaanus Kase on 03.10.14.
//
//


#import "HNE.h"
#import <XCTest/XCTest.h>
#import "HNEFont+HNETypography.h"
#import "HNEShared.h"
#import <CoreText/CoreText.h>



@interface HNEFontTests : XCTestCase

@end



@implementation HNEFontTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
#warning replace with a free otf font.
    // Load the custom font
    NSURL *fontUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"ChoplinLight" withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:fontUrl];
    CFErrorRef error;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
    CGFontRef font = CGFontCreateWithDataProvider(provider);
    if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
        CFStringRef errorDescription = CFErrorCopyDescription(error);
        NSLog(@"Failed to load font: %@", errorDescription);
        CFRelease(errorDescription);
    }
    CFRelease(font);
    CFRelease(provider);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - Get font from description

- (void)testThatItCreatesBasicFont {
    // This is an example of a functional test case.
    
    NSDictionary *fontDict = @{ @"typeface": @"HelveticaNeue", @"size": @(14) };
    
    UIFont *font = [UIFont fontWithHNESerializedRepresentation:fontDict];
    
    XCTAssertEqualObjects(font.fontName, @"HelveticaNeue");
    XCTAssertEqual(font.pointSize, 14);
}

- (void)testThatItCreatesCustomFont {
    NSDictionary *fontDict = @{ @"typeface": @"Choplin-Light", @"size": @(14) };
    
    UIFont *font = [UIFont fontWithHNESerializedRepresentation:fontDict];
    
    XCTAssertEqualObjects(font.fontName, @"Choplin-Light");
    XCTAssertEqual(font.pointSize, 14);
}

- (void)testThatItCreatesCustomFontWithOldstyleNumbers {
    NSDictionary *fontDict = @{ @"typeface": @"Choplin-Light", @"size": @(14), @"number_style": @"oldstyle" };
    
    UIFont *font = [UIFont fontWithHNESerializedRepresentation:fontDict];
    UIFontDescriptor *descriptor = font.fontDescriptor;
    
    NSDictionary *expectedDict = @{
                                   HNEFontFeatureTypeIdentifierKey: @(kNumberCaseType),
                                   HNEFontFeatureSelectorIdentifierKey: @(kLowerCaseNumbersSelector)
                                   };
    
    XCTAssertEqualObjects(font.fontName, @"Choplin-Light");
    XCTAssertEqual(font.pointSize, 14);
    XCTAssertTrue([descriptor.fontAttributes[HNEFontFeatureSettingsAttribute] containsObject:expectedDict]);
}

- (void)testThatItCreatesCustomFontWithMonospacedNumbers {

    NSDictionary *fontDict = @{ @"typeface": @"Choplin-Light", @"size": @(14), @"number_spacing": @"monospaced" };
    
    UIFont *font = [UIFont fontWithHNESerializedRepresentation:fontDict];
    UIFontDescriptor *descriptor = font.fontDescriptor;
    
    NSDictionary *expectedDict = @{
                                   HNEFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                   HNEFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)
                                   };
    
    XCTAssertEqualObjects(font.fontName, @"Choplin-Light");
    XCTAssertEqual(font.pointSize, 14);
    XCTAssertTrue([descriptor.fontAttributes[HNEFontFeatureSettingsAttribute] containsObject:expectedDict]);
    
}



#pragma mark - Get description from font

- (void)testThatItDescribesRegularFont
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    NSDictionary *fontDictionary = [font HNEserializedRepresentation];
    NSDictionary *expectedDictionary = @{@"typeface":@"HelveticaNeue", @"size": @(14)};
    XCTAssertEqualObjects(fontDictionary, expectedDictionary);
}

- (void)testThatItDescribesCustomFont
{
    UIFont *font = [UIFont fontWithName:@"Choplin-Light" size:14];
    NSDictionary *fontDictionary = [font HNEserializedRepresentation];
    NSDictionary *expectedDictionary = @{@"typeface":@"Choplin-Light", @"size": @(14)};
    XCTAssertEqualObjects(fontDictionary, expectedDictionary);
}

- (void)testThatItDescribesCustomFontWithOldstyleNumbers
{
    HNEFontDescriptor *descriptor = [HNEFontDescriptor fontDescriptorWithName:@"Choplin-Light" size:14];
    descriptor = [descriptor fontDescriptorByAddingAttributes:@{HNEFontFeatureSettingsAttribute: @[@{
                                                                        HNEFontFeatureTypeIdentifierKey: @(kNumberCaseType),
                                                                        HNEFontFeatureSelectorIdentifierKey: @(kLowerCaseNumbersSelector)
                                                                        }]}];
    
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:14];
    NSDictionary *fontDictionary = [font HNEserializedRepresentation];
    NSDictionary *expectedDictionary = @{@"typeface":@"Choplin-Light", @"size": @(14), @"number_style": @"oldstyle"};
    XCTAssertEqualObjects(fontDictionary, expectedDictionary);
}

- (void)testThatItDescribesCustomFontWithMonospacedNumbers
{
    HNEFontDescriptor *descriptor = [HNEFontDescriptor fontDescriptorWithName:@"Choplin-Light" size:14];
    descriptor = [descriptor fontDescriptorByAddingAttributes:@{HNEFontFeatureSettingsAttribute: @[@{
                                                                                                       HNEFontFeatureTypeIdentifierKey: @(kNumberSpacingType),
                                                                                                       HNEFontFeatureSelectorIdentifierKey: @(kMonospacedNumbersSelector)
                                                                                                       }]}];
    
    UIFont *font = [UIFont fontWithDescriptor:descriptor size:14];
    NSDictionary *fontDictionary = [font HNEserializedRepresentation];
    NSDictionary *expectedDictionary = @{@"typeface":@"Choplin-Light", @"size": @(14), @"number_spacing": @"monospaced"};
    XCTAssertEqualObjects(fontDictionary, expectedDictionary);
}




@end
