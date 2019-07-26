//
//  PWCommand.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/27.
//
//

#import "PWCommand.h"

@implementation PWCommand

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.msgType = [self.class msgType];
    }
    return self;
}

#pragma mark - public Method

- (void)fillPropertiesWithData:(NSDictionary *)data
{
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
}

- (NSMutableDictionary *)fillDataWithProperties
{
    NSMutableDictionary *data = [NSMutableDictionary new];
    data[@"msgType"] = [self.class msgType];
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
    return data;
}

- (NSData *)dataRepresentation
{
    NSMutableDictionary *data = [self fillDataWithProperties];
#ifdef DEBUG
    NSLog(@"\n发送协议body内容:\n%@", data);
#endif
    return [self dataRepresentationWithData:data];
}

- (NSData *)dataRepresentationWithData:(NSDictionary *)data
{
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    PWCommand *command = [[[self class] allocWithZone:zone] init];
    command.msgType = self.msgType;
    command.fromId = self.fromId;
    command.toId = self.toId;
    command.params = self.params;
    command.paramsArray = self.paramsArray;
    command.msgId = self.msgId;
    command.enabledAck = self.enabledAck;
    return command;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    PWCommand *command = [[[self class] allocWithZone:zone] init];
    command.msgType = self.msgType;
    command.fromId = self.fromId;
    command.toId = self.toId;
    command.params = self.params;
    command.paramsArray = self.paramsArray;
    command.msgId = self.msgId;
    command.enabledAck = self.enabledAck;
    return command;
}

@end
