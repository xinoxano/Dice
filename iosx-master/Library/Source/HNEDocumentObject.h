//
//  DocumentObject.h
//  Hone
//
//  Created by Jaanus Kase on 20.01.14.
//
//

#import <Foundation/Foundation.h>



@class HNEDocumentParameter;



/// Models one application object. It may have an array of parameters encapsulating the actual values.

@interface HNEDocumentObject : NSObject

/// Init the object with a dictionary object, such as retrieved from the values.yaml file, or received from device over the client API.
- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;

@property (nonatomic, copy) NSString *name;

/// Array of DocumentParameter values.
@property (nonatomic, strong) NSArray *parameters;

/// Add a parameter to this object.
- (void)addParameter:(HNEDocumentParameter *)parameter;

/// Remove a parameter from this object.
- (void)removeParameter:(HNEDocumentParameter *)parameter;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/// Dictionary representation of the object, with the object name as key, and parameters as the array content
- (NSDictionary *)dictionaryRepresentation;

@end
