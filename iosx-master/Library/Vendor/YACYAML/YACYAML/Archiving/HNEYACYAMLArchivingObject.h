//
//  YACYAMLArchivingObject.h
//  YACYAML
//
//  Created by James Montgomerie on 18/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HNEYACYAMLKeyedArchiver;
struct yaml_emitter_s;

@interface HNEYACYAMLArchivingObject : NSObject

@property (nonatomic, strong) id representedObject;

- (id)initWithRepresentedObject:(id)representedObject
                    forArchiver:(HNEYACYAMLKeyedArchiver *)archiver;
- (void)encodeChild:(id)obj forKey:(id)key;

- (void)emitWithEmitter:(struct yaml_emitter_s *)emitter;

@end