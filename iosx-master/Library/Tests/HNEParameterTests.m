//
//  HNEParameterTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 17.05.14.
//
//

#import <XCTest/XCTest.h>
#import "HNE.h"
#import "HNE+Private.h"



@interface HNEParameterTests : XCTestCase

@end



@implementation HNEParameterTests

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



#pragma mark - Test block callbacks

- (void)testUpdatedDefaultValue
{
	__block CGFloat f1 = 2;
	__block CGFloat f2 = 3;
	
	__block XCTestExpectation *expect = [self expectationWithDescription:@"default value set"];
    __block XCTestExpectation *expect3 = [self expectationWithDescription:@"default value in first item updated"];
	
	[HNE bindCGFloatIdentifier:@"someValue" defaultValue:2.5 object:self block:^(HNEParameterTests *tests, CGFloat value)
	 {
		 f1 = value;
         if (expect) {
             [expect fulfill];
             expect = nil;
         } else {
             [expect3 fulfill];
             expect3 = nil;
         }
	 }];

	XCTAssertEqualWithAccuracy(f1, 2.5, FLT_EPSILON, @"Bad value after initial registration");
	
	__block XCTestExpectation *expect2 = [self expectationWithDescription:@"default value updated"];
	
	[HNE bindCGFloatIdentifier:@"someValue" defaultValue:3.5 object:self block:^(HNEParameterTests *tests, CGFloat value)
	{
		f2 = value;
		[expect2 fulfill];
		expect2 = nil;
	}];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualWithAccuracy(f2, 3.5, FLT_EPSILON, @"Bad value after second registration");
	XCTAssertEqualWithAccuracy(f1, 3.5, FLT_EPSILON, @"Bad updated value after second registration");
}

- (void)testUpdatedDefaultValueWithClassIdentifier
{
	__block CGFloat f1 = 2;
	__block CGFloat f2 = 3;
	
	__block XCTestExpectation *expect = [self expectationWithDescription:@"initial value"];
    __block XCTestExpectation *expect3 = [self expectationWithDescription:@"initial value updated"];
	
	[HNE bindCGFloatIdentifier:@"someObject.someValue" defaultValue:2.5 object:self block:^(HNEParameterTests *tests, CGFloat value)
	 {
		 f1 = value;
         if (expect) {
             [expect fulfill];
             expect = nil;
         } else {
             [expect3 fulfill];
             expect3 = nil;
         }
	 }];
	
	XCTAssertEqualWithAccuracy(f1, 2.5, FLT_EPSILON, @"Bad value after initial registration");

	__block XCTestExpectation *expect2 = [self expectationWithDescription:@"updated value"];
	
	[HNE bindCGFloatIdentifier:@"someObject.someValue" defaultValue:3.5 object:self block:^(HNEParameterTests *tests, CGFloat value)
	 {
		 f2 = value;
		 [expect2 fulfill];
		 expect2 = nil;
	 }];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualWithAccuracy(f2, 3.5, FLT_EPSILON, @"Bad value after second registration");
	XCTAssertEqualWithAccuracy(f1, 3.5, FLT_EPSILON, @"Bad updated value after second registration");
}



#pragma mark - Identifier parser

- (void)testIdentifierParserOnlyIdentifier
{
	NSString *identifier = @"hello";
	NSDictionary *parsed = [identifier parsedIdentifier];
	XCTAssertNil(parsed[IDENTIFIER_CLASS_NAME], @"Class is not nil");
	XCTAssertEqualObjects(parsed[IDENTIFIER_PARAMETER_NAME], @"hello", @"Wrong parameter name");
}

- (void)testIdentifierParserIdentifierAndClass
{
	NSString *identifier = @"hello.world";
	NSDictionary *parsed = [identifier parsedIdentifier];
	XCTAssertEqualObjects(parsed[IDENTIFIER_CLASS_NAME], @"hello", @"Wrong class name");
	XCTAssertEqualObjects(parsed[IDENTIFIER_PARAMETER_NAME], @"world", @"Wrong parameter name");
}

- (void)testIdentifierParserIdentifierWithKeypath
{
	NSString *identifier = @"another.hello.world";
    NSDictionary *parsed = [identifier parsedIdentifier];
    
    XCTAssertEqualObjects(parsed[IDENTIFIER_CLASS_NAME], @"another", @"Wrong class name");
    XCTAssertEqualObjects(parsed[IDENTIFIER_PARAMETER_NAME], @"hello.world", @"Wrong parameter name");

}



@end
