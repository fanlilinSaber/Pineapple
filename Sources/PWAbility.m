//
//  PWAbility.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWAbility.h"
#import "PWVideoCommand.h"

@implementation PWAbility

+ (PWCommand *)commandWithData:(NSData *)data {
    // Need Design Command Structure
    NSString *video = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *json = @{@"type": @(PWCommandVideo), @"video": video};
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSInteger type = ((NSNumber *)[json valueForKey:@"type"]).integerValue;
    PWCommand<PWCommandReceivable> *command = nil;
    switch (type) {
        case PWCommandVideo:
            command = [PWVideoCommand new];
            break;
        default:
            break;
    }
    command.type = type;
    [command parseData:json];
    return command;
}

@end


