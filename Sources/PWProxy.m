//
//  PWProxy.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/17.
//
//

#import "PWProxy.h"
#import <MQTTClient/MQTTSessionManager.h>

@interface PWProxy () <MQTTSessionManagerDelegate>

@property (strong, nonatomic) MQTTSessionManager *sessionManager;
@property (strong, nonatomic) PWAbility *ability;
@property (copy, nonatomic) NSString *host;
@property (nonatomic) NSInteger port;
@property (copy, nonatomic) NSString *user;
@property (copy, nonatomic) NSString *pass;
@property (copy, nonatomic) NSString *groupId;
@property (copy, nonatomic) NSString *deviceId;
@property (copy, nonatomic) NSString *clientId;
@property (copy, nonatomic) NSString *rootTopic;

@end

@implementation PWProxy

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic {
    self = [super init];
    if (self) {
        _ability = ability;
        _host = host;
        _port = port;
        _user = user;
        _pass = pass;
        _clientId = clientId;
        _rootTopic = rootTopic;
        _sessionManager = [MQTTSessionManager new];
        _sessionManager.delegate = self;
        _sessionManager.subscriptions = @{[NSString stringWithFormat:@"%@/p2p", self.rootTopic]: @0};
        [_sessionManager addObserver:self
                          forKeyPath:@"state"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:nil];
    }
    return self;
}

- (void)connect {    
    [self.sessionManager connectTo:self.host
                              port:self.port
                               tls:NO
                         keepalive:60 // 心跳间隔不得大于 120 s
                             clean:true
                              auth:true
                              user:self.user
                              pass:self.pass
                              will:false
                         willTopic:nil
                           willMsg:nil
                           willQos:0
                    willRetainFlag:FALSE
                      withClientId:self.clientId];
}

- (void)reconnect {
    [self.sessionManager connectToLast];
}

- (void)disconnect {
    [self.sessionManager disconnect];
}

- (void)send:(PWCommand<PWCommandSendable> *)command toDevice:(PWRemoteDevice *)device {
    command.fromId = self.clientId;
    command.toId = device.clientId;
    [self.sessionManager sendData:command.dataRepresentation
                     topic:[NSString stringWithFormat:@"%@/p2p/%@", self.rootTopic, device.clientId]
                       qos:0
                    retain:false];
}

#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.sessionManager.state) {
        case MQTTSessionManagerStateClosed:
            [self.delegate proxyClosed:self];
            break;
        case MQTTSessionManagerStateClosing:
            [self.delegate proxyClosing:self];
            break;
        case MQTTSessionManagerStateConnected:
            [self.delegate proxyConnected:self];
            break;
        case MQTTSessionManagerStateConnecting:
            [self.delegate proxyConnecting:self];
            break;
        case MQTTSessionManagerStateError:
            [self.delegate proxyError:self];
            break;
        case MQTTSessionManagerStateStarting:
            [self.delegate proxyStarting:self];
            break;
    }
}

#pragma mark - MQTTSessionManagerDelegate

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    PWCommand *command = [self.ability commandWithData:data];
    [self.delegate proxy:self didReceiveCommand:command];    
}

@end
