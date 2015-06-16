//
//  HoneTests.m
//  HoneTests
//
//  Created by Jaanus Kase on 18.02.14.
//
//

#import <XCTest/XCTest.h>

#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif

#import "HNEShared.h"



#if TARGET_OS_IPHONE
#define HNETestFont UIFont
#define HNETestColor UIColor
#else
#define HNETestFont NSFont
#define HNETestColor NSColor
#endif



@interface HNEGetterWithBlocksTests : XCTestCase

@end



@implementation HNEGetterWithBlocksTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - Simple initial value setters

- (void)testFloatInitialCallback
{
	__block CGFloat testValue = 3.0;
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindCGFloatIdentifier:@"someFloatIdentifier" defaultValue:5.0 object:self block:^(HNEGetterWithBlocksTests *tests, CGFloat value) {
		testValue = value;
		[expect fulfill];
	}];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(testValue, 5.0, @"Wrong value after initial callback");
	
}

// no API method with options for now
//- (void)testFloatNoInitialCallback
//{
//	__block CGFloat testValue = 3.0;
//	
//	[HNE registerCGFloatParameter:@"someIdentifier" defaultValue:5.0 observer:self options:@{ HNEOptionCallbackOnRegistration: @(NO) } block:^(HoneTests *tests, CGFloat value) {
//								  testValue = value;
//	}];
//	
//	XCTAssertEqual(testValue, 3.0, @"Wrong value after initial callback");
//	
//}

- (void)testNSIntegerInitialCallback
{
	__block NSInteger testValue = 3;
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindNSIntegerIdentifier:@"someIntIdentifier" defaultValue:5 object:self block:^(HNEGetterWithBlocksTests *tests, NSInteger value) {
		testValue = value;
		[expect fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(testValue, 5, @"Wrong value after initial callback");
	
}

- (void)testBOOLInitialCallback
{
	__block BOOL testValue = YES;
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindBOOLIdentifier:@"someBoolIdentifier" defaultValue:NO object:self block:^(HNEGetterWithBlocksTests *tests, BOOL value) {
		testValue = value;
		[expect fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(testValue, NO, @"Wrong value after initial callback");
	
}

- (void)testStringInitialCallback
{
	__block NSString *s = @"tere";
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindNSStringIdentifier:@"someStringIdentifier" defaultValue:@"vana kere" object:self block:^(HNEGetterWithBlocksTests *tests, NSString *value) {
		s = value;
		[expect fulfill];
	}];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualObjects(s, @"vana kere", @"Wrong value after initial callback");
	
}

#if TARGET_OS_IPHONE
- (void)testUIColorInitialCallback
{
	__block HNEColor *c = [HNEColor greenColor];
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
    
	[HNE bindUIColorIdentifier:@"someColorIdentifier" defaultValue:[HNETestColor blueColor] object:self block:^(HNEGetterWithBlocksTests *tests, HNETestColor *value) {
		c = value;
		[expect fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualObjects(c, [HNETestColor blueColor], @"Wrong value after initial callback");
	
}

- (void)testUIFontInitialCallback
{
	__block HNETestFont *f = [HNETestFont systemFontOfSize:12];
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindUIFontIdentifier:@"someFontIdentifier" defaultValue:[HNETestFont systemFontOfSize:13] object:self block:^(HNEGetterWithBlocksTests *tests, HNETestFont *value) {
		f = value;
		[expect fulfill];
	}];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	HNETestFont *expected = [HNETestFont systemFontOfSize:13];
	
	XCTAssertEqualObjects(f.fontName, expected.fontName, @"Wrong font name after initial callback");
	
	XCTAssertEqualWithAccuracy(f.pointSize, expected.pointSize, FLT_EPSILON, @"Wrong font size after initial callback");
	
}
#endif




#pragma mark - Value setters with keypath-like class name

- (void)testKeypathIdentifierSimple
{
	__block NSInteger testValue = 3;
	
	XCTestExpectation *expect = [self expectationWithDescription:@"value changed"];
	
	[HNE bindNSIntegerIdentifier:@"class.someIdentifier" defaultValue:5 object:self block:^(HNEGetterWithBlocksTests *tests, NSInteger value) {
		testValue = value;
		[expect fulfill];
	}];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(testValue, 5, @"Wrong value after initial callback");

}



#pragma mark - Value getter methods

- (void)testCGFloatGetterSimple
{
	[HNE bindCGFloatIdentifier:@"f" defaultValue:3 object:self block:nil];
	CGFloat f = [HNE CGFloatWithHoneIdentifier:@"HNEGetterWithBlocksTests.f"];
	XCTAssertEqualWithAccuracy(f, 3, FLT_EPSILON, @"Bad float value");
}

- (void)testCGFloatGetterKeypath
{
	[HNE bindCGFloatIdentifier:@"hello.f" defaultValue:4 object:self block:nil];
	CGFloat f = [HNE CGFloatWithHoneIdentifier:@"hello.f"];
	XCTAssertEqualWithAccuracy(f, 4, FLT_EPSILON, @"Bad float value");
}

- (void)testCGFloatGetterNonexistentValueException
{
	XCTAssertThrowsSpecificNamed([HNE CGFloatWithHoneIdentifier:@"what.nonexistent"], NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}

- (void)testCGFloatGetterInvalidIdentifierException
{
	XCTAssertThrowsSpecificNamed([HNE CGFloatWithHoneIdentifier:@"what"], NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}



@end
