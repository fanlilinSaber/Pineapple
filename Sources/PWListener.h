//
//  PWListener.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/31.
//
//

#import <Foundation/Foundation.h>
#import "PWLocalDevice.h"

@class PWListener;

@protocol PWListenerDelegate <NSObject>

- (void)listenerDidStartSuccess:(PWListener *)listener;
- (void)listenerDidStartFailed:(PWListener *)listener;
- (void)listener:(PWListener *)listener didConnectDevice:(PWLocalDevice *)device;

@end

@interface PWListener : NSObject

@property (weak, nonatomic) id<PWListenerDelegate> delegate;

- (instancetype)initWithPort:(NSInteger)port;

- (void)start;

@end
