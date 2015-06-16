//
//  DocumentParameterTests.m
//  Hone
//
//  Created by Jaanus Kase on 26.02.14.
//
//

#import <XCTest/XCTest.h>
#import "HNEDocumentParameter.h"
#import "HNEDocumentParameter+Private.h"
//#import <YACYAML/YACYAML.h>
#import "HNEError.h"
#import "HNEShared.h"


#if TARGET_OS_IPHONE
#define HNETestFont UIFont
#define HNETestColor UIColor
#else
#define HNETestFont NSFont
#define HNETestColor NSColor
#endif



@interface HNEDocumentParameterTests : XCTestCase

@end

@implementation HNEDocumentParameterTests

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

- (void)testInitSimpleFloatWithDictionaryRepresentation
{
	NSDictionary *dict = @{@"parameter~float": @(3.14)};
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:dict];
	
	XCTAssertTrue(p.dataType == HNETypeFloat, @"Type is not float as expected");
	XCTAssertEqualObjects(p.name, @"parameter", @"Bad name for float");
	XCTAssertEqualWithAccuracy([p.value floatValue], 3.14, FLT_EPSILON, @"Bad value for float");
}

//- (void)testInitSimpleFloatWithYaml
//{
//	NSString *yaml = @"parameter~float: 3.14";
//	NSDictionary *dict = [YACYAMLKeyedUnarchiver unarchiveObjectWithData:[yaml dataUsingEncoding:NSUTF8StringEncoding]];
//	
//	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:dict];
//
//	XCTAssertTrue(p.dataType == HNETypeFloat, @"Type is not float as expected");
//	XCTAssertEqualObjects(p.name, @"parameter", @"Bad name for float");
//	XCTAssertEqualWithAccuracy([p.value floatValue], 3.14, FLT_EPSILON, @"Bad value for float");
//}

- (void)testInitSimpleFloatWithJson
{
	NSString *json = @"{ \"parameter~float\": 3.14 }";
	NSError *jsonError = nil;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:dict];
	
	XCTAssertTrue(p.dataType == HNETypeFloat, @"Type is not float as expected");
	XCTAssertEqualObjects(p.name, @"parameter", @"Bad name for float");
	XCTAssertEqualWithAccuracy([p.value floatValue], 3.14, FLT_EPSILON, @"Bad value for float");
}



#pragma mark - Default values

- (void)testDefaultBoolValue
{
	BOOL b = [[HNEDocumentParameter defaultValueForDataType:HNETypeBool] boolValue];
	XCTAssertEqual(b, NO);
}

- (void)testDefaultCGFloatValue
{
	CGFloat f = [[HNEDocumentParameter defaultValueForDataType:HNETypeFloat] floatValue];
	XCTAssertEqualWithAccuracy(f, 0, FLT_EPSILON, @"Bad float value");
}

- (void)testDefaultNSIntegerValue
{
	NSInteger i = [[HNEDocumentParameter defaultValueForDataType:HNETypeInt] integerValue];
	XCTAssertEqual(i, 0, @"Bad integer value");
}

- (void)testDefaultFontValue
{
	NSDictionary *f = [HNEDocumentParameter defaultValueForDataType:HNETypeFont];
	NSDictionary *expected = @{@"typeface": [HNETestFont systemFontOfSize:12].fontName, @"size": @(12)};
	XCTAssertEqualObjects(f, expected);
}

- (void)testDefaultColorValue
{
	NSArray *c = [HNEDocumentParameter defaultValueForDataType:HNETypeColor];
	NSArray *expected = @[@(0), @(0), @(0), @(1)];
	XCTAssertEqualObjects(c, expected);
}

- (void)testDefaultStringValue
{
	NSString *s = [HNEDocumentParameter defaultValueForDataType:HNETypeString];
	XCTAssertEqualObjects(s, @"", @"Bad string value");
}

- (void)testDefaultInvalidDatatypeValue
{
	XCTAssertThrowsSpecificNamed([HNEDocumentParameter defaultValueForDataType:9999], NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}



#pragma mark - Default values to freshly created parameters

- (void)testDefaultBOOLParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeBool;
	XCTAssertEqual([p.value boolValue], NO);
}

