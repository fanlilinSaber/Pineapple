//
//  PWMQDevice.h
//  Pineapple iOS
//
//  Created by 范李林 on 2018/3/12.
//

#import <UIKit/UIKit.h>
#import "PWDevice.h"
#import "PWAbility.h"

#pragma mark - 组件并未完成；当前版本不可用

@class PWMQDevice, RMQClient;
// protocol
@protocol PWMQDeviceDelegate <NSObject>

@end

// MQ service
@interface PWMQDevice : PWDevice
/*&* uri*/
@property (nonatomic, copy) NSString *uri;

/**
 init

 @param ability ability
 @param name 设备 名称
 @param uri 连接地址
 @return PWMQDevice Object
 */
- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name uri:(NSString *)uri;

- (void)connect;
- (void)send:(NSString *)text;
@end
