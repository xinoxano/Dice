//
//  DocumentParameter.h
//  Hone
//
//  Created by Jaanus Kase on 15.02.14.
//
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif
#import "HNEType.h"



@class HNEDocumentParameter;



/// One parameter value, and a set of additional info (e.g allowed min/max values, comments) for the parameter.

@interface HNEDocumentParameter : NSObject

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;

@property (assign, nonatomic) HNEType dataType;

/// The serializable value of the parameter. Value is always stored as serialized. For simple types, same as value itself. For complex types, dictionary/array/etc representation.
@property (copy, nonatomic) id value;

/// The native value (e.g native font, color type). Is marshalled to serializable, but can be cached.
@property (copy, nonatomic) id nativeValue;

@property (copy, nonatomic) NSString *name;

/// Dictionary representation of the parameter name, type and value, suitable for archiving or transmitting over API
- (NSDictionary *)dictionaryRepresentation;

/// The overriden values for this parameter, keyed by theme name.
- (NSDictionary *)valueOverrides;

/// Return the appropriate empty (serializable) value for a given data type
+ (id)defaultValueForDataType:(HNEType)dataType;

+ (NSString *)stringLabelForDataType:(HNEType)dataType;

+ (HNEType)dataTypeForStringLabel:(NSString *)label;

+ (BOOL)isValueValid:(id)value forDataType:(HNEType)dataType error:(out NSError **)error;

@end



/// Both the regular and editor value overrides conform to this
@protocol HNEValueOverride <NSObject>

- (NSString *)themeName;

@end


/// Encapsulates the overrides of the value in themes.
@interface HNEDocumentParameterValueOverride : HNEDocumentParameter <HNEValueOverride>

- (instancetype)initWithDocumentThemeName:(NSString *)themeName documentParameter:(HNEDocumentParameter *)parameter value:(id)value;

@property (nonatomic, readonly) NSString *themeName;

@property (nonatomic, readonly) HNEDocumentParameter *parameter;

/// Read-only getter for name, returns parameter name
- (NSString *)name;

/// Read-only getter for type, returns parameter type
- (HNEType)dataType;

@end
