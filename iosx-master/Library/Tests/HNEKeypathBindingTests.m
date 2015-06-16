//
//  HNEKeypathBindingTests.m
//  Hone
//
//  Created by Jaanus Kase on 02.06.14.
//
//

#import <XCTest/XCTest.h>

#if TARGET_OS_IPHONE
#import "HoneIOS.h"
#define HNETestBindColorIdentifier bindUIColorIdentifier
#define HNETestBindFontIdentifier bindUIFontIdentifier
#else
#import "HoneOSX.h"
#define HNETestBindColorIdentifier bindNSColorIdentifier
#define HNETestBindFontIdentifier bindNSFontIdentifier
#endif

#import "HNEShared.h"
#import "HNE+Private.h"
#import "HNEParameterStore.h"
#import "HNEDocumentParameter.h"



@interface HNEKeypathBindingTests : XCTestCase

@property (assign) CGFloat f;
@property (assign) NSInteger i;
@property (strong) NSString *s;
@property (strong) HNEColor *c;
@property (strong) HNEFont *font;
@property (assign) BOOL b;

@end



@implementation HNEKeypathBindingTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.c = [HNEColor colorWithRed:0 green:0 blue:1 alpha:1];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



#pragma mark - Simple binding tests

- (void)testBindBOOL
{
	self.b = YES;
	[HNE bindBOOLIdentifier:@"testBool" object:self keyPath:@"b"];
	XCTAssertEqual(self.b, YES);
}

- (void)testBindCGFloat
{
	self.f = 3;
	[HNE bindCGFloatIdentifier:@"test" object:self keyPath:@"f"];
	XCTAssertEqualWithAccuracy(self.f, 3, FLT_EPSILON, @"Float binding");
}

- (void)testBindNSInteger
{
	self.i = 3;
	[HNE bindNSIntegerIdentifier:@"test" object:self keyPath:@"i"];
	XCTAssertEqual(self.i, 3, @"Int binding");
}

- (void)testBindUIColor
{
	self.c = [HNEColor greenColor];
	[HNE HNETestBindColorIdentifier:@"color" object:self keyPath:@"c"];
	XCTAssertEqualObjects(self.c, [HNEColor greenColor], @"Wrong color");
}

- (void)testBindUIFont
{
	self.font = [HNEFont systemFontOfSize:14];
	[HNE HNETestBindFontIdentifier:@"font" object:self keyPath:@"font"];
	XCTAssertEqualObjects(self.font.fontName, @".HelveticaNeueInterface-Regular", @"Bad font name");
    XCTAssertEqual(self.font.pointSize, 14, @"Bad font size");
}

- (void)testBindNSString
{
	self.s = @"string";
	[HNE bindNSStringIdentifier:@"s" object:self keyPath:@"s"];
	XCTAssertEqualObjects(self.s, @"string", @"Bad string");
}



#pragma mark - Tests for binding that immediately changes the value

- (void)testThatItChangesColorValueAtBinding
{
    HNEDocumentParameter *colorParameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"testColor~color": @[@(1), @(0), @(0), @(1)]}];
    [[HNE sharedHone].parameterStore setParameter:colorParameter
                                    inClass:@"testObject"
                                      theme:nil
                                 storeLevel:HNEParameterStoreLevelBonjour];
    [HNE HNETestBindColorIdentifier:@"testObject.testColor" object:self keyPath:@"c"];
    XCTAssertEqualObjects(self.c, [HNEColor colorWithRed:1 green:0 blue:0 alpha:1], @"Wrong color");
}


@end
