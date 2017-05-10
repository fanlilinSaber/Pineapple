//
//  PWDevice.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/20.
//
//

#import <Foundation/Foundation.h>

@interface PWDevice : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *clientId;

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId;

@end
