//
//  HNEDeveloperViewController.h
//  HoneExample
//
//  Created by Jaanus Kase on 12.06.14.
//
//

#import <UIKit/UIKit.h>


/*!
 @class HNEDeveloperViewController
 @abstract Presents a developer UI that lets the user see and configure the state of the Hone system on the device.
 @discussion You can present this view controller to your users during the design phase of the app to let the users of the app (who is probably the app designer, developer or tester at that point) understand the current state of the Hone system, as well as perform certain actions like pull parameters from the cloud, clear caches of previously pulled parameters etc.
 
 This view controller is only available in Hone development mode. It will raise an exception if attempted to be used in production mode.
 */
@interface HNEDeveloperViewController : UIViewController

/*!
 Return a view controller that is suitable for modal presentation.
 @discussion The returned view controller is a UINavigationController that contains HNEDeveloperViewController. You can present the navigation controller modally, and it has appropriate UI for dismissing the modal.
*/
 + (UIViewController *)containedViewControllerForPresentation;

@end
