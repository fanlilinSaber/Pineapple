//
//  PWKeepLiveCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/20.
//
//

#import "PWKeepLiveCommand.h"

@implementation PWKeepLiveCommand

+ (NSString *)type {
    return @"Keep Live";
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = PWKeepLiveCommand.type;
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableDictionary *data = [super fillDataWithProperties];
    data[@"text"] = @"";
    return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
}

@end
