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

- (instancetype)initWithName:(NSString *)name;

@end
