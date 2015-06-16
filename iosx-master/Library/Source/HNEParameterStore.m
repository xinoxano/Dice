//
//  HoneParameterStore.m
//  HoneExample
//
//  Created by Jaanus Kase on 27.02.14.
//
//

#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEParameterStore+Cloud.h"

// model
#import "HNEDocumentObject.h"
#import "HNEDocumentParameter.h"
#import "HNEDocumentParameter+Private.h"
#import "HNE+Private.h"
#import "HNERegisteredCallback.h"
#import "HNERegisteredWatcher.h"

// helpers
#import "NSData+YamlFormatHacks.h"
#import <HNEYACYAML/HNEYACYAML.h>
#import "HNEError.h"



@implementation HNEParameterStore

- (instancetype)initWithHone:(HNE *)hone
{
	if (self = [super init]) {
		_hone = hone;
		_defaultDocumentObjects = [NSMutableArray array];
		_bonjourDocumentObjects = [NSMutableArray array];
		_diskDocumentObjects = [NSMutableArray array];
		_cloudDocumentObjects = [NSMutableArray array];
		_httpQueue = dispatch_queue_create("tools.hone.deviceTalkbackQueue", DISPATCH_QUEUE_SERIAL);
		_parameterStoreModifierQueue = dispatch_queue_create("tools.hone.parameterStoreModifierQueue", DISPATCH_QUEUE_SERIAL);
		_talkbackSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
	}
	return self;
}



#pragma mark - Value addition, retrieval

