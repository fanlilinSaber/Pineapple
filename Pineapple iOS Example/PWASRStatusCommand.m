//
//  PWASRStatusCommand.m
//  Unity-iPhone
//
//  Created by 范李林 on 2017/10/25.
//
//

#import "PWASRStatusCommand.h"

@implementation PWASRStatusCommand

+ (NSString *)msgType {
    return @"ASRStatus";
}

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.msgType = PWASRStatusCommand.msgType;
        self.params = params;
    }
    return self;
}

- (NSData *)dataRepresentation{
    NSMutableDictionary *data = [super fillDataWithProperties];
//    DDLogDebug(@"发送 ASRStatus_data = \n%@",data);
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (void)parseData:(NSDictionary *)data{
    [super fillPropertiesWithData:data];
    NSString *operType = self.params[@"operType"];
    if ([operType isEqualToString:@"open"]) {
        self.isOpen = YES;
    }else{
        self.isOpen = NO;
    }
    self.topicNumber = [self.params[@"topicNumber"] intValue];
}

@end
