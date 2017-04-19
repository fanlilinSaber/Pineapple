//
//  PWHeader.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/19.
//
//

#import "PWHeader.h"

static NSString * const PWHeaderCRLF = @"\r\n";

static NSString * const PWHeaderVersion = @"Version";
static NSString * const PWHeaderContentLength = @"Content-Length";

@implementation PWHeader

- (instancetype)initWithContentLength:(NSUInteger)contentLength {
    self = [super init];
    if (self) {
        _version = @"1.0";
        _contentLength = contentLength;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    if (self) {
        NSString *header = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *lines = [header componentsSeparatedByString:PWHeaderCRLF];
        for (NSString *line in lines) {
            if ([line isEqualToString:@""]) {
                break;
            }
            NSArray *dict = [line componentsSeparatedByString:@" "];
            NSString *key = dict.firstObject;
            NSString *value = dict.lastObject;
            if ([key isEqualToString:[NSString stringWithFormat:@"%@:", PWHeaderVersion]]) {
                _version = value;
            } else if ([key isEqualToString:[NSString stringWithFormat:@"%@:", PWHeaderContentLength]]) {
                _contentLength = value.integerValue;
            }
        }
    }
    return self;
}

- (NSData *)dataRepresentation {
    NSMutableString *header = [NSMutableString new];
    [header appendFormat:@"%@: %@%@", PWHeaderVersion, self.version, PWHeaderCRLF];
    [header appendFormat:@"%@: %lu%@%@", PWHeaderContentLength, (unsigned long)self.contentLength, PWHeaderCRLF, PWHeaderCRLF];
    return [header dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)endTerm {
    return [[NSString stringWithFormat:@"%@%@", PWHeaderCRLF, PWHeaderCRLF] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
