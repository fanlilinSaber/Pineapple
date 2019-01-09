//
//  PWHeader.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/19.
//
//

#import "PWHeader.h"

/*&* 包头换行符*/
static NSString * const PWHeaderCRLF = @"\r\n";
/*&* 版本*/
static NSString * const PWHeaderVersion = @"Version";
/*&* content 长度*/
static NSString * const PWHeaderContentLength = @"Content-Length";

@implementation PWHeader

#pragma mark - init Method

- (instancetype)initWithContentLength:(NSUInteger)contentLength
{
    self = [super init];
    if (self) {
        _version = @"1.0";
        _contentLength = contentLength;
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data
{
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

#pragma mark - public Method
- (NSData *)dataRepresentation
{
    NSMutableString *header = [NSMutableString new];
    // 协议包头格式 其他端必须保持一致
    [header appendFormat:@"%@: %@%@", PWHeaderVersion, self.version, PWHeaderCRLF];
    [header appendFormat:@"%@: %lu%@%@", PWHeaderContentLength, (unsigned long)self.contentLength, PWHeaderCRLF, PWHeaderCRLF];
    return [header dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)endTerm {
    return [[NSString stringWithFormat:@"%@%@", PWHeaderCRLF, PWHeaderCRLF] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
