//
//  PWAddDeviceViewController.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@class PWAddDeviceViewController;

@protocol PWAddDeviceViewControllerDelegate <NSObject>

- (void)addDeviceViewControllerDidSave:(PWAddDeviceViewController *)addDeviceViewController withDevice:(PWDevice *)device;

@end

@interface PWAddDeviceViewController : UIViewController

@property (weak, nonatomic) id<PWAddDeviceViewControllerDelegate> delegate;

@end
