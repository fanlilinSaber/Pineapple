//
//  PWAbility.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
//
//

#import "PWAbility.h"
#import "PWKeepLiveCommand.h"
#import "PWTextCommand.h"
#import "PWAckCommand.h"

@interface PWAbility ()
/*&* 自定义协议的command class 类*/
@property (copy, nonatomic) NSDictionary *commands;

@end

@implementation PWAbility

#pragma mark - init Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commands = @{PWTextCommand.msgType: PWTextCommand.class,
                      PWAckCommand.msgType: PWAckCommand.class
                      };
    }
    return self;
}

#pragma mark - public Method

- (PWCommand *)commandWithData:(NSData *)data
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *msgType = (NSString *)[json valueForKey:@"msgType"];
    if (!msgType) {
        if ([json isKindOfClass:[NSDictionary class]] && json.count == 0) {
            
            return [PWKeepLiveCommand new];
        }
        return nil;
    } else {
        Class class = (Class)self.commands[msgType];
        PWCommand<PWCommandReceivable> *command = [class new];
        [command parseData:json];
        return command;
    }
}

- (void)addCommand:(Class)aClass withMsgType:(NSString *)msgType
{
    NSAssert([aClass isSubclassOfClass:PWCommand.class], @"Command Must Inherited From PWCommand");
    NSAssert([aClass conformsToProtocol:@protocol(PWCommandReceivable)], @"Command Must Conform To PWCommandReceivable");
    NSAssert(self.commands[msgType] == nil, @"Command Already Existed");
    NSMutableDictionary *commands = [self.commands mutableCopy];
    commands[msgType] = aClass;
    self.commands = commands;
}

@end
