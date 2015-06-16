//
//  DocumentParameter.m
//  Hone
//
//  Created by Jaanus Kase on 15.02.14.
//
//

#import "HNE.h"
#import "HNEDocumentParameter.h"
#import "HNEDocumentParameter+Private.h"
#import "HNEError.h"
#import "HNEFont+HNETypography.h"

#if TARGET_OS_IPHONE
#import "UIColor+HNEColorWithArray.h"
#else
#import "NSColor+HNEColorWithArray.h"
#endif



@implementation HNEDocumentParameter

- (NSString *)description
{
	NSString *s = [NSString stringWithFormat:@"<%@: %p> Type: ", self.name, [self class]];
	
	switch (self.dataType) {
		case HNETypeFont:
			s = [s stringByAppendingString:@"font"];
			break;
			
		case HNETypeFloat:
			s = [[[s stringByAppendingString:@"float ("] stringByAppendingString:[self.value description]] stringByAppendingString:@")"];
			break;
			
		case HNETypeInt:
			s = [[[s stringByAppendingString:@"int ("] stringByAppendingString:[self.value description]] stringByAppendingString:@")"];
			break;
			
		case HNETypeString:
			s = [s stringByAppendingString:[NSString stringWithFormat:@"string “%@”", self.value]];
			break;

		case HNETypeColor:
			s = [s stringByAppendingString:@"color"];
			break;
			
		case HNETypeBool:
			s = [s stringByAppendingString:[NSString stringWithFormat:@"bool (%ld)", (long)[self.value integerValue]]];
			break;
	}
	
	return s;
}

- (instancetype)init
{
	if (self = [super init]) {
		_backingValueOverrides = [NSMutableDictionary dictionary];
		_cachedNativeValue = nil;
	}
	return self;
}



- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation
{
	if (self = [self init]) {
		
		NSArray *nameAndType = [((NSString *)[dictionaryRepresentation allKeys][0]) componentsSeparatedByString:@"~"];
		
		if (nameAndType.count == 2) {
			NSString *parameterName = nameAndType[0];
			NSString *dataTypeString = nameAndType[1];
			
			self.name = parameterName;
			
			NSString *type = dataTypeString;
			id value = [dictionaryRepresentation allValues][0];
			
			if (type) {
				self.dataType = [HNEDocumentParameter dataTypeForStringLabel:type];
			}
			
			_value = value;
			
		}
	}
	return self;
}

- (NSDictionary *)dictionaryRepresentation
{
	NSString *type = [HNEDocumentParameter stringLabelForDataType:self.dataType];
	return @{
			 [NSString stringWithFormat:@"%@~%@", self.name, type]: self.value
			 };
}


- (NSDictionary *)valueOverrides
{
	return self.backingValueOverrides;
}

- (void)addValueOverride:(id<HNEValueOverride>)override
{
	self.backingValueOverrides[override.themeName] = override;
}

- (void)removeValueOverride:(id<HNEValueOverride>)override
{
	if (self.backingValueOverrides && self.backingValueOverrides[override.themeName]) {
		[self.backingValueOverrides removeObjectForKey:override.themeName];
	}
}



#pragma mark - Value getting and setting

- (void)setDataType:(HNEType)dataType
{
	if (_dataType != dataType) {
		_dataType = dataType;
	}
	
	// If there is no value object, init the default value;
	if (!_value) {
		_value = [HNEDocumentParameter defaultValueForDataType:_dataType];
	}
}

- (void)setValue:(id)value
{
	if (![_value isEqual:value]) {
		
		id proposedValue = value;
		
		// Some sanity checking for the serialized values
		switch (self.dataType) {
			case HNETypeColor: {
				if (![proposedValue isKindOfClass:[NSArray class]]) {
					[NSException raise:NSInvalidArgumentException format:@"Trying to set color from a non-array value: %@", proposedValue];
				}
				break;
			}
			case HNETypeFont: {
				if (![proposedValue isKindOfClass:[NSDictionary class]]) {
					[NSException raise:NSInvalidArgumentException format:@"Trying to set font from a non-dictionary value: %@", proposedValue];
				}
				break;
			}
			default:
				break;
		}
		
		
		_cachedNativeValue = nil;
		_value = proposedValue;
	}
}

- (id)nativeValue
{
	if (_cachedNativeValue) {
		return _cachedNativeValue;
	}
	
	switch (self.dataType) {
		case HNETypeBool:
		case HNETypeFloat:
		case HNETypeInt:
		case HNETypeString:
			_cachedNativeValue = _value;
			break;
		case HNETypeColor:
			_cachedNativeValue = [HNEColor HNEcolorWithRGBAArray:_value];
			break;
		case HNETypeFont:
			_cachedNativeValue = [HNEFont fontWithHNESerializedRepresentation:_value];
			break;
	}
	
	return _cachedNativeValue;
}

