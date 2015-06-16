//
//  HNERegisteredWatcher.h
//  HoneExample
//
//  Created by Jaanus Kase on 14.07.14.
//
//

#import <Foundation/Foundation.h>


/// A callback object that does not manage any values on its own, but just watches the changes
@interface HNERegisteredWatcher : NSObject

/// Callback with the observer object and an array of the values that actually changed
@property (nonatomic, copy) void (^watcherCallbackBlock)(id, NSArray *);
@property (nonatomic, weak) id observer;

/// Array of NSStrings. Can be either “category”, or “category.identifier” style. Also the whole thing can be nil, which means “watch everything”
@property (nonatomic, copy) NSArray *watchedIdentifiers;

- (void)runWithChangedIdentifiers:(NSArray *)changedIdentifiers;

@end
