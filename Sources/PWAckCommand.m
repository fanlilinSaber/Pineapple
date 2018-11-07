//
//  PWAckCommand.m
//  Pineapple iOS
//
//  Created by 范李林 on 2018/4/10.
//

#import "PWAckCommand.h"

@implementation PWAckCommand

+ (NSString *)msgType {
    return @"CommonAck";
}

#pragma mark - @init Method

- (instancetype)initWithSourceMsgId:(NSString *)sourceMsgId sourceMsgType:(NSString *)sourceMsgType {
    self = [super init];
    if (self) {
        self.msgType = PWAckCommand.msgType;
        self.sourceMsgId = sourceMsgId;
        self.sourceMsgType = sourceMsgType;
        self.params = @{@"sourceMsgId" : self.sourceMsgId,
                        @"sourceMsgType" : self.sourceMsgType
                        };
    }
    return self;
}

#pragma mark - @protocol PWCommandSendable

- (NSData *)dataRepresentation {
    NSMutableDictionary *data = [super fillDataWithProperties];
    return [super dataRepresentationWithData:data];
}

#pragma mark - @protocol PWCommandSendable

- (void)parseData:(NSDictionary *)data {
    [super fillPropertiesWithData:data];
    self.sourceMsgId = self.params[@"sourceMsgId"];
    self.sourceMsgType = self.params[@"sourceMsgType"];
}

@end
