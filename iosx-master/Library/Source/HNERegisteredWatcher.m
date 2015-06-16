//
//  HNERegisteredWatcher.m
//  Hone
//
//  Created by Jaanus Kase on 14.07.14.
//
//

#import "HNERegisteredWatcher.h"

@implementation HNERegisteredWatcher

- (void)runWithChangedIdentifiers:(NSArray *)changedIdentifiers
{
	void (^executor)(void) = ^{
		self.watcherCallbackBlock(self.observer, changedIdentifiers);
	};
	
	if ([NSThread isMainThread]) {
		executor();
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			executor();
		});
	}
}

@end
