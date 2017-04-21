//
//  PWTextCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWTextCommand.h"

@implementation PWTextCommand

+ (NSString *)type {
    return @"Text";
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.type = PWTextCommand.type;
        _text = text;
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableDictionary *data = [super fillDataWithProperties];
    data[@"text"] = self.text;
    return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
}

- (void)parseData:(NSDictionary *)data {
    [super fillPropertiesWithData:data];
    self.text = data[@"text"];
}

@end