- (void)setNativeValue:(id)nativeValue
{
	_cachedNativeValue = nil;
	switch (self.dataType) {
		case HNETypeBool:
		case HNETypeFloat:
		case HNETypeInt:
		case HNETypeString:
			_value = nativeValue;
			break;
		case HNETypeFont:
			_value = [(HNEFont *)nativeValue HNEserializedRepresentation];
			break;
		case HNETypeColor: {
			CGFloat r, g, b, a;
			HNEColor *color = nativeValue;
#if !TARGET_OS_IPHONE
			if (![color.colorSpace isEqual:[NSColorSpace deviceRGBColorSpace]]) {
				color = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
			}
#endif
			[color getRed:&r green:&g blue:&b alpha:&a];
			_value = @[@(r), @(g), @(b), @(a)];
			break;
		}
	}
}



#pragma mark - Class methods

+ (id)defaultValueForDataType:(HNEType)dataType
{
	switch (dataType) {
		case HNETypeFont:
			return @{ @"typeface": [HNEFont systemFontOfSize:12].fontName,
					  @"size": @(12) };
			break;
			
		case HNETypeFloat:
			return @(0.0);
			break;
			
		case HNETypeBool:
			return @(NO);
			break;
			
		case HNETypeColor:
			return @[@(0), @(0), @(0), @(1)]; // default black color
			break;
			
		case HNETypeInt:
			return @(0);
			break;
			
		case HNETypeString:
			return @"";
			break;
	}
		
	[NSException raise:NSInvalidArgumentException format:@"No default value provided for data type"];
	return nil;
}

+ (NSString *)stringLabelForDataType:(HNEType)dataType
{
	switch (dataType) {
		case HNETypeColor:
			return @"color";
			break;
		case HNETypeBool:
			return @"bool";
			break;
		case HNETypeFloat:
			return @"float";
			break;
		case HNETypeFont:
			return @"font";
			break;
		case HNETypeInt:
			return @"int";
			break;
		case HNETypeString:
			return @"string";
			break;
	}
	
	[NSException raise:NSInvalidArgumentException format:@"No string label provided for data type"];
	return nil;	
}

+ (HNEType)dataTypeForStringLabel:(NSString *)label
{
	if ([label isEqualToString:@"color"]) {
		return HNETypeColor;
	}
	if ([label isEqualToString:@"float"]) {
		return HNETypeFloat;
	}
	if ([label isEqualToString:@"font"]) {
		return HNETypeFont;
	}
	if ([label isEqualToString:@"int"]) {
		return HNETypeInt;
	}
	if ([label isEqualToString:@"string"]) {
		return HNETypeString;
	}
	if ([label isEqualToString:@"bool"]) {
		return HNETypeBool;
	}
	
	[NSException raise:NSInvalidArgumentException format:@"Invalid string label “%@”, cannot determine Hone data type", label];
	return HNETypeFloat;
}

+ (BOOL)isValueValid:(id)serializedValue forDataType:(HNEType)dataType error:(out NSError *__autoreleasing *)error
{
	BOOL result = YES;
	
	switch (dataType) {
		case HNETypeBool: {
			if (![serializedValue isKindOfClass:[NSNumber class]]) {
				result = NO;
			}
			NSInteger intValue = [serializedValue integerValue];
			if ((intValue < 0) || (intValue > 1)) {
				result = NO;
			}
			break;
		}
		case HNETypeFloat: {
			if (![serializedValue isKindOfClass:[NSNumber class]]) {
				result = NO;
			}
			break;
		}
		case HNETypeInt: {
			if (![serializedValue isKindOfClass:[NSNumber class]]) {
				result = NO;
				break;
			}
			if (((NSNumber *)serializedValue).floatValue != ((NSNumber *)serializedValue).intValue) {
				result = NO;
			}
			break;
		}
		case HNETypeString: {
			if (![serializedValue isKindOfClass:[NSString class]]) {
				result = NO;
			}
			break;
		}
		case HNETypeColor: {
			if (![serializedValue isKindOfClass:[NSArray class]]) {
				result = NO;
				break;
			}
			if (((NSArray *)serializedValue).count != 4) {
				result = NO;
			}
			break;
		}
		case HNETypeFont: {
			if (![serializedValue isKindOfClass:[NSDictionary class]]) {
				result = NO;
				break;
			}
			NSDictionary *fontDict = serializedValue;
			NSString *typeface = fontDict[@"typeface"];
			NSNumber *fontSize = fontDict[@"size"];
			if (!typeface || !fontSize) {
				result = NO;
				break;
			}
			HNEFont *font = [HNEFont fontWithName:typeface size:fontSize.floatValue];
			if (!font) {
				result = NO;
				break;
			}
			break;
		}
	}
	
	if (!result && (error != NULL)) {
		*error = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidSerializedParameterValue userInfo:nil];
	}
	
	return result;
}

@end



@interface HNEDocumentParameterValueOverride ()

@property (nonatomic, readwrite) NSString *themeName;
@property (nonatomic, readwrite) HNEDocumentParameter *parameter;

@end



@implementation HNEDocumentParameterValueOverride

- (instancetype)initWithDocumentThemeName:(NSString *)themeName documentParameter:(HNEDocumentParameter *)parameter value:(id)value
{
	if (self = [super init]) {
		_themeName = themeName;
		_parameter = parameter;
		self.value = value;
	}
	return self;
}

- (NSString *)name
{
	return self.parameter.name;
}

- (HNEType)dataType
{
	return self.parameter.dataType;
}

@end
