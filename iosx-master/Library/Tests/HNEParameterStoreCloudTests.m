//
//  HNEParameterStoreCloudTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 13.06.14.
//
//

#import <XCTest/XCTest.h>
#import "OHHTTPStubs.h"
#import "HNE.h"
#import "HNEError.h"



@interface HNEParameterStoreCloudTests : XCTestCase

@end



@implementation HNEParameterStoreCloudTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	[HNE startWithAppIdentifier:@"watIdentifier"
					  appSecret:@"watSecret"
					documentURL:nil
				developmentMode:YES
						  error:nil];
	
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	
	[OHHTTPStubs removeAllStubs];
	
    [super tearDown];
}

- (void)testInvalidCredentials
{
	XCTestExpectation *updateFromCloud = [self expectationWithDescription:@"wait for cloud error"];
	
	[HNE updateFromCloudWithCompletionBlock:^(BOOL success, BOOL updated, NSError *error)
	{
		
		XCTAssertEqual(error.code, HNEErrorCodeCloudNetworkError, @"Cloud error");
		XCTAssertTrue([error.localizedDescription rangeOfString:@"HTTP error 401"].location != NSNotFound, @"Bad message");
		
		[updateFromCloud fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:2 handler:^(NSError *error) {
		NSLog(@"Test error");
	}];
	
}

- (void)testInvalidManifestVersion
{
	
	XCTestExpectation *receivedResponse = [self expectationWithDescription:@"received response"];

	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request)
	{
		return [request.URL.path hasSuffix:@"/manifest"];
	} withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request)
	{
		NSURL *bundleUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"invalidFormatVersion" withExtension:@"hone"];
		NSURL *yamlUrl = [bundleUrl URLByAppendingPathComponent:@"manifest.yaml"];
		
		NSData *yaml = [NSData dataWithContentsOfURL:yamlUrl];
		
		return [OHHTTPStubsResponse responseWithData:yaml statusCode:200 headers:@{@"Content-Type": @"application/octet-stream"}];
	}];
	
	[HNE updateFromCloudWithCompletionBlock:^(BOOL success, BOOL updated, NSError *error)
	 {
		 XCTAssertEqual(error.code, HNEErrorCodeInvalidDocumentFormatVersion, @"Format error");
		 [receivedResponse fulfill];
	 }];
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testThatItPullsThemeWithSpaces
{
    XCTestExpectation *receivedResponse = [self expectationWithDescription:@"received themed values"];
    XCTestExpectation *hitNewThemeResource = [self expectationWithDescription:@"hit “new theme” download"];
    NSURL *bundleUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"exampleSpaces" withExtension:@"hone"];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.absoluteString hasSuffix:@"/manifest"];
    } withStubResponse: ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSURL *yamlUrl = [bundleUrl URLByAppendingPathComponent:@"manifest.yaml"];
        return [OHHTTPStubsResponse responseWithData:[NSData dataWithContentsOfURL:yamlUrl] statusCode:200 headers:@{@"Content-Type": @"application/octet-stream"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.absoluteString hasSuffix:@"/resources/default/values.yaml"];
    } withStubResponse: ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSURL *yamlUrl = [[bundleUrl URLByAppendingPathComponent:@"default"] URLByAppendingPathComponent:@"values.yaml"];
        return [OHHTTPStubsResponse responseWithData:[NSData dataWithContentsOfURL:yamlUrl] statusCode:200 headers:@{@"Content-Type": @"application/octet-stream"}];
    }];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL (NSURLRequest *request) {
        return [request.URL.absoluteString hasSuffix:@"/resources/New%20theme/values.yaml"];
    } withStubResponse: ^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSURL *yamlUrl = [[bundleUrl URLByAppendingPathComponent:@"New theme"] URLByAppendingPathComponent:@"values.yaml"];
        [hitNewThemeResource fulfill];
        return [OHHTTPStubsResponse responseWithData:[NSData dataWithContentsOfURL:yamlUrl] statusCode:200 headers:@{@"Content-Type": @"application/octet-stream"}];
    }];
    
    [HNE updateFromCloudWithCompletionBlock:^(BOOL success, BOOL valuesChanged, NSError *error) {
        XCTAssertTrue(success);
        XCTAssertTrue(valuesChanged);
        XCTAssertNil(error);
        [receivedResponse fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
