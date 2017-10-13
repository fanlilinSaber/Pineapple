//
//  PWBluetooth.h
//  Pineapple iOS
//
//  Created by 范李林 on 2017/10/13.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol PWBluetoothClientDelegate;

@protocol PWBluetoothClientDelegate <NSObject>

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
