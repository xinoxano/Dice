//
//  HNEValueMapperTests.m
//  Hone-iosx
//
//  Created by Jaanus Kase on 17/11/14.
//
//

#import <XCTest/XCTest.h>
#import "HNEValueMapper.h"

#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#define HNETestView UIView
#define HNETestColor UIColor
#else
#import <AppKit/AppKit.h>
#define HNETestView NSView
#define HNETestColor NSColor
#endif


@interface HNEValueMapperTests : XCTestCase

@end

@implementation HNEValueMapperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUnmappedValue
{
    NSObject *o = [[NSObject alloc] init];
    BOOL didHandle = [[HNEValueMapper sharedValueMapper] didApplyHoneValue:[HNETestColor colorWithWhite:1 alpha:1] valueIdentifier:@"unmapped" toObject:o];
    XCTAssertFalse(didHandle);
}

- (void)testMappedColor
{
    HNETestView *v = [[HNETestView alloc] init];
#if (!TARGET_OS_IPHONE)
    [v setWantsLayer:YES];
#endif
    BOOL didHandle = [[HNEValueMapper sharedValueMapper] didApplyHoneValue:[HNETestColor colorWithWhite:1 alpha:1] valueIdentifier:@"layer.borderColor" toObject:v];
    XCTAssertTrue(didHandle);
    XCTAssertEqualObjects([HNETestColor colorWithCGColor:v.layer.borderColor], [HNETestColor colorWithWhite:1 alpha:1]);
}


@end
