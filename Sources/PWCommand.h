//
//  PWCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

extern NSString * const PWCommandText;
extern NSString * const PWCommandVideo;

@protocol PWCommandSendable <NSObject>

- (NSData *)dataRepresentation;

@end

@protocol PWCommandReceivable <NSObject>

- (void)parseData:(NSDictionary *)data;

@end

@interface PWCommand: NSObject

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *clientId;

@end
