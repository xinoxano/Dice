//
//  HNEParameterStoreTests.m
//  HoneExample
//
//  Created by Jaanus Kase on 03.07.14.
//
//

#import <XCTest/XCTest.h>
#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEDocumentParameter.h"
#import "HNEDocumentParameter+Private.h"
#import "HNEDocumentObject.h"
#import "HNE+Private.h"



@interface HNEParameterStoreTests : XCTestCase

@property (strong, nonatomic) HNE *hone;

@end



@implementation HNEParameterStoreTests

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

- (void)testSetStringParameter
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore activateThemes:nil];
	
	HNEDocumentParameter *checker = [self.hone.parameterStore documentParameterForIdentifier:@"param" inClass:@"testClass" usedTheme:nil];
	XCTAssertEqualObjects(checker.value, @"tere kere", @"Wrong string value");	
}

- (void)testSetStringParameterWithTheme
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];
								  
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore activateThemes:nil];
	
	HNEDocumentParameter *checkerWithoutTheme = [self.hone.parameterStore documentParameterForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(checkerWithoutTheme.value, @"tere kere", @"Wrong string value");

	HNEDocumentParameter *themedSetter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere theme"}];
	
	[self.hone.parameterStore setParameter:themedSetter inClass:@"testClass" theme:@"theme1" storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore activateThemes:@[@"theme1"]];
	
	HNEDocumentParameter *checkerWithTheme = [self.hone.parameterStore documentParameterForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(checkerWithTheme.value, @"tere kere theme", @"Wrong string value");

	[self.hone.parameterStore activateThemes:@[@"theme2"]];
	
	HNEDocumentParameter *checkerWithNoTheme = [self.hone.parameterStore documentParameterForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(checkerWithNoTheme.value, @"tere kere", @"Wrong string value");

}

- (void)testSetFontParameter
{
	NSDictionary *fontDict = @{
							   @"typeface": @"ARSMaquettePro-Light",
							   @"size": @(14),
							   @"number_style": @"oldstyle",
							   @"number_spacing": @"monospaced"
							   };
	
	HNEDocumentParameter *fontParameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:
										@{@"testFont~font": fontDict}];
	[self.hone.parameterStore setParameter:fontParameter inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	HNEDocumentParameter *checker = [self.hone.parameterStore documentParameterForIdentifier:@"testFont" inClass:@"testClass" usedTheme:nil];
	
	XCTAssertEqualObjects(checker.value, fontDict, @"Bad font dictionary value");
}

- (void)testSetFontParameterWithTheme
{
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];
	
	NSDictionary *fontDict = @{
							   @"typeface": @"ARSMaquettePro-Light",
							   @"size": @(14),
							   @"number_style": @"oldstyle",
							   @"number_spacing": @"monospaced"
							   };
	
	NSDictionary *fontDict2 = @{
							   @"typeface": @"ARSMaquettePro-Light",
							   @"size": @(14),
							   @"number_style": @"oldstyle",
							   @"number_spacing": @"proportional"
							   };
	
	HNEDocumentParameter *fontParameter = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation: @{@"testFont~font": fontDict}];
	
	[self.hone.parameterStore setParameter:fontParameter inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	HNEDocumentParameter *themedFont = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"testFont~font": fontDict2}];
	
	[self.hone.parameterStore setParameter:themedFont inClass:@"testClass" theme:@"theme1" storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	[self.hone.parameterStore activateThemes:@[@"theme1"]];
	
	NSString *usedTheme = @"";
	HNEDocumentParameter *checker = [self.hone.parameterStore documentParameterForIdentifier:@"testFont" inClass:@"testClass" usedTheme:&usedTheme];
				
	XCTAssertEqualObjects(checker.value, fontDict2, @"Bad font value");
	XCTAssertEqualObjects(usedTheme, @"theme1", @"Bad theme was used");
	
	[self.hone.parameterStore activateThemes:@[@"theme2"]];
				
	checker = [self.hone.parameterStore documentParameterForIdentifier:@"testFont" inClass:@"testClass" usedTheme:&usedTheme];
	XCTAssertNil(usedTheme, @"Bad theme was used");
	XCTAssertEqualObjects(checker.value, fontDict, @"Bad font value");
}

- (void)testGetStringParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore activateThemes:nil];
	
	NSString *s = [self.hone.parameterStore parameterNativeValueForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(s, @"tere kere", @"Wrong string value");
}

