//
//  PWClient.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import <Foundation/Foundation.h>

@interface PWClient : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *clientId;

- (instancetype)initWithName:(NSString *)name clientId:(NSString *)clientId;

@end
