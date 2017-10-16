//
//  PWConnectViewController.h
//  Pineapple
//
//  Created by 范李林 on 2017/10/16.
//
//

#import <UIKit/UIKit.h>
#import "Pineapple.h"
@interface PWConnectViewController : UIViewController
/*&* <##>*/
@property (nonatomic, strong) PWBluetooth *bluetoothClient;

@property (nonatomic, strong) CBPeripheral *peripheral;

@end
