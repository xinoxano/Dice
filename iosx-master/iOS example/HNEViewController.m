//
//  HNEViewController.m
//  HoneExample
//
//  Created by Jaanus Kase on 18.12.13.
//
//

#import "HNEViewController.h"
#import <HoneIOS/HoneIOS.h>
#import "HNETestView.h"



@interface HNEViewController ()

@end



@implementation HNEViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	
	[HNE bindUIColorIdentifier:@"boxes.backgroundColor" object:self keyPath:@"view.backgroundColor"];

	[HNE bindCGFloatIdentifier:@"oneBox.size" defaultValue:64 object:self block:^(HNEViewController *vc, CGFloat newSize)
	{
		for (UIView *v in vc.view.subviews) {
			if ([v isKindOfClass:[HNETestView class]]) {
				CGRect frame = v.frame;
				frame.size.width = newSize;
				frame.size.height = newSize;
				v.frame = frame;
			}
		}
	}];
	
	self.title = @"Hello boxes";
	
	[HNE bindNSStringIdentifier:@"boxes.title" object:self keyPath:@"title"];
	
	[HNE bindNSIntegerIdentifier:@"boxes.numberOfBoxes" defaultValue:4 object:self block:^(HNEViewController *vc, NSInteger newValue)
	{
		[vc reloadBoxes:newValue];
	}];
	
	[HNE prepareDeveloperUiWithViewController:self view:self.view];

	// For development of the cloud downloader, auto-load the developer VC
//	dispatch_async(dispatch_get_main_queue(), ^{
//		UIViewController *vc = [HNEDeveloperViewController containedViewControllerForPresentation];
//		[self presentViewController:vc animated:YES completion:nil];
//	});
	
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	// when not calling this, there is a dangling callback left in Hone’s registered parameters table, but no references to this actual object
	//[HNE removeHoneObserver:self];
}



#pragma mark - Gesture recognizers

- (void)didTapBox:(UITapGestureRecognizer *)tapper
{
	if (tapper.state == UIGestureRecognizerStateRecognized) {
		
		CGAffineTransform currentTransform = tapper.view.transform;
		CGFloat targetScale = [HNE CGFloatWithHoneIdentifier:@"oneBox.animationScale" defaultValue:1.4];
		
		CGFloat firstLength = [HNE CGFloatWithHoneIdentifier:@"oneBox.firstAnimationLength" defaultValue:2];
		
		[UIView animateWithDuration:firstLength animations:^{
			tapper.view.alpha = [HNE CGFloatWithHoneIdentifier:@"oneBox.animationAlpha" defaultValue:0.4];
			tapper.view.transform = CGAffineTransformScale(currentTransform, targetScale, targetScale);
		} completion:^(BOOL finished)
		{
			CGFloat secondLength = [HNE CGFloatWithHoneIdentifier:@"oneBox.secondAnimationLength" defaultValue:1];
			[UIView animateWithDuration:secondLength animations:^{
				tapper.view.alpha = 1;
				tapper.view.transform = currentTransform;
			}];
		}];
		
	}	
}



#pragma mark - Button actions

- (IBAction)themeValueChanged:(UISegmentedControl *)sender {
	if (sender.selectedSegmentIndex == 0) {
		[HNE activateThemes:nil];
	} else {
		[HNE activateThemes:@[@"newTheme"]];
	}
}



#pragma mark - Utilities

- (void)reloadBoxes:(NSInteger)numberOfBoxes
{
	for (UIView *v in self.view.subviews) {
		if ([v isKindOfClass:[HNETestView class]]) {
			[v removeFromSuperview];
		}
	}
	
	for (NSInteger i = 0; i < numberOfBoxes; i++) {
		
		CGFloat size = [HNE CGFloatWithHoneIdentifier:@"oneBox.size"];
        
		int x = arc4random_uniform(self.view.bounds.size.width - size);
		int y = arc4random_uniform(self.view.bounds.size.height - size);
		
		UIView *box = [[HNETestView alloc] initWithFrame:CGRectMake(x, y, size, size)];
		[self.view addSubview:box];
		
		UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBox:)];
		[box addGestureRecognizer:tapper];
	}
}



@end
