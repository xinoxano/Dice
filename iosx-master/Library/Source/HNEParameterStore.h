//
//  HoneParameterStore.h
//  HoneExample
//
//  Created by Jaanus Kase on 27.02.14.
//
//

#import <Foundation/Foundation.h>
#import "HNEShared.h"
#import "HNEType.h"



@class HNEDocumentParameter, HNE;



typedef NS_ENUM(NSInteger, HNEParameterStoreLevel) {
	
	/// Values received during editing over Bonjour.
	HNEParameterStoreLevelBonjour,
	
	/// Values received from Hone cloud service
	HNEParameterStoreLevelCloud,
	
	/// Values loaded from Hone document
	HNEParameterStoreLevelDocument,
	
	/// Default values registered from application.
	HNEParameterStoreLevelDefaultRegistered
};


/// Encapsulates a set of document objects, each containing a set of parameters. May be backed by in-memory values manipulated in real time, files on disk etc.

@interface HNEParameterStore : NSObject

- (instancetype)initWithHone:(HNE *)hone NS_DESIGNATED_INITIALIZER;

/// Set a value on the specified store level. Theme can be nil or empty string to indicate “default” treatment.
- (void)setParameter:(HNEDocumentParameter *)parameter inClass:(NSString *)classIdentifier theme:(NSString *)theme storeLevel:(HNEParameterStoreLevel)storeLevel;

/// Return the current value of the DocumentParameter, considering store priority order and themes.
- (id)parameterNativeValueForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier;

/// Reset the document store with content of Hone document at the indicated URL. Returns YES if document could be loaded, NO if not.
- (BOOL)loadHoneDocumentAtURL:(NSURL *)documentURL forStoreLevel:(HNEParameterStoreLevel)storeLevel error:(out NSError **)error;

/// Activate the list of themes. The order is important, value lookup will happen in exactly this order. If no matching value is found from any themes, the value from “default” is used. You shouldn’t specify “default” in this list, it’s always implied to be the last one/fallback. Pass nil or empty array to clear out any themes and just use the default.
- (void)activateThemes:(NSArray *)themes;

/// Run any code that changes the parameter values in effect. The method resolves which values actually changed and only calls the relevant callbacks, so that not all callbacks would be called.
- (void)runBlockThatAffectsValues:(void (^)(void))block;

/// For diagnostic/developer UI purposes, report the number of items.
- (NSInteger)numberOfParametersInStoreLevel:(HNEParameterStoreLevel)level;

/// Clear out the indicated store, and also its backing store.
- (void)clearParameterStoreForLevel:(HNEParameterStoreLevel)level;

/// Talk back a parameter value access to the host, possibly with error.
- (void)talkbackParameterValueWithParameter:(HNEDocumentParameter *)p class:(NSString *)className theme:(NSString *)theme error:(NSString *)errorString;

@end
