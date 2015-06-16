//
//  NSObject+HNE.h
//  Hone-iosx
//
//  Created by Jaanus Kase on 10.11.14.
//
//

#import <Foundation/Foundation.h>


FOUNDATION_EXTERN NSString *const HNEIgnoredValueIdentifiers;
FOUNDATION_EXPORT NSString *const HNEOnlyValueIdentifiers;


@interface NSObject (HNE)

/// Instruct Hone to manage the properties of this object using the indicated Hone object’s values.
- (void)bindToHoneObject:(NSString *)identifier;

/**
 Specify additional options when binding. The options dictionary may have the following keys and values:
 
 HNEIgnoredValueIdentifiers: NSSet of the identifier strings to ignore in the automatic binding mechanism. For example:
 [someObject bindToHoneObject:@"honeObject" options:@{ HNEIgnoredValueIdentifiers: [NSSet setWithArray:@[ @"ignoredValue", @"anotherIgnoredValue" ]] }];
 HNEOnlyValueIdentifiers: NSSet of the identifier strings to bind to. All other identifiers are ignored.
 
 */
- (void)bindToHoneObject:(NSString *)identifier options:(NSDictionary *)options;

@end
