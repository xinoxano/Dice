//
//  YACYAMLExtensions.m
//  YACYAML
//
//  Created by James Montgomerie on 31/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import "YACYAMLExtensions.h"
#import "HNEYACYAMLKeyedArchiver.h"
#import "HNEYACYAMLKeyedUnarchiver.h"

@implementation NSObject (YACYAMLExtensions)

- (NSString *)YACYAMLEncodedString
{
    return [HNEYACYAMLKeyedArchiver archivedStringWithRootObject:self];
}

- (NSData *)YACYAMLEncodedData
{
    return [HNEYACYAMLKeyedArchiver archivedDataWithRootObject:self];
}

@end

            
@implementation NSString (YACYAMLExtensions)

- (id)YACYAMLDecode
{
    return [self YACYAMLDecodeBasic];
}

- (id)YACYAMLDecodeBasic
{
    return [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithString:self options:YACYAMLKeyedUnarchiverOptionDisallowInitWithCoder];
}

- (id)YACYAMLDecodeAll
{
    return [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithString:self];
}

@end

            
@implementation NSData (YACYAMLExtensions)

- (id)YACYAMLDecode
{
    return [self YACYAMLDecodeBasic];
}

- (id)YACYAMLDecodeBasic
{
    return [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:self options:YACYAMLKeyedUnarchiverOptionDisallowInitWithCoder];
}

- (id)YACYAMLDecodeAll
{
    return [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:self];
}

@end
