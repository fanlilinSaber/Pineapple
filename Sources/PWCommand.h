//
//  PWCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

extern NSString * const PWCommandCRLF;

@interface PWCommand : NSObject

@property (copy, nonatomic) NSString *text;

- (instancetype)initWithText:(NSString *)text;
- (instancetype)initWithData:(NSData *)data;

- (NSData *)dataRepresentation;

@end
