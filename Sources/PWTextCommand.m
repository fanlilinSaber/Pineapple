//
//  PWTextCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWTextCommand.h"

@implementation PWTextCommand

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.type = PWCommandText;
        _text = text;
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableDictionary *json = [NSMutableDictionary new];
    json[@"type"] = self.type;
    json[@"clientId"] = self.clientId;
    json[@"text"] = self.text;
    return [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
}

@end
