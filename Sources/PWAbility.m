//
//  PWAbility.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWAbility.h"
#import "PWKeepLiveCommand.h"
#import "PWTextCommand.h"

@interface PWAbility ()

@property (copy, nonatomic) NSDictionary *commands;

@end

@implementation PWAbility

- (instancetype)init {
    self = [super init];
    if (self) {
        _commands = @{PWTextCommand.msgType: PWTextCommand.class};
    }
    return self;
}

- (PWCommand *)commandWithData:(NSData *)data {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *msgType = (NSString *)[json valueForKey:@"msgType"];
    if (!msgType) {
        return nil;
    } else {
        Class class = (Class)self.commands[msgType];
        PWCommand<PWCommandReceivable> *command = [class new];
        [command parseData:json];
        return command;
    }
}

- (void)addCommand:(Class)class withMsgType:(NSString *)msgType {
    NSAssert([class isSubclassOfClass:PWCommand.class], @"Command Must Inherited From PWCommand");
    NSAssert([class conformsToProtocol:@protocol(PWCommandReceivable)], @"Command Must Conform To PWCommandReceivable");
    NSAssert(self.commands[msgType] == nil, @"Command Already Existed");
    NSMutableDictionary *commands = [self.commands mutableCopy];
    commands[msgType] = class;
    self.commands = commands;
}

@end
