//
//  HNEGetterWithDefaultsTests.m
//  Hone
//
//  Created by Jaanus Kase on 15.06.14.
//
//

#import <XCTest/XCTest.h>

#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif

#import "HNEShared.h"



@interface HNEGetterWithDefaultsTests : XCTestCase

@property (nonatomic, assign) CGFloat f;
@property (nonatomic, assign) NSInteger i;
@property (nonatomic, strong) HNEColor *c;
@property (nonatomic, strong) NSString *s;
@property (nonatomic, strong) HNEFont *font;

@end



@implementation HNEGetterWithDefaultsTests

- (void)setUp
{
    [super setUp];
	
	[HNE startWithAppIdentifier:nil
					  appSecret:nil
					documentURL:nil
				developmentMode:YES
						  error:nil];
	
	self.f = 1.0;
	self.i = 2;
	self.c = [HNEColor redColor];
	self.s = @"Hello";
	self.font = [HNEFont fontWithName:@"Helvetica" size:12];
	
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetBoolWithDefaultValue
{
	BOOL b = [HNE BOOLWithHoneIdentifier:@"testObject.bool" defaultValue:YES];
	XCTAssertEqual(b, YES);
}

- (void)testGetCGFloatWithDefaultValue
{
	CGFloat f = [HNE CGFloatWithHoneIdentifier:@"testObject.float" defaultValue:2.0];
	XCTAssertEqualWithAccuracy(f, 2.0, FLT_EPSILON, @"Bad float");
}

- (void)testGetNSIntegerWithDefaultValue
{
	NSInteger i = [HNE NSIntegerWithHoneIdentifier:@"testObject.int" defaultValue:3];
	XCTAssertEqual(i, 3, @"Bad int");
}

- (void)testGetNSStringWithDefaultValue
{
	NSString *s = [NSString stringWithHoneIdentifier:@"testObject.string" defaultValue:@"Hello world"];
	XCTAssertEqualObjects(s, @"Hello world", @"Bad string");
}

- (void)testGetUIFontWithDefaultValue
{
	HNEFont *f = [HNEFont fontWithHoneIdentifier:@"testObject.font" defaultValue:[HNEFont fontWithName:@"Georgia" size:16]];
	
	XCTAssertEqualObjects(f.fontName, @"Georgia", @"Bad font name");
	XCTAssertEqualWithAccuracy(f.pointSize, 16, FLT_EPSILON, @"Bad font size");
	
//	XCTAssertEqualObjects(f, [UIFont fontWithName:@"Georgia" size:16], @"Bad font");
}

- (void)testGetUIColorWithDefaultValue
{
	HNEColor *c = [HNEColor colorWithHoneIdentifier:@"testObject.color" defaultValue:[HNEColor colorWithRed:0 green:1 blue:0 alpha:1]];
	XCTAssertEqualObjects(c, [HNEColor greenColor], @"Bad color");
}



#pragma mark - Test that callbacks aren’t run multiple times for the same parameter value

- (void)testGetNSIntegerWithRedundantCallbacks
{
	// each callback should only be run once, since the registered value is the same

	XCTestExpectation *callback1 = [self expectationWithDescription:@"first callback run"];
	XCTestExpectation *callback2 = [self expectationWithDescription:@"second callback run"];
	
	__block NSInteger callbackRunCount = 0;
	[HNE bindNSIntegerIdentifier:@"testObject.redundantInt" defaultValue:42 object:self block:^(HNEGetterWithDefaultsTests *getter, NSInteger newValue)
	 {
		 callbackRunCount++;
		 [callback1 fulfill];
	 }];
	
	[HNE bindNSIntegerIdentifier:@"testObject.redundantInt" defaultValue:42 object:self block:^(HNEGetterWithDefaultsTests *getter, NSInteger newValue)
	 {
		 callbackRunCount++;
		 [callback2 fulfill];
	 }];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(callbackRunCount, 2, @"Bad callback run count");
}



@end
