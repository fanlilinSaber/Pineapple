//
//  PWAddLocalDeviceViewController.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@class PWAddLocalDeviceViewController;

@protocol PWAddLocalDeviceViewControllerDelegate <NSObject>

- (void)addLocalDeviceViewControllerDidSave:(PWAddLocalDeviceViewController *)addLocalDeviceViewController withDevice:(PWLocalDevice *)device;

@end

@interface PWAddLocalDeviceViewController : UIViewController

@property (weak, nonatomic) id<PWAddLocalDeviceViewControllerDelegate> delegate;

@end
