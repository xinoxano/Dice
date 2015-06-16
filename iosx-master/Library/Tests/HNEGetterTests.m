//
//  HNEGetterTests.m
//  Hone
//
//  Created by Jaanus Kase on 15.06.14.
//
//

#import <XCTest/XCTest.h>
#import "HNE.h"
#import "HNEFont+HNETypography.h"

#if (TARGET_OS_IPHONE)
#import "UIColor+HNEColorWithArray.h"
#import "HNE+iOS.h"
#else
#import "NSColor+HNEColorWithArray.h"
#endif


@interface HNEGetterTests : XCTestCase

@end



@implementation HNEGetterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	[HNE startWithAppIdentifier:@"appId"
					  appSecret:@"appSecret"
					documentURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"example" withExtension:@"hone"]
				developmentMode:YES
						  error:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - Simple getters

- (void)testGetBOOL
{
	BOOL b = [HNE BOOLWithHoneIdentifier:@"object1.exampleBoolean"];
	XCTAssertEqual(b, YES);
}

- (void)testGetCGFloat
{
	CGFloat f = [HNE CGFloatWithHoneIdentifier:@"object1.exampleFloat"];
	XCTAssertEqualWithAccuracy(f, 2.5, FLT_EPSILON, @"Wrong float");
}

- (void)testGetNSInteger
{
	NSInteger i = [HNE NSIntegerWithHoneIdentifier:@"object1.exampleInt"];
	XCTAssertEqual(i, 4, @"Wrong int");
}

- (void)testGetNSString
{
	NSString *s = [NSString stringWithHoneIdentifier:@"object1.exampleString"];
	XCTAssertEqualObjects(s, @"wat", @"Wrong string");
}

- (void)testGetUIColor
{
	UIColor *c = [UIColor colorWithHoneIdentifier:@"object1.exampleColor"];
	
	UIColor *anotherColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
	XCTAssertEqualObjects(c, anotherColor, @"Wrong color");
	
}

- (void)testGetUIFont
{
	UIFont *font = [UIFont fontWithHoneIdentifier:@"object1.exampleFont"];
	UIFont *anotherFont = [UIFont fontWithName:@"Helvetica" size:12];
	XCTAssertEqualObjects(font.fontName, anotherFont.fontName, @"Wrong font name");
	
	XCTAssertEqualWithAccuracy(font.pointSize, anotherFont.pointSize, FLT_EPSILON, @"Wrong font size");
}

@end
