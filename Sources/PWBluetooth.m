//
//  PWBluetooth.m
//  Pineapple iOS
//
//  Created by 范李林 on 2017/10/13.
//

#import "PWBluetooth.h"

@interface PWBluetooth ()<CBPeripheralDelegate, CBCentralManagerDelegate>
/*&* <##>*/
@property (nonatomic, strong) CBPeripheral *currentPeripheral;

@end

@implementation PWBluetooth

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    return self;
}

#pragma mark - public
- (void)stopScan{
    [self.manager stopScan];
}

- (void)startScan{
    NSAssert(self.isReady != NO, @"bluetooth is not enabled");
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral{
    self.currentPeripheral = peripheral;
    [self.manager connectPeripheral:peripheral options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
}

- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral{
    [self.manager cancelPeripheralConnection:peripheral];
}

#pragma mark - set
- (BOOL)isReady{
    BOOL state = YES;
    if (self.manager.state != CBManagerStatePoweredOn) {
        return NO;
    }
    return state;
}

- (BOOL)isConnection{
    NSAssert(self.currentPeripheral != nil, @"currentPeripheral is nil");
    BOOL state = YES;
    if (self.currentPeripheral.state != CBPeripheralStateConnected) {
        return NO;
    }
    return state;
}

#pragma mark - CBCentralManagerDelegate
#pragma mark - 当前蓝牙主设备状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        // 搜索外设
//        [self.manager scanForPeripheralsWithServices:nil // 通过某些服务筛选外设
//                                             options:nil]; // dict,条件
    }
    else {
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                NSLog(@">>>CBCentralManagerStateUnknown");
                break;
            case CBCentralManagerStateResetting:
                NSLog(@">>>CBCentralManagerStateResetting");
                break;
            case CBCentralManagerStateUnsupported:
                NSLog(@">>>CBCentralManagerStateUnsupported");
                break;
            case CBCentralManagerStateUnauthorized:
                NSLog(@">>>CBCentralManagerStateUnauthorized");
                break;
            case CBCentralManagerStatePoweredOff:
                NSLog(@">>>CBCentralManagerStatePoweredOff");
                break;
                
            default:
                break;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothCentralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothCentralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        });
    }
    NSLog(@"发现设备：%@ %@ \nadvertisementData = %@\nidentifier = %@",peripheral.name,RSSI,advertisementData,peripheral.identifier);
}

#pragma mark 设备扫描与连接的代理
/*&* 连接到Peripherals-成功*/
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothCentralManager:didConnectPeripheral:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothCentralManager:central didConnectPeripheral:peripheral];
        });
        
    }
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
}

/*&* 连接外设失败*/
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothCentralManager:didFailToConnectPeripheral:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothCentralManager:central didFailToConnectPeripheral:peripheral error:error];
        });
    }
}

/*&* 丢失连接*/
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothCentralManager:didDisconnectPeripheral:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothCentralManager:central didDisconnectPeripheral:peripheral error:error];
        });
    }
}

/*&* 扫描到服务*/
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothPeripheral:didDiscoverServices:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothPeripheral:peripheral didDiscoverServices:error];
        });
    }
    if (self.services_uuid.count) {
        for (CBService *service in peripheral.services) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

/*&* 发现外设服务里的特征的时候调用的代理方法(这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothPeripheral:didDiscoverCharacteristicsForService:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothPeripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
        });
    }
    if (self.services_uuid.count) {
        if (!error){
            for (CBUUID *uuid in self.services_uuid) {
                if ([service.UUID isEqual:uuid]) {
                    for (CBCharacteristic *characteristic in service.characteristics) {
                        NSAssert(self.subscibe_uuid != nil, @"subscibe_uuid is nil");
                        if ([self.subscibe_uuid containsObject:characteristic.UUID]) {
                            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                        }
                    }
                    
                }
            }
        }
    }
}

#pragma mark 设备信息处理
/*&* 扫描到具体的值*/
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothPeripheral:didUpdateValueForCharacteristic:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothPeripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
        });
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (self.delecgate && [self.delecgate respondsToSelector:@selector(bluetoothPeripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delecgate bluetoothPeripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
        });
        
    }
}


@end
