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
- (void)device:(PWLocalDevice *)device didConnectFailedError:(NSError *)error;
- (void)deviceDidDisconnectSuccess:(PWLocalDevice *)device;
- (void)device:(PWLocalDevice *)device remoteDidDisconnectError:(NSError *)error;
- (void)device:(PWLocalDevice *)device didReceiveCommand:(PWCommand *)command;

@end

@interface PWLocalDevice : PWDevice

@property (weak, nonatomic) id<PWLocalDeviceDelegate> delegate;
@property (copy, nonatomic) NSString *host;
@property (nonatomic) int port;

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name host:(NSString *)host port:(int)port reconnect:(BOOL)reconnect;
- (instancetype)initWithAbility:(PWAbility *)ability socket:(GCDAsyncSocket *)socket;

- (BOOL)isConnected;
- (void)connect;
- (void)disconnect;
- (void)send:(PWCommand<PWCommandSendable> *)command;

@end
