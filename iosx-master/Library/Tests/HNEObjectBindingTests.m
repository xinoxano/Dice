//
//  HNEObjectBindingTests.m
//  Hone-iosx
//
//  Created by Jaanus Kase on 14/11/14.
//
//

#import <XCTest/XCTest.h>

#if (TARGET_OS_IPHONE)
#import <UIKit/UIKit.h>
#import "HoneIOS.h"
#else
#import <AppKit/AppKit.h>
#import "HoneOSX.h"
#endif

#import "HNEShared.h"
#import "HNE+Private.h"
#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEDocumentObject.h"
#import "HNEDocumentParameter.h"



@interface HNEBindableObject : NSObject

@property (nonatomic, assign) CGFloat f;
@property (nonatomic, assign) BOOL b;
@property (nonatomic, assign) NSInteger i;
@property (nonatomic, strong) HNEFont *font;
@property (nonatomic, strong) HNEColor *c;
@property (nonatomic, strong) NSString *s;
@property (nonatomic, strong) HNEBindableObject *child;

@end



@implementation HNEBindableObject

@end



/// Test the high-level binding interfaces that bind the whole object, without having to map its individual parameters.
@interface HNEObjectBindingTests : XCTestCase

@end



@implementation HNEObjectBindingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    HNE *hone = [HNE sharedHone];
    NSURL *bundledDocumentURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"bindableObjectTests" withExtension:@"hone"];
    if (hone.status == HNELibraryStatusNotStarted) {
        NSError *startError = nil;
        BOOL didStart = [hone startWithAppIdentifier:@"objectBindingAppId" appSecret:@"sikret" documentURL:bundledDocumentURL developmentMode:YES error:&startError];
        XCTAssertNil(startError);
        XCTAssertTrue(didStart);
    }
    
    // Always clear out the parameter store for each test
    NSError *documentLoadError = nil;
    [hone.parameterStore loadHoneDocumentAtURL:bundledDocumentURL forStoreLevel:HNEParameterStoreLevelDocument error:&documentLoadError];
    XCTAssertNil(documentLoadError);
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testThatItBindsAfterObjectCreation {
    HNEBindableObject *object = [[HNEBindableObject alloc] init];
    [object bindToHoneObject:@"myObject"];
    
    XCTAssertEqual(object.f, 3.5);
    XCTAssertEqual(object.i, 42);
    XCTAssertEqual(object.b, YES);
    
    XCTAssertEqualObjects(object.s, @"string");
    XCTAssertEqualObjects(object.font.fontName, @"Helvetica");
    
    XCTAssertEqual(object.font.pointSize, 20);
#if (TARGET_OS_IPHONE)
    XCTAssertEqualObjects(object.c, [HNEColor colorWithRed:0 green:1 blue:0 alpha:1]);
#else
    XCTAssertEqualObjects(object.c, [HNEColor colorWithDeviceRed:0 green:1 blue:0 alpha:1]);
#endif
}

- (void)testThatItSetsChildBindableValue
{
    HNEBindableObject *object = [[HNEBindableObject alloc] init];
    HNEBindableObject *child = [[HNEBindableObject alloc] init];
    
    object.child = child;
    
    [object bindToHoneObject:@"objectWithChild"];
    
    XCTAssertEqualObjects(object.s, @"objectString");
    XCTAssertEqualObjects(object.child.s, @"childString");
}

- (void)testThatItIgnoresBlacklistedParameter
{
    HNEBindableObject *object = [[HNEBindableObject alloc] init];
    NSSet *ignoredValueIdentifiers = [NSSet setWithArray:@[@"ignored"]];
    XCTAssertNoThrowSpecificNamed([object bindToHoneObject:@"ignoredValue" options:@{ HNEIgnoredValueIdentifiers: ignoredValueIdentifiers }], NSException, NSUndefinedKeyException);
    XCTAssertEqualObjects(object.s, @"goodString");

}

- (void)testThatItUsesWhitelistedParameters
{
    // given
    HNEBindableObject *o = [[HNEBindableObject alloc] init];
    o.f = 3.6;
    o.i = 43;
    o.s = @"hello";
    
    // when
    NSSet *whitelist = [NSSet setWithArray:@[@"f", @"s"]];
    [o bindToHoneObject:@"myObject" options:@{HNEOnlyValueIdentifiers: whitelist}];
    
    // then
    XCTAssertEqual(o.f, 3.5);
    XCTAssertEqual(o.i, 43);
    XCTAssertEqualObjects(o.s, @"string");
}

- (void)testThatItAssertsWhenUsingConflictingParameters
{
    NSSet *whitelist = [NSSet setWithArray:@[@"f", @"s"]];
    NSSet *blacklist = [NSSet setWithArray:@[@"i", @"b"]];

    HNEBindableObject *object = [[HNEBindableObject alloc] init];
    
    NSDictionary *options = @{ HNEOnlyValueIdentifiers: whitelist, HNEIgnoredValueIdentifiers: blacklist };
    
    XCTAssertThrowsSpecificNamed([object bindToHoneObject:@"myObject" options:options], NSException, NSInvalidArgumentException, @"Did not throw exception");
    
}

- (void)testThatItAddsDefaultValuesFromBoundObject
{
    // When binding NSObject with the object-binding API, also register the default values
    HNEBindableObject *populator = [[HNEBindableObject alloc] init];
    
    HNEParameterStore *parameterStore = [HNE sharedHone].parameterStore;
    NSPredicate *populatorPredicate = [NSPredicate predicateWithFormat:@"name == %@", @"populatedObject"];
    
    // make sure the object is not there in the store
    NSArray *foundObjects = [parameterStore.documentObjects filteredArrayUsingPredicate:populatorPredicate];
    XCTAssertEqual(foundObjects.count, 0);
    
    // set the object values
    populator.f = 3.5;
    populator.i = 5;
    populator.s = @"hello populator";
    populator.font = [HNEFont fontWithName:@"Helvetica" size:10];
    populator.c = [HNEColor redColor];
    populator.b = YES;
    
    NSDictionary *options = @{ HNEOnlyValueIdentifiers: [NSSet setWithArray:@[ @"f", @"i", @"s", @"font", @"c", @"b" ]] };
    
    [populator bindToHoneObject:@"populatedObject" options:options];
    
    
    // make sure the object is now present in the store
    foundObjects = [parameterStore.documentObjects filteredArrayUsingPredicate:populatorPredicate];
    XCTAssertEqual(foundObjects.count, 1);
    
    HNEDocumentParameter *floatTester = [parameterStore documentParameterForIdentifier:@"f" inClass:@"populatedObject"];
    XCTAssertEqual([floatTester.value floatValue], 3.5);
}

@end
