//
//  PWCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWCommand.h"

@implementation PWCommand

- (void)fillPropertiesWithData:(NSDictionary *)data {
    self.msgType = data[@"msgType"];
    self.fromId = data[@"fromId"];
    self.toId = data[@"toId"];
    self.params = data[@"params"];
    if (data[@"msgId"] && ![data[@"msgId"] isEqualToString:@""]) {
        self.msgId = data[@"msgId"];
    }
    if (data[@"ack"] && ![data[@"ack"] isEqualToString:@""]) {
        self.ack = data[@"ack"];
    }
}

- (NSMutableDictionary *)fillDataWithProperties {
    NSMutableDictionary *data = [NSMutableDictionary new];
    data[@"msgType"] = self.msgType;
    data[@"fromId"] = self.fromId;
    data[@"toId"] = self.toId;
    data[@"params"] = self.params;
    if (self.msgId && ![self.msgId isEqualToString:@""]) {
        data[@"msgId"] = self.msgId;
    }
    if (self.ack && ![self.ack isEqualToString:@""]) {
        data[@"ack"] = self.ack;
    }
    return data;
}

@end
