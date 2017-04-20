//
//  PWRemoteDevice.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import <Foundation/Foundation.h>
#import "PWDevice.h"

@interface PWRemoteDevice : PWDevice

@property (copy, nonatomic) NSString *clientId;

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId;

@end
