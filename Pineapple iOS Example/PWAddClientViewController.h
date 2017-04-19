//
//  PWAddClientViewController.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@class PWAddClientViewController;

@protocol PWAddClientViewControllerDelegate <NSObject>

- (void)addClientViewControllerDidSave:(PWAddClientViewController *)addClientViewController withClient:(PWClient *)client;

@end

@interface PWAddClientViewController : UIViewController

@property (weak, nonatomic) id<PWAddClientViewControllerDelegate> delegate;

@end
