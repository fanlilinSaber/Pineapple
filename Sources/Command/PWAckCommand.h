//
//  PWAckCommand.h
//  Pineapple iOS
//
//  Created by 范李林 on 2018/4/10.
//

#import <Foundation/Foundation.h>
#import "PWCommand.h"

// ack 回复command
@interface PWAckCommand : PWCommand <PWCommandSendable, PWCommandReceivable>
/*&* 消息的MsgId */
@property (nonatomic, copy) NSString *sourceMsgId;
/*&* 消息的MsgType */
@property (nonatomic, copy) NSString *sourceMsgType;

/**
 init

 @param sourceMsgId 回复消息的MsgId
 @param sourceMsgType 回复消息的消息MsgType
 @return PWAckCommand Object
 */
- (instancetype)initWithSourceMsgId:(NSString *)sourceMsgId sourceMsgType:(NSString *)sourceMsgType;
@end
