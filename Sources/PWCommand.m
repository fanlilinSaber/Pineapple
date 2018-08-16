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
    if ([data[@"params"] isKindOfClass:[NSDictionary class]]) {
        self.params = data[@"params"];
    } else {
        self.paramsArray = data[@"params"];
    }
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
    if (self.params) {
        data[@"params"] = self.params;
    } else {
        data[@"params"] = self.paramsArray;
    }
    if (self.msgId && ![self.msgId isEqualToString:@""]) {
        data[@"msgId"] = self.msgId;
    }
    if (self.ack && ![self.ack isEqualToString:@""]) {
        data[@"ack"] = self.ack;
    }
    return data;
}

- (PWCommand *)copyNew {
    PWCommand *command = [[PWCommand alloc] init];
    command.msgType = self.msgType;
    command.fromId = self.fromId;
    command.toId = self.toId;
    command.params = self.params;
    command.paramsArray = self.paramsArray;
    command.msgId = self.msgId;
    command.ack = self.ack;
    return command;
}

- (id)copyWithZone:(NSZone *)zone {
    PWCommand *command = [[[self class] allocWithZone:zone] init];
    command.msgType = self.msgType;
    command.fromId = self.fromId;
    command.toId = self.toId;
    command.params = self.params;
    command.paramsArray = self.paramsArray;
    command.msgId = self.msgId;
    command.ack = self.ack;
    return command;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    PWCommand *command = [[[self class] allocWithZone:zone] init];
    command.msgType = self.msgType;
    command.fromId = self.fromId;
    command.toId = self.toId;
    command.params = self.params;
    command.paramsArray = self.paramsArray;
    command.msgId = self.msgId;
    command.ack = self.ack;
    return command;
}

@end
