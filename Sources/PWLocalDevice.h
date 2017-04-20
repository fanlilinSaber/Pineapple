//
//  PWLocalDevice.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <UIKit/UIKit.h>
#import "PWDevice.h"
#import "PWAbility.h"

@class PWLocalDevice, GCDAsyncSocket;

@protocol PWLocalDeviceDelegate <NSObject>

- (void)deviceDidConnectSuccess:(PWLocalDevice *)device;
- (void)device:(PWLocalDevice *)device didConnectFailedMessage:(NSString *)message;
- (void)deviceDidDisconnectSuccess:(PWLocalDevice *)device;
- (void)device:(PWLocalDevice *)device didDisconnectFailedMessage:(NSString *)message;
- (void)device:(PWLocalDevice *)device didReceiveCommand:(PWCommand *)command;

@end

@interface PWLocalDevice : PWDevice

@property (weak, nonatomic) id<PWLocalDeviceDelegate> delegate;
@property (copy, nonatomic) NSString *host;
@property (nonatomic) int port;

- (instancetype)initWithName:(NSString *)name host:(NSString *)host port:(int)port reconnect:(BOOL)reconnect;
- (instancetype)initWithSocket:(GCDAsyncSocket *)socket;

- (BOOL)isConnected;
- (void)connect;
- (void)disconnect;
- (void)send:(PWCommand<PWCommandSendable> *)command;

@end
