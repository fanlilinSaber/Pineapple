//
//  PWKeepLiveCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/20.
//
//

#import "PWKeepLiveCommand.h"

@implementation PWKeepLiveCommand

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = PWCommandKeepLive;
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableDictionary *data = [NSMutableDictionary new];
    [super fillPropertiesWithData:data];
    data[@"text"] = @"";
    return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
}

@end
