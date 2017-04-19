//
//  PWHeader.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/19.
//
//

#import <Foundation/Foundation.h>

@interface PWHeader : NSObject

@property (copy, nonatomic) NSString *version;
@property (nonatomic) NSUInteger contentLength;

- (instancetype)initWithContentLength:(NSUInteger)contentLength;
- (instancetype)initWithData:(NSData *)data;
- (NSData *)dataRepresentation;

+ (NSData *)endTerm;

@end
