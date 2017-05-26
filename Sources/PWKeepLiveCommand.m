//
//  PWKeepLiveCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/20.
//
//

#import "PWKeepLiveCommand.h"

@implementation PWKeepLiveCommand

+ (NSString *)msgType {
    return @"Keep Live";
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.msgType = PWKeepLiveCommand.msgType;
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSDictionary *data = [NSDictionary new];
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

@end
