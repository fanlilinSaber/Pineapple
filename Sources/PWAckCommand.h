//
//  PWAckCommand.h
//  Pineapple iOS
//
//  Created by 范李林 on 2018/4/10.
//

#import <Pineapple/Pineapple.h>

@interface PWAckCommand : PWCommand <PWCommandSendable, PWCommandReceivable>
/*&* <##>*/
@property (nonatomic, copy) NSString *sourceMsgId;
/*&* <##>*/
@property (nonatomic, copy) NSString *sourceMsgType;

- (instancetype)initWithSourceMsgId:(NSString *)sourceMsgId sourceMsgType:(NSString *)sourceMsgType;
@end
