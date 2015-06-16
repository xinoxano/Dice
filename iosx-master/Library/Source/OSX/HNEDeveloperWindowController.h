//
//  HNEDeveloperWindowController.h
//  HoneExample
//
//  Created by Jaanus Kase on 11.07.14.
//
//

#import <Cocoa/Cocoa.h>

/**
 @abstract
 A self-contained window controller that provides UI to the Hone state
 and lets you perform some manipulations like clearing categories of values
 or pulling new values from cloud.
 
 @discussion
 Instantiate it with standard window controller techniques. You might want to do
 something like this from a menu or button action:
 
 if (!self.honeDeveloperWindowController) {
   self.honeDeveloperWindowController = [[HNEDeveloperWindowController alloc] initWithWindowNibName:@"HNEDeveloperWindowController";
 }
 [self.honeDeveloperWindowController showWindow:self];
 */
@interface HNEDeveloperWindowController : NSWindowController

@end
