//
//  HNEDeviceServer.h
//  HOne
//
//  Created by Jaanus Kase on 16.05.14.
//
//

#import <Foundation/Foundation.h>



@class HNE;



@interface HNEDeviceServer : NSObject

- (instancetype)initWithHone:(HNE *)hone NS_DESIGNATED_INITIALIZER;

- (void)startServer;

- (void)stopServer;

@end
