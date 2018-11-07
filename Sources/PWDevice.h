//
//  PWDevice.h
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/20.
//
//

#import <Foundation/Foundation.h>

// Device model
@interface PWDevice : NSObject
/*&* Device name*/
@property (copy, nonatomic) NSString *name;
/*&* Device clientId*/
@property (copy, nonatomic) NSString *clientId;

/**
 init

 @param name 设备名称
 @param clientId clientId
 @return PWDevice
 */
- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId;

@end
