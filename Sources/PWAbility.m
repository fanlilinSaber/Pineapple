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
        _commands = @{PWTextCommand.type: PWTextCommand.class};
    }
    return self;
}

- (PWCommand *)commandWithData:(NSData *)data {
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = (NSString *)[json valueForKey:@"type"];
    if ([type isEqualToString:PWKeepLiveCommand.type]) {
        return nil;
    } else {
        Class class = (Class)self.commands[type];
        PWCommand<PWCommandReceivable> *command = [class new];
        [command parseData:json];
        return command;
    }
}

- (void)addCommand:(Class)class withType:(NSString *)type {
    NSAssert([class isSubclassOfClass:PWCommand.class], @"Command Must Inherited From PWCommand");
    NSAssert([class conformsToProtocol:@protocol(PWCommandReceivable)], @"Command Must Conform To PWCommandReceivable");
    NSAssert(self.commands[type] == nil, @"Command Already Existed");
    NSMutableDictionary *commands = [self.commands mutableCopy];
    commands[type] = class;
    self.commands = commands;
}

@end
