//
//  PWAckCommand.m
//  Pineapple iOS
//
//  Created by 范李林 on 2018/4/10.
//

#import "PWAckCommand.h"

@implementation PWAckCommand

+ (NSString *)msgType
{
    return @"CommonAck";
}

#pragma mark - init Method

- (instancetype)initWithSourceMsgId:(NSString *)sourceMsgId sourceMsgType:(NSString *)sourceMsgType
{
    self = [super init];
    if (self) {
        self.sourceMsgId = sourceMsgId;
        self.sourceMsgType = sourceMsgType;
        self.params = @{@"sourceMsgId" : self.sourceMsgId,
                        @"sourceMsgType" : self.sourceMsgType
                        };
    }
    return self;
}

#pragma mark - PWCommandSendable protocol

- (void)parseData:(NSDictionary *)data
{
    [super fillPropertiesWithData:data];
    self.sourceMsgId = self.params[@"sourceMsgId"];
    self.sourceMsgType = self.params[@"sourceMsgType"];
}

@end
