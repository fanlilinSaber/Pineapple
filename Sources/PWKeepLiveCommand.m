//
//  PWKeepLiveCommand.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/20.
//
//

#import "PWKeepLiveCommand.h"

@implementation PWKeepLiveCommand

+ (NSString *)msgType
{
    return @"Keep Live";
}

#pragma mark - init Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.msgType = PWKeepLiveCommand.msgType;
    }
    return self;
}

#pragma mark - PWCommandSendable protocol

- (NSData *)dataRepresentation
{
    NSDictionary *data = [NSDictionary new];
    return [super dataRepresentationWithData:data];
}

@end
