//
//  HNEDeveloperViewController.m
//  HOneExample
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import "HNEDeveloperViewController.h"
#import "NSLayoutConstraint+HNEHelpers.h"
#import "HNEParameterStore+Cloud.h"
#import "HNE+Private.h"



@interface HNEDeveloperViewController () {
	id parameterValueDidChangeObserver;
}

@property (strong, nonatomic) UILabel *cloudItemsLabel;
@property (strong, nonatomic) UILabel *cloudStatusLabel;
@property (strong, nonatomic) UILabel *documentStatusLabel;
@property (strong, nonatomic) UILabel *defaultsStatusLabel;
@property (strong, nonatomic) UILabel *bonjourItemsLabel;
@property (strong, nonatomic) UIButton *clearCloudButton;
@property (strong, nonatomic) UIButton *clearBonjourButton;

@end



@implementation HNEDeveloperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
	self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	self.title = @"Hone";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
	
	self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];

	[self prepareBonjourUi];
	[self prepareCloudUi];
	[self prepareDocumentUi];
	[self prepareDefaultsUi];
	
	[self reloadUi];
	// bonjour title
	
	__weak HNEDeveloperViewController *weakSelf = self;
	
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:parameterValueDidChangeObserver];
}



#pragma mark - Public API

+ (UIViewController *)containedViewControllerForPresentation
{
	HNEDeveloperViewController *dev = [[HNEDeveloperViewController alloc] initWithNibName:nil bundle:nil];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dev];
	return nav;
}



#pragma mark - Actions

- (void)clearBonjour:(UIButton *)sender
{
	[[HNE sharedHone].parameterStore clearParameterStoreForLevel:HNEParameterStoreLevelBonjour];
	[self reloadUi];
}

- (void)clearCloud:(UIButton *)sender
{
	[[HNE sharedHone].parameterStore clearParameterStoreForLevel:HNEParameterStoreLevelCloud];
	[self reloadUi];
}

- (void)updateFromCloud:(UIButton *)sender
{
	self.cloudStatusLabel.text = @"Pulling new values from cloud…";
	[[HNE sharedHone].parameterStore updateFromCloudWithCompletionBlock:^(BOOL success, BOOL valuesChanged, NSError *error)
	{
		if (success) {
			if (valuesChanged) {
				self.cloudStatusLabel.text = @"New values pulled from cloud.";
			} else {
				self.cloudStatusLabel.text = @"Nothing changed.";
			}
		} else {
			self.cloudStatusLabel.text = @"Error pulling values from cloud.";
		}
		[self reloadUi];
	 }];
}

- (void)done:(UIBarButtonItem *)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Utilities

