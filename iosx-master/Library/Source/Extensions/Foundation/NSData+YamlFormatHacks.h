//
//  NSData+YamlFormatHacks.h
//  Hone
//
//  Created by Jaanus Kase on 29.04.14.
//
//

#import <Foundation/Foundation.h>

@interface NSData (YamlFormatHacks)

- (NSData *)dataWithArraysConvertedToDictionariesForLevels:(NSUInteger)levels;

- (NSData *)dataWithDictionariesConvertedToArraysForLevels:(NSUInteger)levels;

@end
