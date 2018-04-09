//
//  PWMQDevice.h
//  Pineapple iOS
//
//  Created by 范李林 on 2018/3/12.
//

#import <UIKit/UIKit.h>
#import "PWDevice.h"
#import "PWAbility.h"

@class PWMQDevice, RMQClient;

@interface PWMQDevice : PWDevice

/*&* uri*/
@property (nonatomic, copy) NSString *uri;

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name uri:(NSString *)uri;

- (void)connect;
- (void)send:(NSString *)text;
@end
