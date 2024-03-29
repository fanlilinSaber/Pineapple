//
//  PWCommand.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/27.
//
//

#import <Foundation/Foundation.h>
// 发送协议 自定义 command 必须实现
@protocol PWCommandSendable <NSObject>
@required
// command 类型
+ (NSString *)msgType;

@end

// 接收协议 自定义 command 必须实现
@protocol PWCommandReceivable <NSObject>
@required
// command 类型
+ (NSString *)msgType;
// command data解析
- (void)parseData:(NSDictionary *)data;

@end

// 自定义 command 基类
@interface PWCommand: NSObject<NSCopying>
/*&* command 类型 */
@property (copy, nonatomic) NSString *msgType;
/*&* command 消息来源 id */
@property (copy, nonatomic) NSString *fromId;
/*&* command 消息目标 id */
@property (copy, nonatomic) NSString *toId;
/*&* command 小程序 id；如果没有为nil */
@property (copy, nonatomic) NSString *mmaId;
/*&* command 逻辑参数 */
@property (copy, nonatomic) NSDictionary *params;
/*&* command 逻辑参数 */
@property (copy, nonatomic) NSArray *paramsArray;
/*&* command msgId */
@property (copy, nonatomic) NSString *msgId;
/*&* 默认为NO ；自定义command 如需启用ACK机制 设置YES */
@property (nonatomic, assign, getter=isEnabledAck) BOOL enabledAck;

/**
 实例为command model

 @param data json数据源
 */
- (void)fillPropertiesWithData:(NSDictionary *)data;

/**
 command model 转 json

 @return dict
 */
- (NSMutableDictionary *)fillDataWithProperties;

/**
 json data 转 二进制 data

 @param data json data
 @return 二进制 data
 */
- (NSData *)dataRepresentationWithData:(NSDictionary *)data;

/**
 获取 消息 data，用于发送

 @return data
 */
- (NSData *)dataRepresentation;

@end
