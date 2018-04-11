//
//  PWUserLoginStatusCommand.m
//  Unity-iPhone
//
//  Created by 范李林 on 2018/4/10.
//

#import "PWUserLoginStatusCommand.h"

@implementation PWUserLoginStatusCommand

+ (NSString *)msgType {
    return @"CmdUserLoginStatus";
}

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.msgType = PWUserLoginStatusCommand.msgType;
        self.params = params;
    }
    return self;
}

- (instancetype)initWithUserToken:(NSString *)userToken {
    if (self = [super init]) {
        self.msgType = PWUserLoginStatusCommand.msgType;
        NSDictionary *dict = @{@"userToken" : userToken,
                               @"tokenStatus" : @"Valid"
                               };
        self.params = dict;
        self.enabledAck = YES;
    }
    return self;
}

- (NSData *)dataRepresentation{
    NSMutableDictionary *data = [super fillDataWithProperties];
    NSLog(@"发送 CmdUserLoginStatus_data = \n%@",data);
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (void)parseData:(NSDictionary *)data{
    [super fillPropertiesWithData:data];
    self.userToken = self.params[@"userToken"];
    NSString *tokenStatus = self.params[@"tokenStatus"];
    if ([tokenStatus isEqualToString:@"Valid"]) {
        self.isValid = YES;
    }else {
        self.isValid = NO;
    }
}

@end