- (void)testDefaultFloatParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeFloat;
	XCTAssertEqualWithAccuracy([p.value floatValue], 0, FLT_EPSILON, @"Bad default float value");
}

- (void)testDefaultIntParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeInt;
	XCTAssertNotNil(p.value, @"Bad integer object value");
	XCTAssertEqual([p.value integerValue], 0, @"Bad default integer value");
}

- (void)testDefaultStringParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeString;
	XCTAssertEqualObjects(p.value, @"", @"Bad default string value");
}

- (void)testDefaultColorParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeColor;
#if TARGET_OS_IPHONE
	HNETestColor *expected = [HNETestColor colorWithRed:0 green:0 blue:0 alpha:1];
#else
    HNETestColor *expected = [HNETestColor colorWithDeviceRed:0 green:0 blue:0 alpha:1];
#endif
	XCTAssertEqualObjects(p.nativeValue, expected, @"Bad default color value");
}

- (void)testDefaultFontParameterValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeFont;
	HNEFont *font = p.nativeValue;
	XCTAssertEqualObjects(font.fontName, [HNETestFont systemFontOfSize:12].fontName, @"Bad default font name");
	XCTAssertEqual(font.pointSize, [HNETestFont systemFontOfSize:12].pointSize, @"Bad default font size");
}



#pragma mark - Get serializable values

- (void)testGetBOOLSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misse~bool": @(1)}];
	
	XCTAssertEqualObjects(p.name, @"misse");
	NSNumber *n = p.nativeValue;
	XCTAssertEqual([p.value boolValue], YES);
	XCTAssertEqual([n boolValue], YES);
	
}

- (void)testGetFloatSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~float": @(2.5)}];
	
	XCTAssertEqualObjects(p.name, @"wat", @"Bad name");
	NSNumber *n = p.nativeValue;
	XCTAssertEqualWithAccuracy([p.value floatValue], 2.5, FLT_EPSILON, @"Bad float value");
	XCTAssertEqualWithAccuracy(n.floatValue, 2.5, FLT_EPSILON, @"Bad float value");
}

- (void)testGetIntSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~int": @(4)}];
	
	XCTAssertEqualObjects(p.name, @"wat", @"Bad name");
	NSNumber *n = p.nativeValue;
	XCTAssertEqual([p.value intValue], 4, @"Bad int value");
	XCTAssertEqual(n.floatValue, 4, @"Bad int value");
}

- (void)testGetStringSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~string": @"Hello world"}];
	
	XCTAssertEqualObjects(p.name, @"wat", @"Bad name");
	NSString *s = p.value;
	XCTAssertEqualObjects(p.value, @"Hello world", @"Bad string value");
	XCTAssertEqualObjects(s, @"Hello world", @"Bad string value");
}

- (void)testGetColorSerializableValue
{
	HNETestColor *c = [HNETestColor colorWithRed:1 green:0 blue:0.5 alpha:1];
	
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeColor;
	p.name = @"color";
	p.nativeValue = c;
	
	NSArray *serialized = p.value;
	NSArray *expected = @[@(1), @(0), @(0.5), @(1)];
	XCTAssertEqualObjects(serialized, expected, @"Bad serialized color value");
	
}

- (void)testGetFontSerializableValue
{
	HNETestFont *f = [HNETestFont fontWithName:@"Georgia" size:16];
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
	p.dataType = HNETypeFont;
	p.name = @"Font";
	p.nativeValue = f;
	
	NSDictionary *serialized = p.value;
	NSDictionary *expected = @{@"typeface": @"Georgia", @"size": @(16)};
	
	XCTAssertEqualObjects(serialized, expected, @"Bad serialized font value");
}



#pragma mark - Set serializable values

- (void)testSetBoolSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"misse~bool": @(1)}];
	p.nativeValue = @(0);
	XCTAssertEqualObjects(p.value, @(0));
}

- (void)testSetFloatSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~float": @(3.5)}];
	p.nativeValue = @(4.5);
	XCTAssertEqualObjects(p.value, @(4.5), @"Bad float value");
}

