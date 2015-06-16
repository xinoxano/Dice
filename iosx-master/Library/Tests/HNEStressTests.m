//
//  HNEStressTests.m
//  Hone
//
//  Created by Jaanus Kase on 05.09.14.
//
//

#import <XCTest/XCTest.h>
#if (TARGET_OS_IPHONE)
#import "HoneIOS.h"
#else
#import "HoneOSX.h"
#endif
#import "HNE+Private.h"
#import "HNEParameterStore.h"
#import "HNEDocumentParameter.h"



@interface HNEStressTests : XCTestCase

@property (nonatomic, assign) NSInteger intWatcher;
@property (nonatomic, strong) XCTestExpectation *stringKeypathExpectation;
@property (nonatomic, strong) XCTestExpectation *integerKeypathExpectation;
@property (nonatomic, assign) BOOL integerExpectationFulfilled;

@end



@interface HNETestObject : NSObject

- (instancetype)initWithTestClass:(HNEStressTests *)testClass;

@property (nonatomic, assign) NSInteger integer;
@property (nonatomic, copy) NSString *string;
@property (nonatomic, weak) HNEStressTests *testClass;

@end

@implementation HNETestObject

- (instancetype)initWithTestClass:(HNEStressTests *)testClass {
    if (self = [super init]) {
        _testClass = testClass;
    }
    return self;
}

- (void)setString:(NSString *)string {
    if (![_string isEqualToString:string]) {
        _string = string;
        if ([_string isEqualToString:@"str999"]) {
            [_testClass.stringKeypathExpectation fulfill];
        }
    }
}

- (void)setInteger:(NSInteger)integer {
    if (integer != _integer) {
        _integer = integer;
        if (_integer == 999) {
            if (!_testClass.integerExpectationFulfilled) {
                _testClass.integerExpectationFulfilled = YES;
                [_testClass.integerKeypathExpectation fulfill];
            }
        }
    }
}

@end



@implementation HNEStressTests

- (void)setUp {
    [super setUp];
    self.integerExpectationFulfilled = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testManyIntegerBlockAssignments
{
    HNE *hone = [[HNE alloc] init];
    [hone startWithAppIdentifier:@"stressTestApp" appSecret:@"testSecret" documentURL:nil developmentMode:YES error:nil];
    
	__block NSInteger watcher = 0;
	XCTestExpectation *expect = [self expectationWithDescription:@"got called back with the correct values"];
	
	for (NSInteger i = 0; i < 1000; i++) {
		NSString *identifier = [NSString stringWithFormat:@"class.int%ld", (long)i];
		[hone bindNSIntegerIdentifier:identifier defaultValue:i object:self block:^(HNEStressTests *tests, NSInteger value) {
			watcher = value;
			if (watcher == 999) {
				[expect fulfill];
			}
			
		}];
	}
	
	[self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testManyIntegerKeypathAssignments
{
    
    HNE *hone = [[HNE alloc] init];
    NSError *startError = nil;
    BOOL started = [hone startWithAppIdentifier:@"stressTestApp2" appSecret:@"testSecret" documentURL:nil developmentMode:YES error:nil];
    XCTAssertTrue(started);
    XCTAssertNil(startError);

    HNETestObject *object = [[HNETestObject alloc] initWithTestClass:self];
    object.integer = -2;
    
    self.integerKeypathExpectation = [self expectationWithDescription:@"Did set integer"];
    
    [hone bindNSIntegerIdentifier:@"test.integer" object:object keyPath:@"integer"];

    for (NSInteger i = 0; i < 1000; i++) {
        
        HNEDocumentParameter *parameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"integer~int": @(i)}];
        [hone.parameterStore setParameter:parameter inClass:@"test" theme:@"" storeLevel:HNEParameterStoreLevelBonjour];
    }

    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(object.integer, 999);
    
}

- (void)testManyStringKeypathAssignments
{
    HNE *hone = [[HNE alloc] init];
    NSError *startError = nil;
    BOOL started = [hone startWithAppIdentifier:@"stressTestApp3" appSecret:@"testSecret" documentURL:nil developmentMode:YES error:nil];
    XCTAssertTrue(started);
    XCTAssertNil(startError);
    
    HNETestObject *object = [[HNETestObject alloc] initWithTestClass:self];
    object.string = @"-1";
    
    [hone bindNSStringIdentifier:@"test.str" object:object keyPath:@"string"];

    self.stringKeypathExpectation = [self expectationWithDescription:@"Did set string"];

    for (NSInteger i = 0; i < 1000; i++) {
        HNEDocumentParameter *parameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"str~string": [NSString stringWithFormat:@"str%ld", (long)i]}];
        [hone.parameterStore setParameter:parameter inClass:@"test" theme:@"" storeLevel:HNEParameterStoreLevelBonjour];
    }
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqualObjects(object.string, @"str999");
}

