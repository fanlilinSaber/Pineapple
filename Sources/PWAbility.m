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
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSString *type = (NSString *)[json valueForKey:@"type"];
    if ([type isEqualToString:PWCommandKeepLive]) {
        return nil;
    } else {
        PWCommand<PWCommandReceivable> *command = [PWVideoCommand new];
        [command parseData:json];
        return command;
    }    
}

@end


