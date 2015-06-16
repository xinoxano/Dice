//
//  YACYAMLArchivingExtensions.h
//  YACYAML
//
//  Created by James Montgomerie on 18/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import "HNEYACYAMLKeyedArchiver.h"


@interface NSObject (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end


@interface NSString (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end

@interface NSNumber (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end

@interface NSDate (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end


@interface NSArray (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end

@interface NSDictionary (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end

@interface NSNull (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end

@interface NSSet (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end


@interface NSData (YACYAMLArchivingExtensions) <HNEYACYAMLArchivingCustomEncoding>
@end