//
//  PWProxy.h
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/17.
//
//

#import <Foundation/Foundation.h>
#import "PWRemoteDevice.h"
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

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic;

- (void)connect;
- (void)reconnect;
- (void)disconnect;
- (void)send:(PWCommand<PWCommandSendable> *)command toDevice:(PWRemoteDevice *)device;

@end
