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

- (instancetype)initWithSourceMsgId:(NSString *)sourceMsgId sourceMsgType:(NSString *)sourceMsgType {
    self = [super init];
    if (self) {
        self.msgType = PWAckCommand.msgType;
        self.sourceMsgId = sourceMsgId;
        self.sourceMsgType = sourceMsgType;
    }
    return self;
}

- (NSData *)dataRepresentation {
    self.params = @{@"sourceMsgId" : self.sourceMsgId,
                    @"sourceMsgType" : self.sourceMsgType
                    };
    NSMutableDictionary *data = [super fillDataWithProperties];
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (void)parseData:(NSDictionary *)data {
    [super fillPropertiesWithData:data];
    self.sourceMsgId = self.params[@"sourceMsgId"];
    self.sourceMsgType = self.params[@"sourceMsgType"];
}

@end
