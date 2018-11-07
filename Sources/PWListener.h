//
//  PWListener.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/31.
//
//

#import <UIKit/UIKit.h>
#import "PWLocalDevice.h"

@class PWListener;
// protocol
@protocol PWListenerDelegate <NSObject>
@optional
// 服务器开启成功
- (void)listenerDidStartSuccess:(PWListener *)listener;
// 服务器开启失败
- (void)listenerDidStartFailed:(PWListener *)listener;
// 收到连接进来的客服端
- (void)listener:(PWListener *)listener didConnectDevice:(PWLocalDevice *)device;

@end

// socket 服务端 service
@interface PWListener : NSObject
/*&* socket 服务端 delegate*/
@property (weak, nonatomic) id<PWListenerDelegate> delegate;

/**
 init

 @param ability 消息体（command） 解析和转换对应实体对象的关键 ability
 @param port port
 @return PWListener Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability port:(NSInteger)port;

/**
 开启 socket 服务端 service
 */
- (void)start;

/**
 断开 socket 服务端 service
 */
- (void)disconnect;
@end
