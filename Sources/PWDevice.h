//
//  PWDevice.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>
#import "PWAbility.h"
#import "PWCommand.h"

@interface PWDevice : NSObject

@property (nonatomic, strong) PWAbility *ability;
@property (nonatomic, copy) NSString *host;
@property (nonatomic) int port;

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(int)port;

- (void)connect;
- (void)send:(PWCommand *)command;

@end
