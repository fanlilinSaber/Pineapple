//
//  PWProxy.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/4/17.
//
//

#import "PWProxy.h"
#import <MQTTClient/MQTTSessionManager.h>

@interface PWProxy () <MQTTSessionManagerDelegate>
/*&* MQTT sessionManager*/
@property (strong, nonatomic) MQTTSessionManager *sessionManager;
/*&* ability*/
@property (strong, nonatomic) PWAbility *ability;
/*&* host*/
@property (copy, nonatomic) NSString *host;
/*&* port*/
@property (nonatomic) NSInteger port;
/*&* 用户名*/
@property (copy, nonatomic) NSString *user;
/*&* 密码*/
@property (copy, nonatomic) NSString *pass;
/*&* clientId*/
@property (copy, nonatomic) NSString *clientId;
/*&* 根节点*/
@property (copy, nonatomic) NSString *rootTopic;
/*&* 子节点*/
@property (copy, nonatomic) NSString *nodeId;

@end

@implementation PWProxy

- (void)dealloc
{
    [_sessionManager disconnectWithDisconnectHandler:nil];
    [_sessionManager removeObserver:self forKeyPath:@"state"];
}

#pragma mark - init Method

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic nodeId:(NSString *)nodeId
{
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
        /*&* new MQTTSessionManager*/
        _sessionManager = [MQTTSessionManager new];
        _sessionManager.delegate = self;
        if (nodeId == nil) {
            _sessionManager.subscriptions = @{[NSString stringWithFormat:@"%@", self.rootTopic]: @2,
                                              [NSString stringWithFormat:@"%@/%@", self.rootTopic, self.clientId]: @2};
        }else {
            _sessionManager.subscriptions = @{[NSString stringWithFormat:@"%@/%@", self.rootTopic, self.nodeId]: @2,
                                              [NSString stringWithFormat:@"%@/%@/%@", self.rootTopic, self.nodeId, self.clientId]: @2};
        }
        
        [_sessionManager addObserver:self
                          forKeyPath:@"state"
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:nil];
    }
    return self;
}

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(NSInteger)port user:(NSString *)user pass:(NSString *)pass clientId:(NSString *)clientId rootTopic:(NSString *)rootTopic
{
    return [self initWithAbility:ability host:host port:port user:user pass:pass clientId:clientId rootTopic:rootTopic nodeId:nil];
}

#pragma mark - public Method

- (BOOL)isConnected
{
    if (self.sessionManager.state == MQTTSessionManagerStateConnected) {
        return YES;
    }
    return NO;
}

- (void)addSubscriptionQueue:(NSString *)queue
{
    NSAssert(queue != nil, @"queue name Can't be nil");
    NSDictionary *effectiveSubscriptions = [self.sessionManager.effectiveSubscriptions mutableCopy];
    if (![effectiveSubscriptions objectForKey:queue]) {
        NSMutableDictionary *subscriptions = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.subscriptions];
        [subscriptions setValue:@(2) forKey:queue];
        self.sessionManager.subscriptions = subscriptions;
    }
}

- (void)cancelSubscriptionQueue:(NSString *)queue
{
    NSAssert(queue != nil, @"queue name Can't be nil");
    NSMutableDictionary *subscriptions = [[NSMutableDictionary alloc] initWithDictionary:self.sessionManager.subscriptions];
    [subscriptions removeObjectForKey:queue];
    self.sessionManager.subscriptions = subscriptions;
}

- (void)connect
{
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
                           willQos:2
                    willRetainFlag:FALSE
                      withClientId:self.clientId
                    securityPolicy:nil
                      certificates:nil
                     protocolLevel:MQTTProtocolVersion311
                    connectHandler:nil];
}

- (void)reconnect
{
    [self.sessionManager connectToLast:nil];
}

- (void)disconnect
{
     [self.sessionManager disconnectWithDisconnectHandler:nil];
}

- (void)send:(PWCommand<PWCommandSendable> *)command toDevice:(PWRemoteDevice *)device
{
    command.fromId = self.clientId;
    command.toId = device.clientId;
    NSString *topic = [NSString stringWithFormat:@"%@/%@/%@", self.rootTopic, self.nodeId, device.clientId];
    if (self.nodeId == nil) {
        topic = [NSString stringWithFormat:@"%@/%@", self.rootTopic, device.clientId];
    }
    [self.sessionManager sendData:command.dataRepresentation
                            topic:topic
                              qos:2
                           retain:false];
}

- (void)send:(PWCommand<PWCommandSendable> *)command topic:(NSString *)topic
{
    [self.sessionManager sendData:command.dataRepresentation
                            topic:topic
                              qos:2
                           retain:false];
}

#pragma mark - private Method
#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
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

- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained
{
    PWCommand *command = [self.ability commandWithData:data];
    [self.delegate proxy:self didReceiveCommand:command];    
}

@end
