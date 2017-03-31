//
//  PWDeviceViewController.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"

@class PWDeviceViewController;

@protocol PWDeviceViewControllerDelegate <NSObject>

- (void)deviceViewControllerDidChangeStatus:(PWDeviceViewController *)deviceViewController;

@end

@interface PWDeviceViewController : UIViewController

@property (weak, nonatomic) id<PWDeviceViewControllerDelegate> delegate;
@property (nonatomic) NSInteger index;

- (instancetype)initWithDevice:(PWDevice *)device index:(NSInteger)index;

@end