- (void)testSetIntSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~int": @(3)}];
	p.value = @(4);
	XCTAssertEqualObjects(p.nativeValue, @(4), @"Bad int value");
}

- (void)testSetStringSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~string": @"Oh hai"}];
	p.value = @"Tere tere";
	XCTAssertEqualObjects(p.nativeValue, @"Tere tere", @"Bad string value");
}

- (void)testSetColorSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~color": @[@(1), @(0.5), @(0), @(1)]}];
	p.value = @[@(0.5), @(1), @(0), @(0.5)];

#if (TARGET_OS_IPHONE)
	HNEColor *expected = [HNEColor colorWithRed:0.5 green:1 blue:0 alpha:0.5];
#else
    HNEColor *expected = [HNEColor colorWithDeviceRed:0.5 green:1 blue:0 alpha:0.5];
#endif
	XCTAssertEqualObjects(expected, p.nativeValue, @"Bad color value");
}


- (void)testSetFontSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~font": @{@"typeface": @"Helvetica", @"size": @(13.0)}}];
	p.value = @{@"typeface": @"Georgia", @"size": @(14.0)};
	
	HNEFont *f = p.nativeValue;
	XCTAssertEqualWithAccuracy(f.pointSize, 14.0, FLT_EPSILON, @"Bad font size");
	XCTAssertEqualObjects(f.fontName, @"Georgia", @"Bad font name");
}

- (void)testSetInvalidColorSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~color": @[@(1), @(0.5), @(0), @(1)]}];
	
	XCTAssertThrowsSpecificNamed(p.nativeValue = @"Hello", NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}

- (void)testSetInvalidFontSerializableValue
{
	HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:@{@"wat~font": @{@"typeface": @"Helvetica", @"size": @(13.0)}}];

	XCTAssertThrowsSpecificNamed(p.value = @"hello", NSException, NSInvalidArgumentException, @"Didn’t throw expected exception");
}



#pragma mark - Parameter value validation - passing

- (void)testValidSerializedBOOLValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@(1) forDataType:HNETypeBool error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");
}

- (void)testValidSerializedFloatValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@(2.5) forDataType:HNETypeFloat error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");
}

- (void)testValidSerializedIntValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@(2) forDataType:HNETypeInt error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");
}

- (void)testValidSerializedStringValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"ohai" forDataType:HNETypeString error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");
}

- (void)testValidSerializedColorValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@[@(1),@(0.5),@(0),@(1)] forDataType:HNETypeColor error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");

}

- (void)testValidSerializedFontValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@{@"typeface":@"Georgia",@"size":@(12)} forDataType:HNETypeFont error:&e];
	XCTAssertTrue(valid, @"Bad result");
	XCTAssertNil(e, @"Unexpected error");
}



#pragma mark - Parameter value validation - failing

- (void)testInvalidSerializedBOOLValueNumber
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@(3) forDataType:HNETypeBool error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedBOOLValueDataType
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"kerse" forDataType:HNETypeBool error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}


- (void)testInvalidSerializedIntValueBadDatatype
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"wat" forDataType:HNETypeInt error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedIntValueDecimal
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@(2.5) forDataType:HNETypeInt error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedFloatValue
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"wat" forDataType:HNETypeFloat error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedColorValueBadDatatype
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"wat" forDataType:HNETypeColor error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedColorValueBadArray
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@[@(1), @(0)] forDataType:HNETypeColor error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedFontValueBadDatatype
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@"wat" forDataType:HNETypeFont error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}

- (void)testInvalidSerializedFontValueNonexistentFamily
{
	NSError *e = nil;
	BOOL valid = [HNEDocumentParameter isValueValid:@{@"typeface": @"NonexistentSans", @"size": @(14)} forDataType:HNETypeFont error:&e];
	XCTAssertFalse(valid, @"Bad result");
	XCTAssertNotNil(e, @"Unexpected error");
	XCTAssertEqual(e.code, HNEErrorCodeInvalidSerializedParameterValue, @"Error wasn’t what’s expected");
}



@end
