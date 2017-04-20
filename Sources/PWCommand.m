//
//  PWCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWCommand.h"

NSString * const PWCommandKeepLive = @"Keep Live";
NSString * const PWCommandText = @"Text";
NSString * const PWCommandVideo = @"Video";

@implementation PWCommand

- (void)fillPropertiesWithData:(NSDictionary *)data {
    self.type = data[@"type"];
    self.clientId = data[@"clientId"];
}

- (NSMutableDictionary *)fillDataWithProperties {
    NSMutableDictionary *data = [NSMutableDictionary new];
    data[@"type"] = self.type;
    data[@"clientId"] = self.clientId;
    return data;
}

@end
