//
//  PWLocalDevice.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/27.
//
//

#import <UIKit/UIKit.h>
#import "PWDevice.h"
#import "PWAbility.h"

@class PWLocalDevice, GCDAsyncSocket;
// protocol
@protocol PWLocalDeviceDelegate <NSObject>
@optional
// socket 连接成功
- (void)deviceDidConnectSuccess:(PWLocalDevice *)device;
// socket 连接失败
- (void)device:(PWLocalDevice *)device didConnectFailedError:(NSError *)error;
// socket 断开连接
- (void)deviceDidDisconnectSuccess:(PWLocalDevice *)device;
// socket 服务端主动断开连接
- (void)device:(PWLocalDevice *)device remoteDidDisconnectError:(NSError *)error;
// 接收到 command 消息
- (void)device:(PWLocalDevice *)device didReceiveCommand:(PWCommand *)command;

@end

// socket service
@interface PWLocalDevice : PWDevice
/*&* socket delegate */
@property (weak, nonatomic) id<PWLocalDeviceDelegate> delegate;
/*&* host */
@property (copy, nonatomic) NSString *host;
/*&* port */
@property (nonatomic) int port;
/*&* 激活YES 发送的消息启用ACK机制；默认为NO */
@property (nonatomic, assign, getter=isEnabledAck) BOOL enabledAck;

/**
 init

 @param ability 消息体（command） 解析和转换对应实体对象的关键 ability
 @param name 设备 名称
 @param host 设备 host
 @param port 设备 port
 @param reconnect 重连机制
 @return PWLocalDevice Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name host:(NSString *)host port:(int)port reconnect:(BOOL)reconnect;

/**
 init

 @param ability 消息体（command） 解析和转换对应实体对象的关键 ability
 @param socket 核心 socket
 @return PWLocalDevice Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability socket:(GCDAsyncSocket *)socket;

/**
 连接状态
 
 @return YES or NO
 */
- (BOOL)isConnected;

/**
 开始连接
 */
- (void)connect;

/**
 断开连接
 */
- (void)disconnect;

/**
 发送消息

 @param command custom PWCommand
 */
- (void)send:(PWCommand<PWCommandSendable> *)command;

@end
