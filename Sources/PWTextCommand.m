//
//  PWTextCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWTextCommand.h"

@implementation PWTextCommand

+ (NSString *)msgType {
    return @"Text";
}

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.msgType = PWTextCommand.msgType;
        self.enabledAck = YES;
        _text = text;
        self.params = @{@"text": self.text};
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableDictionary *data = [super fillDataWithProperties];
    return [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
}

- (void)parseData:(NSDictionary *)data {
    [super fillPropertiesWithData:data];
    self.text = self.params[@"text"];
}

@end
