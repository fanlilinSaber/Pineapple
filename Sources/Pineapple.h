//
//  Pineapple.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/27.
//
//
/* README: 此组件包含基础通信服务; MQTT、Socket、蓝牙、MQ
           MQTT：用于跨网移动端设备与设备之间的通信；核心组件
           Socket：用于本地域网移动端设备与设备之间的通信；核心组件
           蓝牙：用于采集小米手环心跳数据
*/
#import <UIKit/UIKit.h>

//! Project version number for Pineapple.
FOUNDATION_EXPORT double PineappleVersionNumber;

//! Project version string for Pineapple.
FOUNDATION_EXPORT const unsigned char PineappleVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Pineapple/PublicHeader.h>
#import "PWDevice.h"
#import "PWProxy.h"
#import "PWRemoteDevice.h"
#import "PWListener.h"
#import "PWLocalDevice.h"
#import "PWAbility.h"
#import "PWCommand.h"
#import "PWTextCommand.h"
#import "PWBluetooth.h"
#import "PWMQDevice.h"
