//
//  PWProxy.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/17.
//
//

#import <Foundation/Foundation.h>
#import "PWClient.h"
#import "PWAbility.h"

@class PWProxy;

@protocol PWProxyDelegate <NSObject>

- (void)proxyClosed:(PWProxy *)proxy;
- (void)proxyClosing:(PWProxy *)proxy;
- (void)proxyConnected:(PWProxy *)proxy;
- (void)proxyConnecting:(PWProxy *)proxy;
- (void)proxyError:(PWProxy *)proxy;
- (void)proxyStarting:(PWProxy *)proxy;
- (void)proxy:(PWProxy *)proxy didReceiveCommand:(PWCommand *)command;

@end

@interface PWProxy : NSObject

@property (weak, nonatomic) id<PWProxyDelegate> delegate;

- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass groupId:(NSString *)groupId deviceId:(NSString *)deviceId rootTopic:(NSString *)rootTopic;

- (void)connect;
- (void)reconnect;
- (void)disconnect;
- (void)send:(PWCommand<PWCommandSendable> *)command toClient:(PWClient *)client;

@end
