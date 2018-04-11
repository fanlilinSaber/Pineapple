//
//  PWLocalDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWLocalDevice.h"
#import "PWHeader.h"
#import "PWKeepLiveCommand.h"
#import "PWAckCommand.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

static NSInteger const PWTagHeader = 10;
static NSInteger const PWTagBody = 11;
static NSTimeInterval const PWKeepLiveTimeInterval = 60;
static NSTimeInterval const PWAckQueueTimeInterval = 3;

@interface PWLocalDevice () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) PWAbility *ability;
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (nonatomic, getter=isOwner) BOOL owner;
/*&* 无序的 key拿字典来存储*/
@property (nonatomic, strong) NSMutableDictionary *ackQueueSource;
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *ackQueueSourceKey;
/*&* <##>*/
@property (nonatomic) dispatch_source_t keepLive_source_t;
/*&* <##>*/
@property (nonatomic) dispatch_source_t ackQueue_source_t;
/*&* */
@property (nonatomic, strong) NSMutableArray *ackMsgIdSource;
/*&* <##>*/
@property (nonatomic, copy) NSString *currentAckMsgId;

@end

@implementation PWLocalDevice

- (void)dealloc {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
    if (self.keepLive_source_t) {
        dispatch_source_cancel(self.keepLive_source_t);
        self.keepLive_source_t = NULL;
    }
    if (self.ackQueue_source_t) {
        dispatch_source_cancel(self.ackQueue_source_t);
        self.ackQueue_source_t = NULL;
    }
}

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name host:(NSString *)host port:(int)port reconnect:(BOOL)reconnect {
    self = [super initWithName:name clientId:nil];
    if (self) {
        _owner = YES;
        _ability = ability;
        _host = host;
        _port = port;
        if (reconnect) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
    return self;
}

- (instancetype)initWithAbility:(PWAbility *)ability socket:(GCDAsyncSocket *)socket {
    self = [super initWithName:@"未知" clientId:nil];
    if (self) {
        _owner = NO;
        _ability = ability;
        _host = socket.connectedHost;
        _port = socket.connectedPort;
        _socket = socket;
        _socket.delegate = self;
        _socket.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (void)setEnabledAck:(BOOL)enabledAck {
    _enabledAck = enabledAck;
    if (enabledAck) {
        _ackQueueSource = [NSMutableDictionary dictionary];
        _ackMsgIdSource = [NSMutableArray array];
        _ackQueueSourceKey = [NSMutableArray array];
    }
}

- (BOOL)isConnected {
    return [self.socket isConnected];
}

- (void)connect {
    if (self.owner) {
        [self connectWithRead:NO];
    } else {
        [self connectWithRead:YES];
    }
}

- (void)disconnect {
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
    if (self.isEnabledAck) {
        [self.ackQueueSource removeAllObjects];
        [self.ackMsgIdSource removeAllObjects];
        [self.ackQueueSourceKey removeAllObjects];
    }
}

- (void)send:(PWCommand<PWCommandSendable> *)command {
    if (command.isEnabledAck && self.isEnabledAck) {
        NSString *uuidString = [self uuidString];
        command.msgId = uuidString;
        NSData *body = command.dataRepresentation;
        NSData *header = [[[PWHeader alloc] initWithContentLength:body.length] dataRepresentation];
        NSMutableData *data = [[NSMutableData alloc] initWithData:header];
        [data appendData:body];
        [self.ackQueueSource setValue:data forKey:command.msgId];
        [self.ackQueueSourceKey addObject:command.msgId];
        [self ackMaybeDequeueWrite];
    }else {
        NSData *body = command.dataRepresentation;
        NSData *header = [[[PWHeader alloc] initWithContentLength:body.length] dataRepresentation];
        NSMutableData *data = [[NSMutableData alloc] initWithData:header];
        [data appendData:body];
        [self.socket writeData:data withTimeout:-1 tag:0];
    }
}

- (void)ackMaybeDequeueWrite {
     if ([self.socket isConnected]) {
         if (self.ackQueueSourceKey.count > 0 && self.currentAckMsgId == nil) {
             self.currentAckMsgId = self.ackQueueSourceKey.firstObject;
             NSData *writeData = [self.ackQueueSource valueForKey:self.currentAckMsgId];
             [self sendData:writeData];
         }
     }else {
         if (self.ackQueue_source_t) {
             dispatch_source_cancel(self.ackQueue_source_t);
             self.ackQueue_source_t = NULL;
         }
     }
}

#pragma mark - uuidString
- (NSString *)uuidString {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString ;
}

#pragma mark - Handle App Life Style

- (void)appDidBecomeActive {
    [self connectWithRead:NO];
}

#pragma mark - Private

- (void)addReceiveMsgId:(NSString *)msgId {
    [self.ackMsgIdSource addObject:msgId];
    if (self.ackMsgIdSource.count == 20) {
        [self.ackMsgIdSource removeObjectsInRange:NSMakeRange(0, 10)];
    }
}

- (void)sendData:(NSData *)data {
    [self.socket writeData:data withTimeout:-1 tag:0];
}

- (void)connectWithRead:(BOOL)read {
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [self.socket setIPv4PreferredOverIPv6:NO]; /*&* 设置支持IPV6 默认情况下,首选协议IPV6*/
    }
    if ([self.socket isDisconnected]) {
        NSError *error = nil;
        if (![self.socket connectToHost:self.host onPort:self.port withTimeout:5 error:&error]) {
            [self.delegate device:self didConnectFailedError:error];
        }
    } else if (read) {
        [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
    }
    /*&* 作为服务端不主动发送心跳包 由客户端发送 → 服务端收到并回复 (客户端控制心跳频率)*/
    if (self.owner) {
        if (self.keepLive_source_t) {
            dispatch_source_cancel(self.keepLive_source_t);
            self.keepLive_source_t = NULL;
        }
        [self startKeepLiveTimer];
    }
    if (self.isEnabledAck) {
        if (self.ackQueue_source_t) {
            dispatch_source_cancel(self.ackQueue_source_t);
            self.ackQueue_source_t = NULL;
        }
        [self startAckQueueTimer];
    }
}

- (void)keepLive {
    if ([self.socket isConnected]) {
        [self send:[PWKeepLiveCommand new]];
    } else {
        if (self.keepLive_source_t) {
            dispatch_source_cancel(self.keepLive_source_t);
            self.keepLive_source_t = NULL;
        }
    }
}

- (void)ackQueueCommand:(PWAckCommand<PWCommandSendable> *)command {
    if (self.currentAckMsgId != nil && [self.currentAckMsgId isEqualToString:command.sourceMsgId]) {
        if ([self.ackQueueSource valueForKey:command.sourceMsgId]) {
            [self.ackQueueSource removeObjectForKey:command.sourceMsgId];
            [self.ackQueueSourceKey removeObjectAtIndex:0];
            self.currentAckMsgId = nil;
            [self ackMaybeDequeueWrite];
        }
    }
}

- (void)startAckQueueTimer {
     __weak PWLocalDevice *weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), PWAckQueueTimeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{ @autoreleasepool {
        __strong PWLocalDevice *strongSelf = weakSelf;
        if (strongSelf == nil) {return ;}
        [strongSelf ackMaybeDequeueWrite];
    }});
    dispatch_resume(timer);
    self.ackQueue_source_t = timer;
}

- (void)startKeepLiveTimer {
    __weak PWLocalDevice *weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0), PWKeepLiveTimeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{ @autoreleasepool {
        __strong PWLocalDevice *strongSelf = weakSelf;
        if (strongSelf == nil) {return ;}
        [strongSelf keepLive];
    }});
    dispatch_resume(timer);
    self.keepLive_source_t = timer;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.keepLive_source_t == NULL) {
            [self startKeepLiveTimer];
        }
        if (self.isEnabledAck && self.ackQueue_source_t == NULL) {
            [self startAckQueueTimer];
        }
        [self.delegate deviceDidConnectSuccess:self];
    });
    [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    self.socket.delegate = nil;
    self.socket = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            /*&* socket serve closed*/
            if (error.code == 7) {
                [self.delegate device:self remoteDidDisconnectError:error];
            }else{
                [self.delegate device:self didConnectFailedError:error];
            }
        } else {
            [self.delegate deviceDidDisconnectSuccess:self];
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == PWTagHeader) {
        PWHeader *header = [[PWHeader alloc] initWithData:data];
        [self.socket readDataToLength:header.contentLength withTimeout:-1 tag:PWTagBody];
    } else if (tag == PWTagBody) {
        PWCommand *command = [self.ability commandWithData:data];
        if (command != nil) {
            /*&* 心跳包*/
            if ([command.msgType isEqualToString:[PWKeepLiveCommand msgType]]) {
                if (!self.owner) {
                    [self send:(PWKeepLiveCommand *)command];
                }
            }
            /*&* ack*/
            else if ([command.msgType isEqualToString:[PWAckCommand msgType]]) {
                [self ackQueueCommand:(PWAckCommand *)command];
            }
            else {
                if (command.msgId.length > 0) {
                    /*&* 回复 ack*/
                    [self send:[[PWAckCommand alloc] initWithSourceMsgId:command.msgId sourceMsgType:command.msgType]];
                    
                    if (![self.ackMsgIdSource containsObject:command.msgId]) {
                        
                        [self addReceiveMsgId:command.msgId];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate device:self didReceiveCommand:command];
                        });
                    }
                    
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate device:self didReceiveCommand:command];
                    });
                }
            }
        }
        [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
    }
}

@end
