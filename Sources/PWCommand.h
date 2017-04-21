//
//  PWCommand.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import <Foundation/Foundation.h>

@protocol PWCommandSendable <NSObject>

+ (NSString *)type;
- (NSData *)dataRepresentation;

@end

@protocol PWCommandReceivable <NSObject>

+ (NSString *)type;
- (void)parseData:(NSDictionary *)data;

@end

@interface PWCommand: NSObject

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *clientId;

- (void)fillPropertiesWithData:(NSDictionary *)data;
- (NSMutableDictionary *)fillDataWithProperties;

@end
