/***********************************************************************************
 *
 * Copyright (c) 2012 Olivier Halligon
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 ***********************************************************************************/

#import <XCTest/XCTest.h>
#import "OHHTTPStubs.h"

static const NSTimeInterval kResponseTimeTolerence = 0.3;

@interface NilValuesTests : XCTestCase @end

@implementation NilValuesTests

-(void)setUp
{
    [super setUp];
    [OHHTTPStubs removeAllStubs];
}

- (void)test_NilData
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:nil statusCode:400 headers:nil];
    }];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Network request's completionHandler called"];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.iana.org/domains/example/"]];
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error)
     {
         XCTAssertEqual(data.length, (NSUInteger)0, @"Data should be empty");
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:kResponseTimeTolerence handler:nil];
}

- (void)test_InvalidPath
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:@"-invalid-path-" statusCode:500 headers:nil];
    }];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Network request's completionHandler called"];
    
    NSURLRequest* req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.iana.org/domains/example/"]];
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error)
     {
         XCTAssertEqual(data.length, (NSUInteger)0, @"Data should be empty");
         
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:kResponseTimeTolerence handler:nil];
}

- (void)_test_NilURLAndCookieHandlingEnabled:(BOOL)handleCookiesEnabled
{
    NSData* expectedResponse = [NSStringFromSelector(_cmd) dataUsingEncoding:NSUTF8StringEncoding];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return YES;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithData:expectedResponse
                                          statusCode:200
                                             headers:nil];
    }];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"Network request's completionHandler called"];
    
    NSMutableURLRequest* req = [NSMutableURLRequest requestWithURL:nil];
    [req setHTTPShouldHandleCookies:handleCookiesEnabled];
    
    __block NSData* response = nil;
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* resp, NSData* data, NSError* error)
     {
         response = data;
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:kResponseTimeTolerence handler:nil];
    
    XCTAssertEqualObjects(response, expectedResponse, @"Unexpected data received");
}

- (void)test_NilURLAndCookieHandlingEnabled
{
    [self _test_NilURLAndCookieHandlingEnabled:YES];
}

- (void)test_NilURLAndCookieHandlingDisabled
{
    [self _test_NilURLAndCookieHandlingEnabled:NO];
}

@end
