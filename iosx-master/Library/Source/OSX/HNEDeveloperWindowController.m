//
//  HNEDeveloperWindowController.m
//  HoneExample
//
//  Created by Jaanus Kase on 11.07.14.
//
//

#import "HNEDeveloperWindowController.h"
#import "HNE.h"
#import "HNEParameterStore+Cloud.h"
#import "HNE+Private.h"



@interface HNEDeveloperWindowController () {
	id parameterValueDidChangeObserver;
}
@property (weak) IBOutlet NSTextField *bonjourItemsLabel;
@property (weak) IBOutlet NSTextField *documentStatusLabel;
@property (weak) IBOutlet NSTextField *defaultsStatusLabel;
@property (weak) IBOutlet NSTextField *cloudItemsLabel;
@property (weak) IBOutlet NSTextField *cloudStatusLabel;

@end



@implementation HNEDeveloperWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
		
		__weak HNEDeveloperWindowController *weakSelf = self;
		parameterValueDidChangeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:HNEDidReceiveValuesFromLocalNetworkNotification
																							object:nil
																							 queue:nil
																						usingBlock:^(NSNotification *note)
										   {
											   dispatch_async(dispatch_get_main_queue(), ^{
												   [weakSelf reloadUi];
											   });
										   }];
		
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	[self reloadUi];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	[self reloadUi];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:parameterValueDidChangeObserver];
}

/// Reload content of the UI based on the current state of the system.
- (void)reloadUi
{
	static NSDateFormatter *cloudDateFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cloudDateFormatter = [[NSDateFormatter alloc] init];
		cloudDateFormatter.timeStyle = NSDateFormatterMediumStyle;
		cloudDateFormatter.dateStyle = NSDateFormatterMediumStyle;
	});
	
	self.bonjourItemsLabel.stringValue = [NSString stringWithFormat:@"Number of values received from local network: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelBonjour]];
	
	self.documentStatusLabel.stringValue = [NSString stringWithFormat:@"Number of values from bundled document: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelDocument]];
	
	self.defaultsStatusLabel.stringValue = [NSString stringWithFormat:@"Number of values from code: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelDefaultRegistered]];
	
	// More about cloud
	
	long cloudItems = (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelCloud];
	
	NSURL *cloudManifestUrl = [[HNE sharedHone].parameterStore.cloudDocumentFolder URLByAppendingPathComponent:@"manifest.yaml"];
	NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[cloudManifestUrl path] error:nil];
	NSDate *date = [attributes fileModificationDate];
	
	NSString *cloudText = [NSString stringWithFormat:@"Number of values from cloud: %ld", cloudItems];
	if (date) {
		cloudText = [cloudText stringByAppendingString:@", updated "];
		cloudText = [cloudText stringByAppendingString:[cloudDateFormatter stringFromDate:date]];
	}
	
	self.cloudItemsLabel.stringValue = cloudText;
	
	self.cloudStatusLabel.stringValue = @"Ready to pull.";
}


#pragma mark - Actions

- (IBAction)clearBonjour:(NSButton *)sender
{
	[[HNE sharedHone].parameterStore clearParameterStoreForLevel:HNEParameterStoreLevelBonjour];
	[self reloadUi];
}

- (IBAction)clearCloud:(NSButton *)sender
{
	[[HNE sharedHone].parameterStore clearParameterStoreForLevel:HNEParameterStoreLevelCloud];
	[self reloadUi];
}

- (IBAction)updateFromCloud:(NSButton *)sender
{
	self.cloudStatusLabel.stringValue = @"Pulling new values from cloud…";
	[[HNE sharedHone].parameterStore updateFromCloudWithCompletionBlock:^(BOOL success, BOOL valuesChanged, NSError *error)
	 {
		 if (success) {
			 if (valuesChanged) {
				 self.cloudStatusLabel.stringValue = @"New values pulled from cloud.";
			 } else {
				 self.cloudStatusLabel.stringValue = @"Nothing changed.";
			 }
		 } else {
			 self.cloudStatusLabel.stringValue = @"Error pulling values from cloud.";
		 }
		 [self reloadUi];
	 }];
}

@end
