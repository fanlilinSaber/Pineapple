//
//  PWAbility.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
//
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

// 消息体（command） 解析和转换对应实体对象的关键对象；每一个新的command协议在 通信的 service 初始化前 必须先注册到Ability里面，后续收到的消息才能正确的解析 转换为对应的实体model
@interface PWAbility : NSObject

/**
 解析接收的data消息 转为 command model

 @param data json data
 @return command model
 */
- (PWCommand *)commandWithData:(NSData *)data;

/**
 解析接收的JSON数据消息 转为 command model

 @param json json data
 @return command model
 */
- (PWCommand *)commandWithJson:(NSDictionary *)json;

/**
 注册 自定义协议的command

 @param aClass command实体类
 @param msgType command 的 msgType
 */
- (void)addCommand:(Class)aClass withMsgType:(NSString *)msgType;

/**
 注册 自定义协议的command，msgType默认会用aClass的msgType
 
 @param aClass command实体类
 */
- (void)addCommand:(Class)aClass;

@end
