//
//  HNEAppDelegate.m
//  HoneExampleOSX
//
//  Created by Jaanus Kase on 27.06.14.
//
//

#import "HNEOSXAppDelegate.h"
#import "HNEWindowController.h"
#import <HoneOSX/HoneOSX.h>



@interface HNEOSXAppDelegate ()

@property (strong, nonatomic) HNEWindowController *windowController;

@end



@implementation HNEOSXAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[HNE startWithAppIdentifier:@"53b423fc4e82e2211814cc64"
					  appSecret:@"zlvEEKM2/lzGMogdBTWzjK02+pDcgZGPu/qw0LM8g1s="
					documentURL:[[NSBundle mainBundle] URLForResource:@"OSX example" withExtension:@"hone"]
				developmentMode:YES
						  error:nil];

	// Insert code here to initialize your application
	self.windowController = [[HNEWindowController alloc] initWithWindowNibName:@"HNEWindowController"];
	[self.windowController.window makeKeyAndOrderFront:self];
	
}

@end
