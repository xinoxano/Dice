//
//  HNEDiskDocumentTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 20.05.14.
//
//

#import <XCTest/XCTest.h>
#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif
#import "HNE+Private.h"
#import "HNEShared.h"



@interface HNEDiskDocumentTests : XCTestCase

@property (strong) HNE *hone;

@end



@implementation HNEDiskDocumentTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
    self.hone = [[HNE alloc] init];
    
	[self.hone startWithAppIdentifier:@"diskDocTests" appSecret:@"appSecret" documentURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"example" withExtension:@"hone"] developmentMode:YES error:nil];

	[self.hone activateThemes:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSimpleIntValueLoad
{
	NSInteger i = [self.hone NSIntegerWithHoneIdentifier:@"object1.exampleInt"];
	XCTAssertEqual(i, 4, @"Integer is not what’s expected");
}

- (void)testStringWithColonValueLoad
{
	NSString *s = [self.hone NSStringWithHoneIdentifier:@"object1.helloWorld"];
	XCTAssertEqualObjects(s, @"Hello world:");
}

- (void)testThemedIntValueLoad
{
	NSInteger i = [self.hone NSIntegerWithHoneIdentifier:@"object2.anotherInt"];
	XCTAssertEqual(i, 4, @"Integer is not what’s expected");

	[self.hone activateThemes:@[@"newTheme"]];
	i = [self.hone NSIntegerWithHoneIdentifier:@"object2.anotherInt"];
	XCTAssertEqual(i, 42, @"Themed integer is not what’s expected");
}

- (void)testBadThemeActivation
{
	XCTAssertThrowsSpecificNamed([self.hone activateThemes:@[@"nonexistentTheme"]], NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}

- (void)testThemedStringCallback
{
	
	__block XCTestExpectation *expect = [self expectationWithDescription:@"value was set"];
	
	__block NSString *s = @"karu";
	[self.hone bindNSStringIdentifier:@"object1.exampleString" defaultValue:@"misse" object:self block:^(HNEDiskDocumentTests *tests, NSString *uus) {
		s = [uus copy];
		
		if ([s isEqualToString:@"anotherWat"]) {
			[expect fulfill];
		}
	}];
	
	[self.hone activateThemes:@[@"newTheme"]];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];

	XCTAssertEqualObjects(s, @"anotherWat", @"Bad string value");
}

- (void)testWrongDocumentUrlType
{
	// Should not load Internet URL-s
	NSURL *internetUrl = [NSURL URLWithString:@"http://www.google.com/"];
	
	NSError *e = nil;
    
    HNE *hone = [[HNE alloc] init];
    
	BOOL success = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:internetUrl developmentMode:YES error:&e];
	XCTAssertFalse(success, @"Bad result");
	XCTAssertEqual(e.code, HNEErrorCodeDocumentMustBeFileURL, @"Bad error code");
}

//- (void)testProxyBenchmark
//{
//	// Test proxy for benchmarking stuff
//	
//	uint64_t ns = dispatch_benchmark(100, ^{
//		
//		// load document
//		[HNE loadHoneDocumentAtURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"example" withExtension:@"hone"] error:nil];
//		
//		// load simple value
//		NSInteger i = [HNE NSIntegerWithHoneIdentifier:@"object2.anotherInt"];
//		[HNE activateThemes:@[@"newTheme"]];
//		i = [HNE NSIntegerWithHoneIdentifier:@"object2.anotherInt"];
//		
//	});
//	NSLog(@"One execution took %llu ms (%llu ns)", ns / 1000000, ns);
//	
//	XCTAssertTrue(YES, @"Success");
//}

@end
