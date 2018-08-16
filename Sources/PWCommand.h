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

@interface PWCommand: NSObject<NSCopying>

@property (copy, nonatomic) NSString *msgType;
@property (copy, nonatomic) NSString *fromId;
@property (copy, nonatomic) NSString *toId;
@property (copy, nonatomic) NSDictionary *params;
@property (copy, nonatomic) NSArray *paramsArray;
@property (copy, nonatomic) NSString *msgId;
@property (copy, nonatomic) NSString *ack;
@property (nonatomic, assign, getter=isEnabledAck) BOOL enabledAck;

- (void)fillPropertiesWithData:(NSDictionary *)data;
- (NSMutableDictionary *)fillDataWithProperties;

- (PWCommand *)copyNew;
@end
