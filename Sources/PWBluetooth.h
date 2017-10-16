//
//  PWBluetooth.h
//  Pineapple iOS
//
//  Created by 范李林 on 2017/10/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PWBluetoothClientDelegate;

@protocol PWBluetoothClientDelegate <NSObject>
@optional;
/**
 *  *&* 发现设备*
 */
- (void)bluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
/**
 *  *&* 连接到Peripherals-成功*
 */
- (void)bluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
/**
 *  *&* 连接失败*
 */
-(void)bluetoothCentralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  *&* 断开连接*
 */
- (void)bluetoothCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
/**
 *  *&* 扫描到服务*
 */
-(void)bluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error;
/**
 *  *&* 扫描到特征*
 */
- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
/**
 *  *&* 扫描到information*
 */
- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;

- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end


@interface PWBluetooth : NSObject
/*&* 蓝牙管理*/
@property (nonatomic, strong, readonly) CBCentralManager *manager;
/*&* 蓝牙是否可用*/
@property (nonatomic, assign, readonly, getter = isReady) BOOL ready;
/*&* 是否连接*/
@property (nonatomic, assign, readonly, getter = isConnection)  BOOL connection;
/*&* delecgate*/
@property (nonatomic, weak) id <PWBluetoothClientDelegate>delecgate;
/*&* services 如果设置了 默认内部 执行 discoverCharacteristics*/
@property (nonatomic, strong) NSArray *services_uuid;
/*&* 订阅广播 (一般实时心率) 对订阅的特征值uuid 若支持notfiy setNotifyValue*/
@property (nonatomic, strong) NSArray *subscibe_uuid;



/**
 *  *&* 开始扫描*
 */
- (void)stopScan;
/**
 *  *&* 停止扫描*
 */
- (void)startScan;
/**
 *  *&* 连接 设备*
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral;
/**
 *  *&* 断开连接*
 */
- (void)cancelPeripheralConnection:(CBPeripheral *)peripheral;

@end

NS_ASSUME_NONNULL_END
