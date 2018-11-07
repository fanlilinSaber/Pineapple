//
//  PWAddLocalDeviceViewController.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
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

- (instancetype)initWithAbility:(PWAbility *)ability;

@end
