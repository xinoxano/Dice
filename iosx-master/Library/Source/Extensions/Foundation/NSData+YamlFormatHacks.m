//
//  NSData+YamlFormatHacks.m
//  Hone
//
//  Created by Jaanus Kase on 29.04.14.
//
//

#import "NSData+YamlFormatHacks.h"

@implementation NSData (YamlFormatHacks)

- (NSData *)dataWithArraysConvertedToDictionariesForLevels:(NSUInteger)levels
{
	NSString *s = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
	
	for (NSInteger level = levels-1; level >= 0; level--) {
		
		NSString *prefix = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
		prefix = [@"^(" stringByAppendingString:prefix];
		prefix = [prefix stringByAppendingString:@")- "];
		
		NSError *e = nil;
		
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:prefix options:NSRegularExpressionAnchorsMatchLines error:&e];
		
		s = [regex stringByReplacingMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:@"$1"];
	}
	
	// Shift all deeper levels left by one indentation level
	NSString *searcher = [@"" stringByPaddingToLength:(levels+1)*2 withString:@" " startingAtIndex:0];
	searcher = [@"^" stringByAppendingString:searcher];
	
	NSString *replacer = [@"" stringByPaddingToLength:levels*2 withString:@" " startingAtIndex:0];

	NSError *e = nil;
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searcher options:NSRegularExpressionAnchorsMatchLines error:&e];
	
	s = [regex stringByReplacingMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:replacer];
	
	return [s dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)dataWithDictionariesConvertedToArraysForLevels:(NSUInteger)levels
{
	NSString *s = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
	
	for (NSInteger level = 0; level < levels; level++) {
		NSString *prefix = [@"" stringByPaddingToLength:level * 2 withString:@" " startingAtIndex:0];
		prefix = [@"^(" stringByAppendingString:prefix];
		prefix = [prefix stringByAppendingString:@")(\\S)"];
		NSError *e = nil;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:prefix options:NSRegularExpressionAnchorsMatchLines error:&e];
		s = [regex stringByReplacingMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:@"$1- $2"];
	}
	
	// After all the conversions, shift the nested dictionary keys right by 1 level, but don’t touch arrays
	
	NSString *searcher = [@"" stringByPaddingToLength:(levels)*2 withString:@" " startingAtIndex:0];
	searcher = [@"^" stringByAppendingString:searcher];
	searcher = [searcher stringByAppendingString:@"([^-])"];
	
	NSString *replacer = [@"" stringByPaddingToLength:(levels+1)*2 withString:@" " startingAtIndex:0];
	replacer = [replacer stringByAppendingString:@"$1"];
	
	NSError *e = nil;
	
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searcher options:NSRegularExpressionAnchorsMatchLines error:&e];
	
	s = [regex stringByReplacingMatchesInString:s options:0 range:NSMakeRange(0, s.length) withTemplate:replacer];

	
	
	return [s dataUsingEncoding:NSUTF8StringEncoding];
}

@end
