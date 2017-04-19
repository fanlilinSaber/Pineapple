//
//  PWClient.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import "PWClient.h"

@interface PWClient ()

@end

@implementation PWClient

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId {
    self = [super init];
    if (self) {
        _name = name;
        _clientId = clientId;
    }
    return self;
}

@end
