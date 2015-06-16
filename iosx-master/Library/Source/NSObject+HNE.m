//
//  NSObject+HNE.m
//  Hone-iosx
//
//  Created by Jaanus Kase on 10.11.14.
//
//

#import "NSObject+HNE.h"
#import "HNERegisteredWatcher.h"
#import "HNE.h"
#import "HNE+Private.h"
#import "HNEParameterStore.h"
#import "HNEParameterStore+Private.h"
#import "HNEDocumentObject.h"
#import "HNEDocumentParameter.h"
#import "HNEValueMapper.h"



NSString *const HNEIgnoredValueIdentifiers = @"HNEIgnoredValueIdentifiers";
NSString *const HNEOnlyValueIdentifiers = @"HNEOnlyValueIdentifiers";



@implementation NSObject (HNE)

- (void)bindToHoneObject:(NSString *)identifier
{
    [self bindToHoneObject:identifier options:nil];
}

- (void)bindToHoneObject:(NSString *)objectIdentifier options:(NSDictionary *)options
{
    NSSet *optionsIgnoredValueIdentifiers = options[HNEIgnoredValueIdentifiers];
    NSSet *optionsOnlyValueIdentifiers = options[HNEOnlyValueIdentifiers];
    
    if (optionsIgnoredValueIdentifiers && optionsOnlyValueIdentifiers) {
        [NSException raise:NSInvalidArgumentException format:@"Cannot specify both IgnoredValueIdentifiers and OnlyValueIdentifiers to Hone object binding"];
    }
    
    HNERegisteredWatcher *watcher = [[HNERegisteredWatcher alloc] init];
    watcher.observer = self;
    watcher.watchedIdentifiers = @[ objectIdentifier ];
    watcher.watcherCallbackBlock = ^(typeof(self) myself, NSArray *changed) {
        for (NSString *parameterId in changed) {
            NSDictionary *parsedParameterId = [parameterId parsedIdentifier];
            NSString *parameterName = parsedParameterId[IDENTIFIER_PARAMETER_NAME];
            
            NSSet *ignoredValueIdentifiers = [options objectForKey:HNEIgnoredValueIdentifiers];
            NSSet *onlyValueIdentifiers = [options objectForKey:HNEOnlyValueIdentifiers];
            
            if ((!ignoredValueIdentifiers && !onlyValueIdentifiers) ||
                (ignoredValueIdentifiers && ![ignoredValueIdentifiers containsObject:parameterName]) ||
                (onlyValueIdentifiers && [onlyValueIdentifiers containsObject:parameterName])) {
                
                // The callback should be run if one of these conditions is met:
                // 1) neither ignored nor “only” value identifiers are specified
                // 2) ignored identifiers are specified and do not contain the parameter name
                // 3) only identifiers are specified and DO contain the parameter name
                
                id parameterValue = [[HNE sharedHone].parameterStore parameterNativeValueForIdentifier:parsedParameterId[IDENTIFIER_PARAMETER_NAME] inClass:parsedParameterId[IDENTIFIER_CLASS_NAME]];
                
                BOOL valueMapperDidHandleValue = [[HNEValueMapper sharedValueMapper] didApplyHoneValue:parameterValue valueIdentifier:parsedParameterId[IDENTIFIER_PARAMETER_NAME] toObject:myself];
                if (!valueMapperDidHandleValue) {
                    [myself setValue:parameterValue forKeyPath:parsedParameterId[IDENTIFIER_PARAMETER_NAME]];
                }
                
            }
            
        }
    };
    
    [[HNE sharedHone] registerWatcher:watcher];
    
    
    
    // If there were specific value identifiers specified, capture the default values
    for (NSString *identifierToCapture in optionsOnlyValueIdentifiers) {
        
        id defaultValue = [self valueForKeyPath:identifierToCapture];
        
        HNEType type = HNETypeString;
        if ([defaultValue isKindOfClass:[NSString class]]) {
        }
        else if ([defaultValue isKindOfClass:[HNEFont class]]) {
            type = HNETypeFont;
        }
        else if ([defaultValue isKindOfClass:[HNEColor class]]) {
            type = HNETypeColor;
        }
        else if ([defaultValue isKindOfClass:[NSNumber class]]) {
            NSNumber *number = defaultValue;
            if (strcmp(number.objCType, "q") == 0) {
                // int
                type = HNETypeInt;
            } else if (strcmp(number.objCType, "c") == 0) {
                // bool
                type = HNETypeBool;
            } else if (strcmp(number.objCType, "d") == 0) {
                // float
                type = HNETypeFloat;
            }
        }
        
        HNEDocumentParameter *p = [[HNEDocumentParameter alloc] init];
        p.dataType = type;
        p.nativeValue = defaultValue;
        p.name = identifierToCapture;
        
        [[HNE sharedHone].parameterStore setParameter:p inClass:objectIdentifier theme:nil storeLevel:HNEParameterStoreLevelDefaultRegistered];
    }
    
    
    
    // Run the callback once at binding time, with all known identifiers for the object.
    
    NSMutableArray *initialIdentifiers = [NSMutableArray array];
    
    for (HNEDocumentObject *documentObject in [HNE sharedHone].parameterStore.documentObjects) {
        if ([documentObject.name isEqualToString:objectIdentifier]) {
            for (HNEDocumentParameter *parameter in [[HNE sharedHone].parameterStore parametersForDocumentObject:documentObject]) {
                [initialIdentifiers addObject:[NSString stringWithFormat:@"%@.%@", objectIdentifier, parameter.name]];
            }
        }
    }
    
    if (initialIdentifiers.count) {
        [watcher runWithChangedIdentifiers:initialIdentifiers];
    }
    
}

@end
