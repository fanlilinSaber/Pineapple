//
//  PWHeader.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/19.
//
//

#import <Foundation/Foundation.h>

// 消息体（command）包头
@interface PWHeader : NSObject
/*&* 版本号 */
@property (copy, nonatomic) NSString *version;
/*&* 主体内容的长度（用于 socket 解析出正确的 boby ）*/
@property (nonatomic) NSUInteger contentLength;

/**
 init

 @param contentLength 主体内容的长度（用于 socket 解析出正确的 boby ）
 @return PWHeader Object
 */
- (instancetype)initWithContentLength:(NSUInteger)contentLength;

/**
 init（用于收到的消息 解包头）

 @param data 包头 data
 @return PWHeader Object
 */
- (instancetype)initWithData:(NSData *)data;

/**
 包头 model 转 json data

 @return json data
 */
- (NSData *)dataRepresentation;

/**
 包头结束标记

 @return 包头结束标记 data
 */
+ (NSData *)endTerm;

@end
