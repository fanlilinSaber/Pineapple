//
//  PWListener.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/31.
//
//

#import <Foundation/Foundation.h>
#import "PWDevice.h"

extern NSInteger const PWListenerPort;

@class PWListener;

@protocol PWListenerDelegate <NSObject>

- (void)listenerDidStartSuccess:(PWListener *)listener;
- (void)listenerDidStartFailed:(PWListener *)listener;
- (void)listener:(PWListener *)listener didConnectDevice:(PWDevice *)device;

@end

@interface PWListener : NSObject

@property (weak, nonatomic) id<PWListenerDelegate> delegate;

- (void)start;

@end
