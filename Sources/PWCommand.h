//
//  PWCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

extern NSString * const PWCommandCRLF;

@protocol PWCommandSendable <NSObject>

- (NSData *)dataRepresentation;

@end

@protocol PWCommandReceivable <NSObject>

- (void)parseData:(NSDictionary *)data;

@end

@interface PWCommand: NSObject

@property (nonatomic) NSInteger type;

@end

typedef NS_ENUM(NSInteger, PWCommandType) {
    PWCommandText = 1,
    PWCommandVideo = 2,
};
