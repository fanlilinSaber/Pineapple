//
//  PWAddRemoteDeviceViewController.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/18.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@class PWAddRemoteDeviceViewController;

@protocol PWAddRemoteDeviceViewControllerDelegate <NSObject>

- (void)addRemoteDeviceViewControllerDidSave:(PWAddRemoteDeviceViewController *)addRemoteDeviceViewController withDevice:(PWRemoteDevice *)device;

@end

@interface PWAddRemoteDeviceViewController : UIViewController

@property (weak, nonatomic) id<PWAddRemoteDeviceViewControllerDelegate> delegate;

@end
