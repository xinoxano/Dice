//
//  DocumentObject.m
//  Hone
//
//  Created by Jaanus Kase on 20.01.14.
//
//

#import "HNEDocumentObject.h"
#import "HNEDocumentObject+Private.h"
#import "HNEDocumentParameter.h"



@implementation HNEDocumentObject

- (NSString *)description
{
	NSString *d = [NSString stringWithFormat:@"<%@: %p> %@", [self class], self, self.name];
	
	return d;
}

- (instancetype)init
{
	if (self = [super init]) {
		self.backingParameters = [NSMutableArray array];
	}
	return self;
}

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)representation
{
	if (self = [self init]) {
		if ([representation isKindOfClass:[NSDictionary class]]) {
			_name = [[representation allKeys] firstObject];
			for (NSDictionary *d in [[representation allValues] firstObject]) {
				HNEDocumentParameter *p = [[HNEDocumentParameter alloc] initWithDictionaryRepresentation:d];
				[self.backingParameters addObject:p];
			}			
		} else {
			return nil;
		}
	}
	return self;
}

- (NSArray *)parameters
{
	return self.backingParameters;
}

- (void)setParameters:(NSArray *)parameters
{
	self.backingParameters = [NSMutableArray arrayWithArray:parameters];
}



#pragma mark - Serializing

- (NSDictionary *)dictionaryRepresentation
{
	NSMutableArray *parameterRepresentations = [NSMutableArray array];
	for (HNEDocumentParameter *p in self.parameters) {
		[parameterRepresentations addObject:[p dictionaryRepresentation]];
	}
	return @{self.name: parameterRepresentations};
}



#pragma mark - Add/remove parameters

- (void)addParameter:(HNEDocumentParameter *)parameter
{
	[self.backingParameters addObject:parameter];
}

- (void)removeParameter:(HNEDocumentParameter *)parameter
{
	[self.backingParameters removeObject:parameter];
}



#pragma mark - Keyed subscripting

/// Return a parameter with given name, or nil of it does not exist.
- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
	return [[self.backingParameters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", key]] firstObject];
}

/// Set a parameter to given value for given name
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
	NSInteger index = [self.backingParameters indexOfObject:self[key]];
	if (index != NSNotFound) {
		[self.backingParameters replaceObjectAtIndex:index withObject:obj];
	} else {
		[self.backingParameters addObject:obj];
	}
}



@end
