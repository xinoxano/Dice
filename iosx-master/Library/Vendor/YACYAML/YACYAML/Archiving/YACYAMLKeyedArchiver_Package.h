//
//  YACYAMLKeyedArchiver_Package.h
//  YACYAML
//
//  Created by James Montgomerie on 18/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HNEYACYAMLArchivingObject;

@interface HNEYACYAMLKeyedArchiver ()

@property (nonatomic, readonly) BOOL scalarAnchorsAllowed;

- (void)pushArchivingObject:(HNEYACYAMLArchivingObject *)archivingObject;
- (void)popArchivingObject;
- (void)noteNonAnchoringObject:(HNEYACYAMLArchivingObject *)archivingObject;

- (HNEYACYAMLArchivingObject *)previouslySeenArchivingObjectForObject:(id)object;
- (NSString *)generateAnchor;

@end
