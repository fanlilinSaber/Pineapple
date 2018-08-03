//
//  PWListener.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/31.
//
//

#import <UIKit/UIKit.h>
#import "PWLocalDevice.h"

@class PWListener;

@protocol PWListenerDelegate <NSObject>

- (void)listenerDidStartSuccess:(PWListener *)listener;
- (void)listenerDidStartFailed:(PWListener *)listener;
- (void)listener:(PWListener *)listener didConnectDevice:(PWLocalDevice *)device;

@end

@interface PWListener : NSObject

@property (weak, nonatomic) id<PWListenerDelegate> delegate;

- (instancetype)initWithAbility:(PWAbility *)ability port:(NSInteger)port;

- (void)start;

- (void)disconnect;
@end