- (void)testGetStringThemedParameterValue
{
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];

	HNEDocumentParameter *p2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere2 kere2"}];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore setParameter:p2 inClass:@"testClass" theme:@"theme1" storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	[self.hone.parameterStore activateThemes:nil];
	NSString *s = [self.hone.parameterStore parameterNativeValueForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(s, @"tere kere", @"Wrong string value");
	
	[self.hone.parameterStore activateThemes:@[@"theme1"]];
	s = [self.hone.parameterStore parameterNativeValueForIdentifier:@"param" inClass:@"testClass"];
	XCTAssertEqualObjects(s, @"tere2 kere2", @"Wrong string value");

}



#pragma mark - Theme ordering bug

- (void)testThatItSetsParameterCorrectlyWhenThemedValueSetBeforeMainValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~int": @(4)}];

	HNEDocumentParameter *p2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~int": @(5)}];
	
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];

	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:@"theme1" storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore setParameter:p2 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	
	NSArray *objects = [self.hone.parameterStore documentObjects];
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	HNEDocumentObject *o = objects.firstObject;
	NSArray *knownParameters = [self.hone.parameterStore parametersForDocumentObject:o];
	XCTAssertEqual(knownParameters.count, 1, @"Bad parameter count");
	HNEDocumentParameter *param = knownParameters.firstObject;
	XCTAssertEqualObjects(param.name, @"param");
	XCTAssertEqualObjects(param.value, @(5));

}



#pragma mark - Test getting and setting parameters on multiple levels

- (void)testRedefineExistingParameterOnDifferentLevel
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	HNEDocumentParameter *p2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param2~string": @"tere2 kere2"}];
	HNEDocumentParameter *p2bis = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param2~string": @"tere2bis kere2bis"}];
	// DocumentParameter *p3 = [[DocumentParameter alloc] initWithDictionaryRepresentation:@{@"param3~string": @"tere3 kere3"} documentObject:nil];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore setParameter:p2 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDocument];

	NSArray *objects = [self.hone.parameterStore documentObjects];
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	HNEDocumentObject *o = objects.firstObject;
	NSArray *knownParameters = [self.hone.parameterStore parametersForDocumentObject:o];
	XCTAssertEqual(knownParameters.count, 2, @"Bad parameter count");
	
	[self.hone.parameterStore setParameter:p2bis inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelBonjour];
	objects = [self.hone.parameterStore mergedDocumentObjects];
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	o = objects.firstObject;
	knownParameters = o.parameters;
	XCTAssertEqual(knownParameters.count, 2, @"Bad parameter count");
	HNEDocumentParameter *paraTest = knownParameters[0];
	XCTAssertEqualObjects(paraTest.name, @"param2", @"Bad parameter name");
	XCTAssertEqualObjects(paraTest.value, @"tere2bis kere2bis", @"Unexpected parameter value");
}

- (void)testAddParameterOnHigherLevel
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	HNEDocumentParameter *p2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param2~string": @"tere2 kere2"}];
	HNEDocumentParameter *p3 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param3~string": @"tere3 kere3"}];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	[self.hone.parameterStore setParameter:p2 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelBonjour];
	NSArray *objects = [self.hone.parameterStore mergedDocumentObjects];
	HNEDocumentObject *o = objects.firstObject;
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	NSArray *knownParameters = o.parameters;
	XCTAssertEqual(knownParameters.count, 2, @"Bad parameter count");

	[self.hone.parameterStore setParameter:p3 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDocument];
	objects = [self.hone.parameterStore mergedDocumentObjects];
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	o = objects.firstObject;
	knownParameters = o.parameters;
	XCTAssertEqual(knownParameters.count, 3, @"Bad parameter count");

}

- (void)testAddParameterOnLowerLevel
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param~string": @"tere kere"}];
	HNEDocumentParameter *p2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param2~string": @"tere2 kere2"}];
	HNEDocumentParameter *p3 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"param3~string": @"tere3 kere3"}];
	
	[self.hone.parameterStore setParameter:p inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDocument];
	[self.hone.parameterStore setParameter:p2 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelBonjour];
	NSArray *objects = [self.hone.parameterStore mergedDocumentObjects];
	HNEDocumentObject *o = objects.firstObject;
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	NSArray *knownParameters = o.parameters;
	XCTAssertEqual(knownParameters.count, 2, @"Bad parameter count");
	
	[self.hone.parameterStore setParameter:p3 inClass:@"testClass" theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
	objects = [self.hone.parameterStore mergedDocumentObjects];
	XCTAssertEqual(objects.count, 1, @"Bad object count");
	o = objects.firstObject;
	knownParameters = o.parameters;
	XCTAssertEqual(knownParameters.count, 3, @"Bad parameter count");
	
}



#pragma mark - Test that callbacks aren’t run multiple times for the same parameter themed value

