//
//  PWDevice.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>
#import "PWAbility.h"

@class PWDevice, GCDAsyncSocket;

@protocol PWDeviceDelegate <NSObject>

- (void)deviceDidConnectSuccess:(PWDevice *)device;
- (void)deviceDidConnectFailed:(PWDevice *)device;
- (void)deviceDidDisconnectSuccess:(PWDevice *)device;
- (void)deviceDidDisconnectFailed:(PWDevice *)device;
- (void)device:(PWDevice *)device didReceiveCommand:(PWCommand *)command;

@end

@interface PWDevice : NSObject

@property (weak, nonatomic) id<PWDeviceDelegate> delegate;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *host;
@property (nonatomic) int port;

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name host:(NSString *)host port:(int)port;
- (instancetype)initWithAbility:(PWAbility *)ability socket:(GCDAsyncSocket *)socket;

- (BOOL)isConnected;
- (void)connect;
- (void)disconnect;
- (void)send:(PWCommand<PWCommandSendable> *)command;

@end
