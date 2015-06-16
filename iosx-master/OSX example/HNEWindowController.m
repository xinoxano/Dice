//
//  HNEWindow.m
//  HoneExample
//
//  Created by Jaanus Kase on 27.06.14.
//
//

#import "HNEWindowController.h"
#import <HoneOSX/HoneOSX.h>



@interface HNEWindowController ()

@property (weak) IBOutlet NSView *customView;
@property (weak) IBOutlet NSTextField *label;
@property (weak) IBOutlet NSLayoutConstraint *boxWidthConstraint;
@property (strong, nonatomic) HNEDeveloperWindowController *honeDevUi;

@end



@implementation HNEWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	
	[self.customView setWantsLayer:YES];
    [self.customView bindToHoneObject:@"box"
                              options: @{
                                         HNEIgnoredValueIdentifiers: [NSSet setWithArray:@[@"boxWidthConstraint.constant", @"label.font", @"label.stringValue"]]
                                        }];
    
    [self bindToHoneObject:@"box"
                   options:@{
                             HNEIgnoredValueIdentifiers: [NSSet setWithArray:@[@"layer.backgroundColor"]]}];
}

- (IBAction)showHoneDeveloperUi:(NSButton *)sender {
	if (!self.honeDevUi) {
		self.honeDevUi = [[HNEDeveloperWindowController alloc] initWithWindowNibName:@"HNEDeveloperWindowController"];
	}
	[self.honeDevUi showWindow:self];
}

@end
