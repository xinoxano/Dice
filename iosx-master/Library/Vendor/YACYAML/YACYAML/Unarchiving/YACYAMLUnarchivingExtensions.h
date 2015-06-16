//
//  YACYAMLUnarchivingExtensions.h
//  YACYAML
//
//  Created by James Montgomerie on 29/05/2012.
//  Copyright (c) 2012 James Montgomerie. All rights reserved.
//

#import "HNEYACYAMLKeyedUnarchiver.h"

void YACYAMLUnarchivingExtensionsRegister(void);

@interface NSNumber (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingScalar>
@end

@interface NSDate (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingScalar>
@end

@interface NSData (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingScalar>
@end

@interface NSNull (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingScalar>
@end



@interface NSArray (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingSequence>
@end

@interface NSDictionary (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingMapping>
@end

@interface NSSet (YACYAMLUnarchivingExtensions) <HNEYACYAMLUnarchivingMapping>
@end

