//
//  HoneParameterStore+Private.h
//  HoneExample
//
//  Created by Jaanus Kase on 21.05.14.
//
//



@class HNEDocumentParameter, HNEDocumentObject, HNE;



@interface HNEParameterStore ()

@property (strong, nonatomic) NSMutableArray *defaultDocumentObjects;
@property (strong, nonatomic) NSMutableArray *bonjourDocumentObjects;
@property (strong, nonatomic) NSMutableArray *diskDocumentObjects;
@property (strong, nonatomic) NSMutableArray *cloudDocumentObjects;

@property (weak, nonatomic) HNE *hone;

/// All parameter store HTTP request are dispatched here
@property (strong, nonatomic) dispatch_queue_t httpQueue;

/// All requests that modify the store, or want to enumerate the store or callbacks, should pass through this queue
@property (strong, nonatomic) dispatch_queue_t parameterStoreModifierQueue;

/// URL session used for device talkback, as well as fetching parameters from cloud
@property (strong, nonatomic) NSURLSession *talkbackSession;

/// Cloud service session, correctly pre-configured with things like authorization set up at Hone init time
@property (strong, nonatomic) NSURLSession *cloudServiceSession;

@property (strong, nonatomic) NSMutableSet *availableThemes;
@property (strong, nonatomic) NSMutableArray *activeThemes;

/// Return the matching document parameter. The usedTheme is the key for the theme whose parameter ended up being used
- (HNEDocumentParameter *)documentParameterForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier usedTheme:(out NSString **)usedTheme;

- (HNEDocumentParameter *)documentParameterForIdentifier:(NSString *)identifier inClass:(NSString *)classIdentifier;

/// Known document objects, with possibly incomplete parameter representations
- (NSArray *)documentObjects;

/// Aggregated parameters for a given object
- (NSArray *)parametersForDocumentObject:(HNEDocumentObject *)documentObject;

/// Known document objects, with values merged across all store levels, useful for read-only presentation, e.g in the server
- (NSArray *)mergedDocumentObjects;

@end
