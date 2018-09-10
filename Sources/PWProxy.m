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
@property (copy, nonatomic) NSString *nodeId;

@end

@implementation PWProxy

- (void)dealloc {
    [_sessionManager disconnectWithDisconnectHandler:nil];
    [_sessionManager removeObserver:self forKeyPath:@"state"];
}

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic nodeId:(NSString *)nodeId {
    self = [super init];
    if (self) {
        _ability = ability;
        _host = host;
        _port = port;
        _user = user;
        _pass = pass;
        _clientId = clientId;
        _rootTopic = rootTopic;
        _nodeId = nodeId;
        _sessionManager = [MQTTSessionManager new];
        _sessionManager.delegate = self;
        _sessionManager.subscriptions = @{[NSString stringWithFormat:@"%@/%@", self.rootTopic, self.nodeId]: @1,
                                          [NSString stringWithFormat:@"%@/%@/%@", self.rootTopic, self.nodeId, self.clientId]: @1};
        [_sessionManager addObserver:self
                          forKeyPath:@"state"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:nil];
    }
    return self;
}

- (BOOL)isConnected {
    if (self.sessionManager.state == MQTTSessionManagerStateConnected) {
        return YES;
    }
    return NO;
}

- (void)addSubscriptionQueue:(NSString *)queue {
    NSAssert(queue != nil, @"queue name Can't be nil");
    NSDictionary *effectiveSubscriptions = [self.sessionManager.effectiveSubscriptions mutableCopy];
    if (![effectiveSubscriptions objectForKey:queue]) {
        NSMutableDictionary *subscriptions = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.subscriptions];
        [subscriptions setValue:@(1) forKey:queue];
        self.sessionManager.subscriptions = subscriptions;
    }
}

- (void)cancelSubscriptionQueue:(NSString *)queue {
    NSAssert(queue != nil, @"queue name Can't be nil");
    NSMutableDictionary *subscriptions = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.subscriptions];
    [subscriptions removeObjectForKey:queue];
    
    self.sessionManager.subscriptions = subscriptions;
}

- (void)connect {
    [self.sessionManager connectTo:self.host
                              port:self.port
                               tls:NO
                         keepalive:60
                             clean:true
                              auth:true
                              user:self.user
                              pass:self.pass
                              will:false
                         willTopic:nil
                           willMsg:nil
                           willQos:1
                    willRetainFlag:FALSE
                      withClientId:self.clientId
                    securityPolicy:nil
                      certificates:nil
                     protocolLevel:MQTTProtocolVersion311
                    connectHandler:nil];
}

- (void)reconnect {
    [self.sessionManager connectToLast:nil];
}

- (void)disconnect {
     [self.sessionManager disconnectWithDisconnectHandler:nil];
}

- (void)send:(PWCommand<PWCommandSendable> *)command toDevice:(PWRemoteDevice *)device {
    command.fromId = self.clientId;
    command.toId = device.clientId;
    [self.sessionManager sendData:command.dataRepresentation
                     topic:[NSString stringWithFormat:@"%@/%@/%@", self.rootTopic, self.nodeId, device.clientId]
                       qos:1
                    retain:false];
}

- (void)send:(PWCommand<PWCommandSendable> *)command topic:(NSString *)topic {
    [self.sessionManager sendData:command.dataRepresentation
                            topic:topic
                              qos:1
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
