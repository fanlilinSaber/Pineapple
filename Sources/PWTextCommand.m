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
        _text = text;
        self.type = PWCommandText;
    }
    return self;
}

- (NSData *)dataRepresentation {
    return [self.text dataUsingEncoding:NSUTF8StringEncoding];
}

@end
