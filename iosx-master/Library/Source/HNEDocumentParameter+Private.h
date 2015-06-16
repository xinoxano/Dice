//
//  DocumentParameter+Private.h
//  Hone
//
//  Created by Jaanus Kase on 12.05.14.
//
//
#import "HNEDocumentParameter.h"

@interface HNEDocumentParameter () {
	id _cachedNativeValue;
}

@property (nonatomic, strong) NSMutableDictionary *backingValueOverrides;

/// Add a value override to this parameter, overwriting any previous overrides for this theme. Does not do undo etc - public API for this is in documentModel.
- (void)addValueOverride:(id<HNEValueOverride>)override;

/// Remove an override from this parameter.
- (void)removeValueOverride:(id<HNEValueOverride>)override;

@end
