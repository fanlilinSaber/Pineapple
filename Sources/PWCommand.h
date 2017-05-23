//
//  PWCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

@protocol PWCommandSendable <NSObject>

+ (NSString *)msgType;
- (NSData *)dataRepresentation;

@end

@protocol PWCommandReceivable <NSObject>

+ (NSString *)msgType;
- (void)parseData:(NSDictionary *)data;

@end

@interface PWCommand: NSObject

@property (copy, nonatomic) NSString *msgType;
@property (copy, nonatomic) NSString *fromId;
@property (copy, nonatomic) NSString *toId;
@property (copy, nonatomic) NSDictionary *params;
@property (copy, nonatomic) NSString *msgId;
@property (copy, nonatomic) NSString *ack;

- (void)fillPropertiesWithData:(NSDictionary *)data;
- (NSMutableDictionary *)fillDataWithProperties;

@end
