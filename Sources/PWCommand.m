//
//  PWCommand.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWCommand.h"

NSString * const PWCommandCRLF = @"\r\n";

@implementation PWCommand

- (instancetype)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        _text = text;        
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        _text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return self;   
}

- (NSData *)dataRepresentation {
    return [self.text dataUsingEncoding:NSUTF8StringEncoding];
}

@end