- (void)testManyObjectsListeningToTheSameKeypath
{
    HNE *hone = [[HNE alloc] init];
    NSError *startError = nil;
    BOOL started = [hone startWithAppIdentifier:@"stressTestAppManyObjectsSameKeypath" appSecret:@"testSecret" documentURL:nil developmentMode:YES error:nil];
    XCTAssertTrue(started);
    XCTAssertNil(startError);
    
    HNETestObject *lastObject = nil;
    
    self.integerKeypathExpectation = [self expectationWithDescription:@"integer set"];
    
    for (NSInteger i = 0; i < 1000; i++) {
        HNETestObject *o = [[HNETestObject alloc] initWithTestClass:self];
        lastObject = o;
        [hone bindNSIntegerIdentifier:@"test.manyInts" object:o keyPath:@"integer"];
        HNEDocumentParameter *parameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"manyInts~int": @(i)}];
        [hone.parameterStore setParameter:parameter inClass:@"test" theme:nil storeLevel:HNEParameterStoreLevelBonjour];
    }
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertEqual(lastObject.integer, 999);
}

- (void)testManyObjectsListeningToManyKeypaths
{
    HNE *hone = [[HNE alloc] init];
    NSError *startError = nil;
    BOOL started = [hone startWithAppIdentifier:@"stressTestAppManyObjectsManyKeypaths" appSecret:@"testSecret" documentURL:nil developmentMode:YES error:nil];
    XCTAssertTrue(started);
    XCTAssertNil(startError);
    
    self.stringKeypathExpectation = [self expectationWithDescription:@"Did set string"];
    
    HNETestObject *lastObject = nil;
    
    for (NSInteger i = 0; i < 1000; i++) {
        
        HNETestObject *object = [[HNETestObject alloc] initWithTestClass:self];
        lastObject = object;
        object.string = @"-1";
        
        NSString *objectIdentifier = [NSString stringWithFormat:@"test.str%ld", (long)i];

        [hone bindNSStringIdentifier:objectIdentifier object:object keyPath:@"string"];
        
        [hone watchIdentifiers:@[ objectIdentifier ] object:self block:^(HNEStressTests *tests, NSArray *changed) {}];
        
        HNEDocumentParameter *parameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{[NSString stringWithFormat:@"str%ld~string", (long)i]: [NSString stringWithFormat:@"str%ld", (long)i]}];
        [hone.parameterStore setParameter:parameter inClass:@"test" theme:@"" storeLevel:HNEParameterStoreLevelBonjour];
    }
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqualObjects(lastObject.string, @"str999");
}

//- (void)testMany

//- (void)testManyIntegerAssignmentsWithSameIdentifier
//{
//    __block NSInteger watcher = 0;
//    self.intWatcher = 3;
//    XCTestExpectation *expect = [self expectationWithDescription:@"tests done"];
//    
//    for (NSInteger i = 0; i < 1000; i++) {
//        NSString *identifier = @"class.int";
//        [HNE bindNSIntegerIdentifier:identifier defaultValue:i object:self block:^(HNEStressTests *tests, NSInteger value) {
//            watcher = value;
//            if (watcher == 999) {
//                [expect fulfill];
//            }
//            
//        }];
//    }
//    
//    [HNE bindNSIntegerIdentifier:@"class.intWatcher" object:self keyPath:@"intWatcher"];
//    
//    [self waitForExpectationsWithTimeout:1 handler:nil];
//}


@end
