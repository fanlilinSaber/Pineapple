//
//  PWVideoCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWVideoCommand.h"

@implementation PWVideoCommand

- (void)parseData:(NSDictionary *)data {
    self.type = data[@"type"];
    self.clientId = data[@"clientId"];
    self.video = data[@"text"];
}

@end
