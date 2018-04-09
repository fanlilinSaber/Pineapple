//
//  PWAddRMQViewController.h
//  Pineapple iOS Example
//
//  Created by 范李林 on 2018/3/8.
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@class PWAddRMQViewController;

@protocol PWAddRMQViewControllerDelegate <NSObject>

- (void)addMQDeviceViewControllerDidSave:(PWAddRMQViewController *)addMQDeviceViewController withDevice:(PWMQDevice *)device;

@end

@interface PWAddRMQViewController : UIViewController

@property (weak, nonatomic) id<PWAddRMQViewControllerDelegate> delegate;

- (instancetype)initWithAbility:(PWAbility *)ability;

@end
