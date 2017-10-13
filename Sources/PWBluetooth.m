//
//  PWBluetooth.m
//  Pineapple iOS
//
//  Created by 范李林 on 2017/10/13.
//

#import "PWBluetooth.h"

@interface PWBluetooth ()<CBPeripheralDelegate, CBCentralManagerDelegate>

@end

@implementation PWBluetooth

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    return self;
}


@end
