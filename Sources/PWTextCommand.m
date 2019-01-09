//
//  PWTextCommand.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/29.
//
//

#import "PWTextCommand.h"

@implementation PWTextCommand

+ (NSString *)msgType
{
    return @"Text";
}

#pragma mark - init Method

- (instancetype)initWithText:(NSString *)text
{
    self = [super init];
    if (self) {
        self.msgType = PWTextCommand.msgType;
        self.enabledAck = YES;
        _text = text;
        self.params = @{@"text": self.text};
    }
    return self;
}

#pragma mark - PWCommandSendable protocol

- (NSData *)dataRepresentation
{
    NSMutableDictionary *data = [super fillDataWithProperties];
    return [super dataRepresentationWithData:data];
}

#pragma mark - PWCommandReceivable protocol

- (void)parseData:(NSDictionary *)data
{
    [super fillPropertiesWithData:data];
    self.text = self.params[@"text"];
}

@end
