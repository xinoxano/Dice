//
//  HNEWatchingTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 14.07.14.
//
//

#import <XCTest/XCTest.h>
#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif
#import "HNE+Private.h"



@interface HNEWatchingTests : XCTestCase

@property (assign, nonatomic) NSInteger testInt;

@property (strong, nonatomic) HNE *hone;

@end



@implementation HNEWatchingTests

- (void)setUp
{
    [super setUp];
	self.hone = [[HNE alloc] init];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWatchIntChangeWithKeypathBindingFullWatchPath
{
	// async test code keeps failing when run together with other tests
//	XCTFail(@"Not implemented");
	
	XCTestExpectation *expect = [self expectationWithDescription:@"watched int value changed"];
	
	self.testInt = 5;
	
	__block NSInteger myInt = 3;
	__block NSArray *changed = nil;
	[self.hone watchIdentifiers:@[@"test.testInt"] object:self block:^(HNEWatchingTests *tests, NSArray *changedIdentifiers)
	{
		changed = changedIdentifiers;
		myInt = self.testInt;
		[expect fulfill];
	}];
	
	[self.hone bindNSIntegerIdentifier:@"test.testInt" object:self keyPath:@"testInt"];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualObjects(changed, @[@"test.testInt"], @"Wrong list of changed objects");
	XCTAssertEqual(myInt, 5, @"Bad integer value");
	
}

- (void)testWatchIntChangeWithKeypathBindingMultipleWatchPaths
{
	__block XCTestExpectation *expect = [self expectationWithDescription:@"watched values changed"];
	
	self.testInt = 5;
	
	__block NSInteger myInt = 3;
	__block NSArray *changed = nil;
	[self.hone watchIdentifiers:@[@"anotherTest.someOtherInt", @"multiTest.testInt"] object:self block:^(HNEWatchingTests *tests, NSArray *changedIdentifiers)
	 {
		 changed = changedIdentifiers;
		 myInt = self.testInt;
		 [expect fulfill];
	 }];
	
	[self.hone bindNSIntegerIdentifier:@"multiTest.testInt" object:self keyPath:@"testInt"];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualObjects(changed, @[@"multiTest.testInt"], @"Wrong list of changed objects");
	XCTAssertEqual(myInt, 5, @"Bad integer value");
	
}

- (void)testWatchIntChangeWithKeypathBindingClassWatchPath
{
	XCTestExpectation *expect = [self expectationWithDescription:@"watched identifiers changed"];
	
	self.testInt = 5;
	
	__block NSInteger myInt = 3;
	__block NSArray *changed = nil;
	[self.hone watchIdentifiers:@[@"test2"] object:self block:^(HNEWatchingTests *tests, NSArray *changedIdentifiers)
	 {
		 changed = changedIdentifiers;
		 myInt = self.testInt;
		 [expect fulfill];
	 }];
	
	[self.hone bindNSIntegerIdentifier:@"test2.testInt" object:self keyPath:@"testInt"];

	[self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {}];
	
	XCTAssertEqualObjects(changed, @[@"test2.testInt"], @"Wrong list of changed objects");
	XCTAssertEqual(myInt, 5, @"Bad integer value");
	
}

- (void)testWatchIntChangeWithKeypathBindingEmptyWatchPath
{
	XCTestExpectation *expect = [self expectationWithDescription:@"empty watch patch changed"];
	
	self.testInt = 5;
	
	__block NSInteger myInt = 3;
	__block NSArray *changed = nil;
	[self.hone watchIdentifiers:nil object:self block:^(HNEWatchingTests *tests, NSArray *changedIdentifiers)
	 {
		 changed = changedIdentifiers;
		 myInt = self.testInt;
		 [expect fulfill];
	 }];
	
	[self.hone bindNSIntegerIdentifier:@"test3.testInt" object:self keyPath:@"testInt"];

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqualObjects(changed, @[@"test3.testInt"], @"Wrong list of changed objects");
	XCTAssertEqual(myInt, 5, @"Bad integer value");
	
}



- (void)testWatchIntChangeWithBlockBinding
{
	XCTestExpectation *valueExpectation = [self expectationWithDescription:@"value changed"];
	XCTestExpectation *valuePostExpectation = [self expectationWithDescription:@"new value posted"];
	
	__block NSInteger myInt = 3;
	[self.hone watchIdentifiers:@[@"blockTest.testInt"] object:self block:^(HNEWatchingTests *tests, NSArray *changedIdentifiers)
	 {
		 myInt = [self.hone NSIntegerWithHoneIdentifier:@"blockTest.testInt"];
		 
		 XCTAssertEqualObjects(changedIdentifiers, @[@"blockTest.testInt"], @"Wrong list of changed objects");
		 XCTAssertEqual(myInt, 6, @"Bad integer value");
		 
		 [valueExpectation fulfill];
	 }];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.hone bindNSIntegerIdentifier:@"blockTest.testInt" defaultValue:6 object:self block:^(HNEWatchingTests *tests, NSInteger value)
		 {
			 [valuePostExpectation fulfill];
		 }];
	});

	[self waitForExpectationsWithTimeout:2 handler:nil];

}

@end
