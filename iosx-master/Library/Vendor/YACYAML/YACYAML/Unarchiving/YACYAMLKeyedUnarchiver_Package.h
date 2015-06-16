//
//  YACYAMLKeyedUnarchiver_Package.h
//  YACYAML
//
//  Created by James Montgomerie on 24/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

struct yaml_parser_s; 
@class HNEYACYAMLUnarchivingObject;

@interface HNEYACYAMLKeyedUnarchiver ()

- (void)setUnarchivingObject:(HNEYACYAMLUnarchivingObject *)unarchivingObject
                   forAnchor:(NSString *)anchor;
- (HNEYACYAMLUnarchivingObject *)previouslyInstantiatedUnarchivingObjectForAnchor:(NSString *)anchor;

- (void)pushUnarchivingObject:(HNEYACYAMLUnarchivingObject *)archivingObject;
- (void)popUnarchivingObject;

+ (Class)classForYAMLTag:(NSString *)tag;
+ (Class)classForYAMLScalarString:(NSString *)scalarString;

@end