- (void)setParameter:(HNEDocumentParameter *)parameter inClass:(NSString *)classIdentifier theme:(NSString *)theme storeLevel:(HNEParameterStoreLevel)storeLevel
{
	dispatch_sync(self.parameterStoreModifierQueue, ^{
		
		BOOL changedValue = NO;
		
		NSMutableArray *targetStore = [self targetStoreForStoreLevel:storeLevel];
		
		HNEDocumentObject *documentObject = [[targetStore filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", classIdentifier]] firstObject];
		
		if (!documentObject) {
			documentObject = [[HNEDocumentObject alloc] init];
			documentObject.name = classIdentifier;
			[targetStore addObject:documentObject];
		}
		
		if (theme.length) {			
			HNEDocumentParameter *existing = documentObject[parameter.name];
			if (!existing) {
				existing = [[HNEDocumentParameter alloc] init];
				existing.name = parameter.name;
				existing.dataType = parameter.dataType;
			}
			
			HNEDocumentParameter *previousOverride = existing.backingValueOverrides[theme];
			if (![previousOverride.value isEqual:parameter.value]) {
				existing.backingValueOverrides[theme] = parameter;
				documentObject[parameter.name] = existing;
				changedValue = YES;
			}
			
			
		} else {
			
			HNEDocumentParameter *previous = documentObject[parameter.name];
			if (![previous.value isEqual:parameter.value]) {
				changedValue = YES;
                if (previous.backingValueOverrides) {
                    parameter.backingValueOverrides = previous.backingValueOverrides;
                }
				documentObject[parameter.name] = parameter;
			}
			
		}
		
		if (changedValue) {
			dispatch_async(self.parameterStoreModifierQueue, ^{
				[self didChangeValueForParameter:parameter inClass:documentObject.name];
			});
		}
	});
}

- (id)parameterNativeValueForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier
{
	NSString *usedTheme = @"";
	HNEDocumentParameter *p = [self documentParameterForIdentifier:identifier inClass:classIdentifier usedTheme:&usedTheme];
	if (!usedTheme) { usedTheme = @""; }
	[self talkbackParameterValueWithParameter:p class:classIdentifier theme:usedTheme error:nil];
	return p.nativeValue;
}

- (HNEDocumentParameter *)documentParameterForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier
{
	return [self documentParameterForIdentifier:identifier inClass:classIdentifier usedTheme:nil];
}

- (HNEDocumentParameter *)documentParameterForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier usedTheme:(out NSString *__autoreleasing *)usedTheme
{
	// should probably optimize this behavior to coalesce the value stores… if profiling ever shows that it’s a problem
	for (NSArray *store in [self prioritizedStores]) {
		HNEDocumentObject *documentObject = [[store filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", classIdentifier]] firstObject];
		if (documentObject) {
			HNEDocumentParameter *parameter = documentObject[identifier];
			HNEDocumentParameter *parameterToReturn = parameter;
			for (NSString *theme in self.activeThemes) {
				HNEDocumentParameter *themed = parameter.valueOverrides[theme];
				if (themed) {
					parameterToReturn = themed;
					if (usedTheme != NULL) {
						*usedTheme = theme;
					}
				}
			}
			
			if (parameterToReturn) { return parameterToReturn; }
		}
	}
		
	return nil;
}

/// Run post-parameter setting actions, such as run callbacks
- (void)didChangeValueForParameter:(HNEDocumentParameter *)parameter inClass:(NSString *)className
{
	HNEDocumentParameter *p = [self documentParameterForIdentifier:parameter.name inClass:className];
	if (!p) { return; }
	
	// Iterate over known callback blocks and run the callback
	
	for (id objectKey in self.hone.registeredCallbacks) {
		
		NSSet *callbacks = [self.hone.registeredCallbacks objectForKey:objectKey];
		
		// iterate over all parameters that changed
		for (HNERegisteredCallback *callback in callbacks) {
				
			// see if this parameter matches one that changed
			if ([className isEqualToString:callback.objectClass] && [p.name isEqualToString:callback.valueIdentifier]) {
				[callback runWithParameter:p];
			}
		}
	}
	
	// Iterate over general value change watchers
	// The watcher callback takes an array, but until we get to coalescing, the array will just contain one element
	NSString *compoundName = [[className stringByAppendingString:@"."] stringByAppendingString:parameter.name];
	for (id objectKey in self.hone.registeredWatchers) {
		NSSet *watchers = [self.hone.registeredWatchers objectForKey:objectKey];
		for (HNERegisteredWatcher *watcher in watchers) {
			BOOL shouldRunWatcher = NO;
			if (!watcher.watchedIdentifiers) {
				shouldRunWatcher = YES;
			} else if ([watcher.watchedIdentifiers containsObject:className]) {
				shouldRunWatcher = YES;
			} else if ([watcher.watchedIdentifiers containsObject:compoundName]) {
				shouldRunWatcher = YES;
			}
			
			if (shouldRunWatcher) {
				[watcher runWithChangedIdentifiers:@[compoundName]];
			}
		}
	}
}



#pragma mark - Themes

- (void)runBlockThatAffectsValues:(void (^)(void))block
{
	if (!block) { return; }
	
	// Capture initial values here…
	
	NSMutableDictionary *previousValues = [NSMutableDictionary dictionary];
	
	for (HNEDocumentObject *documentObject in [self documentObjects]) {
		if (!previousValues[documentObject.name]) { previousValues[documentObject.name] = [NSMutableDictionary dictionary]; };
		NSMutableDictionary *valueParameters = previousValues[documentObject.name];
		for (HNEDocumentParameter *documentParameter in [self parametersForDocumentObject:documentObject]) {
			valueParameters[documentParameter.name] = [self parameterNativeValueForIdentifier:documentParameter.name inClass:documentObject.name];
			
		}
		previousValues[documentObject.name] = valueParameters;
	}
	
	
	
	// Run the change
	
	block();
	
	
	// See what changed, and run callbacks
	
	// Run observer blocks for any changed values…
	for (HNEDocumentObject *documentObject in [self documentObjects]) {
		for (HNEDocumentParameter *documentParameter in [self parametersForDocumentObject:documentObject]) {
			
			id currentValue = [self parameterNativeValueForIdentifier:documentParameter.name inClass:documentObject.name];
			id previousValue = previousValues[documentObject.name][documentParameter.name];
			if (![currentValue isEqual:previousValue]) {
				[self didChangeValueForParameter:documentParameter inClass:documentObject.name];
			}
		}
	}
}

- (void)activateThemes:(NSArray *)themes
{
	[self runBlockThatAffectsValues:^{
		self.activeThemes = [NSMutableArray array];
		for (NSString *theme in themes) {
			if (![self.availableThemes containsObject:theme]) {
				[NSException raise:NSInvalidArgumentException format:@"Trying to activate theme “%@” that hasn’t been loaded", theme];
			}
			[self.activeThemes addObject:theme];
		}
	}];
	
}



#pragma mark - Filling a store

- (BOOL)loadHoneDocumentAtURL:(NSURL *)documentURL forStoreLevel:(HNEParameterStoreLevel)storeLevel error:(out NSError *__autoreleasing *)outError
{
	if (!documentURL.isFileURL) {
		if (outError != NULL) {
			*outError = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeDocumentMustBeFileURL userInfo:nil];
		}
		return NO;
	}
	
	NSMutableArray *targetStore = [self targetStoreForStoreLevel:storeLevel];
    [targetStore removeAllObjects];
    
	NSError *error = nil;
	
	// Load manifest
	
	NSURL *manifestUrl = [documentURL URLByAppendingPathComponent:@"manifest.yaml"];
	NSData *manifestData = [NSData dataWithContentsOfURL:manifestUrl options:0 error:&error];
	
	if (error) {
		if (outError != NULL) {
			*outError = error;
		}
		return NO;
	}
	
	manifestData = [manifestData dataWithDictionariesConvertedToArraysForLevels:3];
	NSArray *manifest = [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:manifestData];
	
	if (![manifest[0][@"format"] isEqualToNumber:@(1)]) {
		if (outError != NULL) {
			*outError = [NSError errorWithDomain:HNEErrorDomain code:HNEErrorCodeInvalidDocumentFormatVersion userInfo:nil];
		}
		return NO;
	}

	// First, populate the default theme
	NSURL *defaultThemeUrl = [documentURL URLByAppendingPathComponent:@"default"];
	NSURL *defaultValuesUrl = [defaultThemeUrl URLByAppendingPathComponent:@"values.yaml"];
	
	error = nil;
	
	NSData *defaultValuesData = [NSData dataWithContentsOfURL:defaultValuesUrl options:0 error:&error];
	if (error) {
		if (outError != NULL) {
			*outError = error;
		}
		return NO;
	}
	defaultValuesData = [defaultValuesData dataWithDictionariesConvertedToArraysForLevels:2];
	NSArray *defaultValuesArray = [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:defaultValuesData];
	
	for (NSDictionary *d in defaultValuesArray) {
		HNEDocumentObject *o = [[HNEDocumentObject alloc] initWithDictionaryRepresentation:d];
		if (o) {
			[targetStore addObject:o];
		}
	}
	
	// Then, iterate over the themes and merge the parameters into the individual values’ override dictionaries
	// Also, populate the available themes thing
	
	// Think about how to best handle and test this. Maybe it shouldn’t be tied to document? Can I refresh themes
	// from cloud as well?
	if (storeLevel == HNEParameterStoreLevelDocument) { self.availableThemes = [NSMutableSet set]; }
	
	NSDictionary *themesDictionary = nil;
	for (NSDictionary *dict in manifest) {
		if ([dict.allKeys.firstObject isEqualToString:@"resources"]) {
			themesDictionary = dict[@"resources"];
		}
	}
	
	for (NSDictionary *theme in themesDictionary) {
		NSString *themeName = [theme allKeys].firstObject;
		if ([themeName isEqualToString:@"default"]) { continue; } // skip default theme
		if (storeLevel == HNEParameterStoreLevelDocument) { [self.availableThemes addObject:themeName]; }
		NSURL *themeUrl = [documentURL URLByAppendingPathComponent:themeName];
		NSURL *themeValuesUrl = [themeUrl URLByAppendingPathComponent:@"values.yaml"];
		error = nil;
		
		NSData *themeValuesData = [NSData dataWithContentsOfURL:themeValuesUrl options:0 error:&error];
		if (error) {
			if (outError != NULL) {
				*outError = error;
			}
			return NO;
		}
		
		themeValuesData = [themeValuesData dataWithDictionariesConvertedToArraysForLevels:2];
		NSArray *themeValuesArray = [HNEYACYAMLKeyedUnarchiver unarchiveObjectWithData:themeValuesData];
		for (NSDictionary *d in themeValuesArray) {
			HNEDocumentObject *themeObject = [[HNEDocumentObject alloc] initWithDictionaryRepresentation:d];
			if (themeObject) {
				for (HNEDocumentParameter *p in themeObject.parameters) {
					HNEDocumentObject *realObject = [[targetStore filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", themeObject.name]] firstObject];
					HNEDocumentParameter *realParameter = realObject[p.name];
					realParameter.backingValueOverrides[themeName] = p;
				}
			}
		}
	}

	return YES;
}

- (NSInteger)numberOfParametersInStoreLevel:(HNEParameterStoreLevel)level
{
	NSMutableArray *store = [self targetStoreForStoreLevel:level];
	NSInteger items = 0;
	for (HNEDocumentObject *o in store) {
		items += o.parameters.count;
	}
	return items;
}

- (void)clearParameterStoreForLevel:(HNEParameterStoreLevel)level
{
	[self runBlockThatAffectsValues:^{
		NSMutableArray *targetStore = [self targetStoreForStoreLevel:level];
		[targetStore removeAllObjects];
		
		if (level == HNEParameterStoreLevelCloud) {
			NSURL *documentUrl = [self cloudDocumentFolder];
			[[NSFileManager defaultManager] removeItemAtURL:documentUrl error:nil];
		}
	}];
}



#pragma mark - Utilities

- (void)talkbackParameterValueWithParameter:(HNEDocumentParameter *)p class:(NSString *)className theme:(NSString *)theme error:(NSString *)errorString
{
	if (!self.hone.deviceTalkbackUrl) { return; }
	
	// This parameter transformation is ugly, should be done in a cleaner way.
	
	dispatch_async(self.httpQueue, ^{
		NSMutableDictionary *talkbackDict = [NSMutableDictionary dictionary];
		talkbackDict[@"time"] = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
		talkbackDict[@"device_guid"] = self.hone.deviceUuid.UUIDString;
		talkbackDict[@"object"] = className;
		talkbackDict[@"parameter"] = p.name;
		talkbackDict[@"theme"] = theme ? theme : @"";
		talkbackDict[@"project_id"] = self.hone.appId;
		if (errorString) {
			talkbackDict[@"error"] = errorString;
		}
		
		talkbackDict[@"parameter_type"] = [HNEDocumentParameter stringLabelForDataType:p.dataType];
		talkbackDict[@"value"] = p.value;
				
		NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.hone.deviceTalkbackUrl]];
		req.HTTPMethod = @"PUT";
		
		NSArray *talkbacks = @[talkbackDict];
		
		req.HTTPBody = [NSJSONSerialization dataWithJSONObject:talkbacks options:0 error:nil];
		
		[[self.talkbackSession dataTaskWithRequest:req] resume];
	});
	
}

- (NSMutableArray *)targetStoreForStoreLevel:(HNEParameterStoreLevel)storeLevel
{
	switch (storeLevel) {
		case HNEParameterStoreLevelDefaultRegistered:
			return self.defaultDocumentObjects;
			break;
		case HNEParameterStoreLevelBonjour:
			return self.bonjourDocumentObjects;
			break;
		case HNEParameterStoreLevelDocument:
			return self.diskDocumentObjects;
			break;
		case HNEParameterStoreLevelCloud:
			return self.cloudDocumentObjects;
			break;
	}
	
	return nil;
}

- (NSArray *)prioritizedStores
{
	return @[self.bonjourDocumentObjects, self.cloudDocumentObjects, self.diskDocumentObjects, self.defaultDocumentObjects];
}

- (NSArray *)documentObjects
{
	NSMutableArray *objs = [NSMutableArray array];
	for (NSArray *store in [self prioritizedStores]) {
		for (HNEDocumentObject *o in store) {
			HNEDocumentObject *foundO = [[objs filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", o.name]] firstObject];
			if (!foundO) {
				[objs addObject:o];
			}
		}
	}
	
	return objs;
}

- (NSArray *)parametersForDocumentObject:(HNEDocumentObject *)documentObject
{
	NSMutableArray *params = [NSMutableArray array];
	for (NSArray *store in [self prioritizedStores]) {
		HNEDocumentObject *o = [[store filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", documentObject.name]] firstObject];
		if (o) {
			for (HNEDocumentParameter *p in o.parameters) {
				HNEDocumentParameter *foundP = [[params filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", p.name]] firstObject];
				if (!foundP) {
					[params addObject:p];
				}
			}
		}
	}
	return params;
}

- (NSArray *)mergedDocumentObjects
{
	NSMutableArray *merged = [NSMutableArray array];
	for (HNEDocumentObject *o in self.documentObjects) {
		HNEDocumentObject *mergedObject = [[HNEDocumentObject alloc] init];
		mergedObject.name = o.name;
		mergedObject.parameters = [self parametersForDocumentObject:o];
		[merged addObject:mergedObject];
	}
	
	return merged;
}



@end
