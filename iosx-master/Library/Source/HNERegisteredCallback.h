//
//  HoneRegisteredParameter.h
//  HoneExample
//
//  Created by Jaanus Kase on 31.12.13.
//
//

#import <Foundation/Foundation.h>
#import "HNEShared.h"
#import "HNEType.h"



@class HNEDocumentParameter, HNE;


/// A callback object for a specific document parameter
@interface HNERegisteredCallback : NSObject

- (instancetype)initWithHone:(HNE *)hone NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) void (^callbackBlock)(id, id);

@property (nonatomic, assign) HNEType valueDataType;
@property (nonatomic, copy) NSString *valueIdentifier;
@property (nonatomic, weak) id observer;
@property (nonatomic, copy) NSString *objectClass;

/// Run the callback with the given parameter.
- (void)runWithParameter:(HNEDocumentParameter *)parameter;

@end
