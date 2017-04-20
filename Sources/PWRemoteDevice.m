//
//  PWRemoteDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import "PWRemoteDevice.h"

@interface PWRemoteDevice ()

@end

@implementation PWRemoteDevice

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId {
    self = [super initWithName:name];
    if (self) {
        _clientId = clientId;
    }
    return self;
}

@end
