//
//  PWProxy.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/17.
//
//

#import <Foundation/Foundation.h>
#import "PWRemoteDevice.h"
#import "PWAbility.h"

@class PWProxy;
// protocol
@protocol PWProxyDelegate <NSObject>
@optional
// MQTT 已关闭
- (void)proxyClosed:(PWProxy *)proxy;
// MQTT 关闭中
- (void)proxyClosing:(PWProxy *)proxy;
// MQTT 已连接
- (void)proxyConnected:(PWProxy *)proxy;
// MQTT 连接中
- (void)proxyConnecting:(PWProxy *)proxy;
// MQTT 出错了
- (void)proxyError:(PWProxy *)proxy;
// MQTT 开始中
- (void)proxyStarting:(PWProxy *)proxy;
// MQTT 收到消息了
- (void)proxy:(PWProxy *)proxy didReceiveCommand:(PWCommand *)command;

@end

// MQTT Session Object
@interface PWProxy : NSObject
/*&* MQTT delegate */
@property (weak, nonatomic) id<PWProxyDelegate> delegate;

/**
 init

 @param ability 消息体（command） 解析和转换对应实体对象的关键 ability
 @param host host
 @param port port
 @param user 用户名
 @param pass 密码
 @param clientId clientId
 @param rootTopic rootTopic (当前rootTopic“不包含”nodeId)
 @param nodeId nodeId
 @return PWProxy Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic nodeId:(NSString *)nodeId;

/**
 init

 @param ability ability 消息体（command） 解析和转换对应实体对象的关键 ability
 @param host host
 @param port port
 @param user 用户名
 @param pass 密码
 @param clientId clientId
 @param rootTopic rootTopic（当前rootTopic“包含”nodeId）
 @return PWProxy Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic;

/**
 连接状态

 @return YES or NO
 */
- (BOOL)isConnected;

/**
 订阅消息队列

 @param queue 队列名
 */
- (void)addSubscriptionQueue:(NSString *)queue;

/**
 取消消息队列

 @param queue 队列名
 */
- (void)cancelSubscriptionQueue:(NSString *)queue;

/**
 开始连接服务器
 */
- (void)connect;

/**
 重试连接服务器
 */
- (void)reconnect;

/**
 断开连接服务器
 */
- (void)disconnect;

/**
 发送 command 到指定的 device

 @param command command
 @param device device
 */
- (void)send:(PWCommand<PWCommandSendable> *)command toDevice:(PWRemoteDevice *)device;

/**
 发送 command 到指定的 队列里

 @param command command
 @param topic 队列名
 */
- (void)send:(PWCommand<PWCommandSendable> *)command topic:(NSString *)topic;

@end
