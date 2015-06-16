//
//  HNEStartingTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 05.07.14.
//
//

#import <XCTest/XCTest.h>
#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif

#import "HNE+Private.h"



/// Test various behaviors when starting Hone.
@interface HNEStartingTests : XCTestCase

@end



@implementation HNEStartingTests

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

- (void)testFailStartingServerInProductionMode
{
	NSError *startError = nil;
    
    HNE *hone = [[HNE alloc] init];
    
	BOOL startResult = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
	XCTAssertTrue(startResult, @"Start error");
	XCTAssertNil(startError, @"Start error");
	
	XCTAssertThrowsSpecificNamed([hone startServer], NSException, NSInternalInconsistencyException, @"Invalid exception");
}

- (void)testMultipleStartAttempts
{
    // should fail with the status code to be set correctly
    
	NSError *startError = nil;
    
    HNE *hone = [[HNE alloc] init];
    
	BOOL startResult = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
	XCTAssertTrue(startResult, @"Start error");
	XCTAssertNil(startError, @"Start error");

	startResult = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
	XCTAssertFalse(startResult, @"Start error");
	XCTAssertEqual(startError.code, HNEErrorCodeInvalidStartRequest, @"Multiple instances start error");
}

- (void)testThatItFailsSwitchingToNotRunning
{
    HNE *hone = [[HNE alloc] init];

    NSError *startError = nil;
    BOOL startResult = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
    XCTAssertTrue(startResult, @"Start error");
    XCTAssertNil(startError, @"Start error");
    
    XCTAssertThrowsSpecificNamed(hone.status = HNELibraryStatusNotStarted, NSException, NSInvalidArgumentException);
}

- (void)testThatItDoesNotSetStatusIfLibraryIsNotStarted
{
    // when trying to set status manually before starting, should fail
    
    HNE *hone = [[HNE alloc] init];
    XCTAssertThrowsSpecificNamed(hone.status = HNELibraryStatusDevelopmentMode, NSException, NSInternalInconsistencyException);
    
}

- (void)testThatItFailsToDownloadFromCloudInProductionMode
{
    HNE *hone = [[HNE alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"correctly failed the cloud download in production mode"];
    
    NSError *startError = nil;
    BOOL startResult = [hone startWithAppIdentifier:@"appId" appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
    XCTAssertTrue(startResult, @"Start error");
    XCTAssertNil(startError, @"Start error");

    [hone updateFromCloudWithCompletionBlock:^(BOOL success, BOOL valuesChanged, NSError *error) {
        XCTAssertFalse(success);
        XCTAssertFalse(valuesChanged);
        XCTAssertEqual(error.code, HNEErrorCodeOperationNotAllowedInProductionMode);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testMissingAppIdInLiveMode
{
	NSError *startError = nil;
    HNE *hone = [[HNE alloc] init];
	BOOL startResult = [hone startWithAppIdentifier:nil appSecret:@"appSecret" documentURL:nil developmentMode:NO error:&startError];
	XCTAssertFalse(startResult, @"Start error");
	XCTAssertEqual(startError.code, HNEErrorCodeInvalidStartParameters, @"Start parameters error");
}

- (void)testMissingAppSecretInDevelopmentMode
{
	NSError *startError = nil;
    HNE *hone = [[HNE alloc] init];
	BOOL startResult = [hone startWithAppIdentifier:@"wat" appSecret:nil documentURL:nil developmentMode:YES error:&startError];
	XCTAssertFalse(startResult, @"Start error");
	XCTAssertEqual(startError.code, HNEErrorCodeInvalidStartParameters, @"Start parameters error");
}

@end