- (void)prepareBonjourUi
{
	// Bonjour title
	
	UILabel *bonjourTitle = [[UILabel alloc] initWithFrame:CGRectZero];
	bonjourTitle.translatesAutoresizingMaskIntoConstraints = NO;
	bonjourTitle.text = @"Values received over local network";
	bonjourTitle.font = [UIFont boldSystemFontOfSize:14];
	[self.view addSubview:bonjourTitle];

	id topGuide = self.topLayoutGuide;
	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(topGuide, bonjourTitle);
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-8-[bonjourTitle]" options:0 metrics:nil views:viewsDictionary]];
	
	[bonjourTitle HNEaddConstraintForAligningLeftToLeftOfView:self.view distance:8.0f];

	// Bonjour status
	
	self.bonjourItemsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.bonjourItemsLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.bonjourItemsLabel.text = @"Bonjour items info";
	self.bonjourItemsLabel.font = [UIFont systemFontOfSize:9];
	[self.view addSubview:self.bonjourItemsLabel];
	
	[self.bonjourItemsLabel HNEaddConstraintForAligningLeftToLeftOfView:bonjourTitle distance:0];
	[self.bonjourItemsLabel HNEaddConstraintForAligningTopToBottomOfView:bonjourTitle distance:0];
	
	self.clearBonjourButton = [UIButton buttonWithType:UIButtonTypeSystem];
	self.clearBonjourButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.clearBonjourButton setTitle:@"Clear" forState:UIControlStateNormal];
	[self.view addSubview:self.clearBonjourButton];
	[self.clearBonjourButton HNEaddConstraintForAligningTopToBottomOfView:self.bonjourItemsLabel distance:0];
	[self.clearBonjourButton HNEaddConstraintForAligningLeftToLeftOfView:bonjourTitle distance:0];
	[self.clearBonjourButton addTarget:self action:@selector(clearBonjour:) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void)prepareCloudUi
{
	// Cloud title
	UILabel *cloudTitle = [[UILabel alloc] initWithFrame:CGRectZero];
	cloudTitle.translatesAutoresizingMaskIntoConstraints = NO;
	cloudTitle.text = @"Cloud values";
	cloudTitle.font = [UIFont boldSystemFontOfSize:14];
	[self.view addSubview:cloudTitle];
	
	[cloudTitle HNEaddConstraintForAligningTopToBottomOfView:self.clearBonjourButton distance:16];
	[cloudTitle HNEaddConstraintForAligningLeftToLeftOfView:self.view distance:8.0f];
	
	// Cloud number of items and last updated
	
	self.cloudItemsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.cloudItemsLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.cloudItemsLabel.text = @"Some info about cloud items";
	self.cloudItemsLabel.font = [UIFont systemFontOfSize:9];
	[self.view addSubview:self.cloudItemsLabel];
	
	[self.cloudItemsLabel HNEaddConstraintForAligningLeftToLeftOfView:cloudTitle distance:0];
	[self.cloudItemsLabel HNEaddConstraintForAligningTopToBottomOfView:cloudTitle distance:0];
	
	// Cloud download status
	
	self.cloudStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.cloudStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.cloudStatusLabel.font = [UIFont systemFontOfSize:9];
	[self.view addSubview:self.cloudStatusLabel];
	
	[self.cloudStatusLabel HNEaddConstraintForAligningLeftToLeftOfView:cloudTitle distance:0];
	[self.cloudStatusLabel HNEaddConstraintForAligningTopToBottomOfView:self.cloudItemsLabel distance:4];
	
	// Clear cloud button
	
	self.clearCloudButton = [UIButton buttonWithType:UIButtonTypeSystem];
	self.clearCloudButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.clearCloudButton setTitle:@"Clear" forState:UIControlStateNormal];
	[self.view addSubview:self.clearCloudButton];
	
	[self.clearCloudButton HNEaddConstraintForAligningTopToBottomOfView:self.cloudStatusLabel distance:0];
	[self.clearCloudButton HNEaddConstraintForAligningLeftToLeftOfView:cloudTitle distance:0];
	[self.clearCloudButton addTarget:self action:@selector(clearCloud:) forControlEvents:UIControlEventTouchUpInside];
	
	// Refresh from cloud button
	
	UIButton *cloudButton = [UIButton buttonWithType:UIButtonTypeSystem];
	cloudButton.translatesAutoresizingMaskIntoConstraints = NO;
	[cloudButton setTitle:@"Pull from cloud" forState:UIControlStateNormal];
	[self.view addSubview:cloudButton];
	
	[cloudButton HNEaddConstraintForAligningLeftToRightOfView:self.clearCloudButton distance:32];
	[cloudButton HNEaddConstraintForAligningTopToTopOfView:self.clearCloudButton distance:0];
	[cloudButton addTarget:self action:@selector(updateFromCloud:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareDocumentUi
{
	// Document title
	
	UILabel *documentTitle = [[UILabel alloc] initWithFrame:CGRectZero];
	documentTitle.translatesAutoresizingMaskIntoConstraints = NO;
	documentTitle.text = @"Values from bundled document";
	documentTitle.font = [UIFont boldSystemFontOfSize:14];
	[self.view addSubview:documentTitle];
	
	[documentTitle HNEaddConstraintForAligningTopToBottomOfView:self.clearCloudButton distance:16];
	[documentTitle HNEaddConstraintForAligningLeftToLeftOfView:self.view distance:8.0f];
	
	// Document status
	
	self.documentStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.documentStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.documentStatusLabel.text = @"Document items info";
	self.documentStatusLabel.font = [UIFont systemFontOfSize:9];
	[self.view addSubview:self.documentStatusLabel];
	
	[self.documentStatusLabel HNEaddConstraintForAligningLeftToLeftOfView:documentTitle distance:0];
	[self.documentStatusLabel HNEaddConstraintForAligningTopToBottomOfView:documentTitle distance:0];
}

- (void)prepareDefaultsUi
{
	// Defaults title
	
	UILabel *defaultsTitle = [[UILabel alloc] initWithFrame:CGRectZero];
	defaultsTitle.translatesAutoresizingMaskIntoConstraints = NO;
	defaultsTitle.text = @"Values from code";
	defaultsTitle.font = [UIFont boldSystemFontOfSize:14];
	[self.view addSubview:defaultsTitle];
	
	[defaultsTitle HNEaddConstraintForAligningTopToBottomOfView:self.documentStatusLabel distance:16];
	[defaultsTitle HNEaddConstraintForAligningLeftToLeftOfView:self.view distance:8.0f];
	
	// Defaults status
	
	self.defaultsStatusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	self.defaultsStatusLabel.translatesAutoresizingMaskIntoConstraints = NO;
	self.defaultsStatusLabel.text = @"Defaults items info";
	self.defaultsStatusLabel.font = [UIFont systemFontOfSize:9];
	[self.view addSubview:self.defaultsStatusLabel];
	
	[self.defaultsStatusLabel HNEaddConstraintForAligningLeftToLeftOfView:defaultsTitle distance:0];
	[self.defaultsStatusLabel HNEaddConstraintForAligningTopToBottomOfView:defaultsTitle distance:0];
	
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
	
	self.bonjourItemsLabel.text = [NSString stringWithFormat:@"Number of values from local network: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelBonjour]];
	
	self.documentStatusLabel.text = [NSString stringWithFormat:@"Number of values from bundled document: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelDocument]];
	
	self.defaultsStatusLabel.text = [NSString stringWithFormat:@"Number of values from code: %ld", (long)[[HNE sharedHone].parameterStore numberOfParametersInStoreLevel:HNEParameterStoreLevelDefaultRegistered]];
	
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
	
	self.cloudItemsLabel.text = cloudText;
	
	self.cloudStatusLabel.text = @"Ready to pull.";
}

@end
