//
//  PWDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/20.
//
//

#import "PWDevice.h"

@implementation PWDevice

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId {
    self = [super init];
    if (self) {
        _name = name;
        _clientId = clientId;
    }
    return self;
}

@end