- (void)testGetNSIntegerWithMultipleThemeCallbacks {
	XCTestExpectation *multipleCallbacks = [self expectationWithDescription:@"All callbacks were run"];
	
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(3)}];
	HNEDocumentParameter *theme1 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(4)}];
	HNEDocumentParameter *theme2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(5)}];
	
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];
	[self.hone.parameterStore setParameter:p inClass:@"misObject" theme:nil storeLevel:HNEParameterStoreLevelDocument];
	[self.hone.parameterStore setParameter:theme1 inClass:@"misObject" theme:@"theme1" storeLevel:HNEParameterStoreLevelDocument];
	[self.hone.parameterStore setParameter:theme2 inClass:@"misObject" theme:@"theme2" storeLevel:HNEParameterStoreLevelDocument];
	
	__block NSInteger testInt = 1;
	__block NSInteger callbackRunCount = 0;
	
	[self.hone bindNSIntegerIdentifier:@"misObject.misValue" defaultValue:2 object:self block:^(HNEParameterStoreTests *tests, NSInteger value)
	{
		testInt = value;
		callbackRunCount++;
		if (testInt == 5) {
			[multipleCallbacks fulfill];
		}
	}];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.hone activateThemes:@[@"theme1"]];
	});

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.hone activateThemes:@[@"theme2"]];
	});
	
	[self waitForExpectationsWithTimeout:1 handler:nil];

	XCTAssertEqual(callbackRunCount, 3);
	XCTAssertEqual(testInt, 5);
}

- (void)testGetNSIntegerWithMultipleRedundantThemeCallbacks
{
	XCTestExpectation *multipleCallbacks = [self expectationWithDescription:@"All callbacks were run"];
	
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(3)}];
	HNEDocumentParameter *theme1 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(3)}];
	HNEDocumentParameter *theme2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misValue~int": @(3)}];
	
	self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1", @"theme2"]];
	
	__block NSInteger testInt = 1;
	__block NSInteger callbackRunCount = 0;

	[self.hone.parameterStore setParameter:p inClass:@"misObject" theme:nil storeLevel:HNEParameterStoreLevelDocument];
	[self.hone.parameterStore setParameter:theme1 inClass:@"misObject" theme:@"theme1" storeLevel:HNEParameterStoreLevelDocument];
	[self.hone.parameterStore setParameter:theme2 inClass:@"misObject" theme:@"theme2" storeLevel:HNEParameterStoreLevelDocument];

	[self.hone bindNSIntegerIdentifier:@"misObject.misValue" defaultValue:2 object:self block:^(HNEParameterStoreTests *tests, NSInteger value)
	 {
		 testInt = value;
		 callbackRunCount++;
	 }];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.hone activateThemes:@[@"theme1"]];
	});
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.hone activateThemes:@[@"theme2"]];
	});
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[multipleCallbacks fulfill];
	});

	[self waitForExpectationsWithTimeout:1 handler:nil];
	
	XCTAssertEqual(callbackRunCount, 1);
	XCTAssertEqual(testInt, 3);
}

- (void)testThatItPreservesThemedColorValue
{
    // test for https://github.com/honetools/tool/issues/63 - The themed value was cleared out
    // if the main value was set after it.
    
    HNEDocumentParameter *colorParam1 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"color~color": @[@(1), @(0), @(0), @(1)]}];
    HNEDocumentParameter *colorParam2 = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"color~color": @[@(0), @(1), @(0), @(1)]}];
    
    self.hone.parameterStore.availableThemes = [NSMutableSet setWithArray:@[@"theme1"]];
    
    [self.hone.parameterStore setParameter:colorParam1 inClass:@"test" theme:@"theme1" storeLevel:HNEParameterStoreLevelBonjour];
    [self.hone.parameterStore setParameter:colorParam2 inClass:@"test" theme:nil storeLevel:HNEParameterStoreLevelBonjour];
    
    
#if TARGET_OS_IPHONE
    HNEColor *tester1 = [HNEColor colorWithRed:0 green:1 blue:0 alpha:1];
    HNEColor *tester2 = [HNEColor colorWithRed:1 green:0 blue:0 alpha:1];
#else
    HNEColor *tester1 = [HNEColor colorWithDeviceRed:0 green:1 blue:0 alpha:1];
    HNEColor *tester2 = [HNEColor colorWithDeviceRed:1 green:0 blue:0 alpha:1];
#endif
    
    HNEColor *c1 = [self.hone.parameterStore parameterNativeValueForIdentifier:@"color" inClass:@"test"];
    XCTAssertEqualObjects(c1, tester1);
    
    [self.hone.parameterStore activateThemes:@[@"theme1"]];
    HNEColor *c2 = [self.hone.parameterStore parameterNativeValueForIdentifier:@"color" inClass:@"test"];
    
    XCTAssertEqualObjects(c2, tester2);
}



@end
