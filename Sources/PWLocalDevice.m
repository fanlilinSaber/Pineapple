//
//  PWLocalDevice.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/27.
//
//

#import "PWLocalDevice.h"
#import "PWHeader.h"
#import "PWKeepLiveCommand.h"
#import "PWAckCommand.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

/*&* 消息头 tag header*/
static NSInteger const PWTagHeader = 10;
/*&* 消息主要内容 tag content*/
static NSInteger const PWTagBody = 11;
/*&* 心跳间隔 单位：秒*/
static NSTimeInterval const PWKeepLiveTimeInterval = 60;
/*&* ack 消息队列检测 单位：秒*/
static NSTimeInterval const PWAckQueueTimeInterval = 5;

@interface PWLocalDevice () <GCDAsyncSocketDelegate>
/*&* socket通信command注册*/
@property (strong, nonatomic) PWAbility *ability;
/*&* socket通信组件*/
@property (strong, nonatomic) GCDAsyncSocket *socket;
/*&* socket 是否是自己new出来的;作为服务端和客服端判断*/
@property (nonatomic, getter=isOwner) BOOL owner;
/*&* ack 消息缓冲队列 无序的 key拿字典来存储*/
@property (nonatomic, strong) NSMutableDictionary *ackQueueSource;
/*&* ack 消息缓冲队列 对应key*/
@property (nonatomic, strong) NSMutableArray *ackQueueSourceKey;
/*&* 心跳 source timer*/
@property (nonatomic, strong) dispatch_source_t keepLive_source_t;
/*&* ack 消息队列循环检测 source timer*/
@property (nonatomic, strong) dispatch_source_t ackQueue_source_t;
/*&* ack 消息派发队列*/
@property (nonatomic, strong) dispatch_queue_t ackQueue;
/*&* 用来记录最近收到的ack消息 避免其他因素导致重复回复*/
@property (nonatomic, strong) NSMutableArray *ackRecentMsgId;
/*&* 当前发送的ack command 的MsgId; 用来避免因为后收到其他回复的ack MsgId 导致消息乱序*/
@property (nonatomic, copy) NSString *currentAckMsgId;
/*&* 重连机制*/
@property (nonatomic, assign, getter=isReconnect) BOOL reconnect;
/*&* 标记ack消息回复和消息队列循环检测 source 后续方法重复调用*/
@property (nonatomic, assign, getter=isSendQueueData) BOOL sendQueueData;
/*&* ack 派发队列状态*/
@property (nonatomic, assign, getter=isAckQueueRuning) BOOL ackQueueRuning;
@end

@implementation PWLocalDevice

- (void)dealloc
{
    if (self.isReconnect) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    if (self.keepLive_source_t) {
        dispatch_source_cancel(self.keepLive_source_t);
        self.keepLive_source_t = NULL;
    }
    if (self.ackQueue_source_t) {
        dispatch_source_cancel(self.ackQueue_source_t);
        self.ackQueue_source_t = NULL;
    }
    if (self.ackQueue) {
        self.ackQueue = NULL;
    }
#ifdef DEBUG
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
#else
#endif
    
}

#pragma mark - init Method

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name host:(NSString *)host port:(int)port reconnect:(BOOL)reconnect
{
    self = [super initWithName:name clientId:nil];
    if (self) {
        _owner = YES;
        _enabledAck = NO;
        _ability = ability;
        _host = host;
        _port = port;
        _reconnect = reconnect;
        if (reconnect) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        }
    }
    return self;
}

- (instancetype)initWithAbility:(PWAbility *)ability socket:(GCDAsyncSocket *)socket
{
    self = [super initWithName:@"未知" clientId:nil];
    if (self) {
        _owner = NO;
        _enabledAck = NO;
        _ability = ability;
        _host = socket.connectedHost;
        _port = socket.connectedPort;
        _socket = socket;
        _socket.delegate = self;
        _socket.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

#pragma mark - setters

- (void)setEnabledAck:(BOOL)enabledAck
{
    _enabledAck = enabledAck;
    if (enabledAck) {
        _ackQueueSource = [NSMutableDictionary dictionary];
        _ackRecentMsgId = [NSMutableArray array];
        _ackQueueSourceKey = [NSMutableArray array];
    }
}

#pragma mark - uuidString

- (NSString *)uuidString
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuidObj);
    return uuidString ;
}

#pragma mark - Handle App Life Style

- (void)appDidBecomeActive
{
    [self connectWithRead:NO];
}

#pragma mark - public Method

- (BOOL)isConnected
{
    return [self.socket isConnected];
}

- (void)connect
{
    if (self.owner) {
        [self connectWithRead:NO];
    } else {
        [self connectWithRead:YES];
    }
}

- (void)disconnect
{
    if ([self.socket isConnected]) {
        [self.socket disconnect];
    }
    if (self.isEnabledAck) {
        [self.ackQueueSource removeAllObjects];
        [self.ackRecentMsgId removeAllObjects];
        [self.ackQueueSourceKey removeAllObjects];
    }
    if (self.keepLive_source_t) {
        dispatch_source_cancel(self.keepLive_source_t);
        self.keepLive_source_t = NULL;
    }
    if (self.ackQueue_source_t) {
        self.ackQueueRuning = NO;
        dispatch_source_cancel(self.ackQueue_source_t);
        self.ackQueue_source_t = NULL;
    }
    if (self.ackQueue) {
        self.ackQueue = NULL;
    }
}

- (void)send:(PWCommand<PWCommandSendable> *)command
{
    PWCommand<PWCommandSendable> *newCommand = [command mutableCopy];
    if (newCommand.isEnabledAck && self.isEnabledAck) {
        dispatch_barrier_async(self.ackQueue, ^{
            NSString *uuidString = [self uuidString];
            newCommand.msgId = uuidString;
            NSData *body = newCommand.dataRepresentation;
            NSData *header = [[[PWHeader alloc] initWithContentLength:body.length] dataRepresentation];
            NSMutableData *data = [[NSMutableData alloc] initWithData:header];
            [data appendData:body];
            /*&* 当前消息队列闲置时候才马上发送 队列里的消息必须顺序执行*/
            if (![self isAckQueueCount]) {
                self.currentAckMsgId = newCommand.msgId;
                [self sendData:data];
            }
            /*&* 添加到ack缓存队列里*/
            [self addAckQueueData:data msgId:newCommand.msgId];
            if (self.ackQueue_source_t == NULL) {
                [self startAckQueueTimer];
            }
        });
        
    }else {
        NSData *body = newCommand.dataRepresentation;
        NSData *header = [[[PWHeader alloc] initWithContentLength:body.length] dataRepresentation];
        NSMutableData *data = [[NSMutableData alloc] initWithData:header];
        [data appendData:body];
        [self.socket writeData:data withTimeout:-1 tag:0];
    }
}

#pragma mark - private Method
/*&* ack消息体 队列检测发送*/
- (void)ackMaybeDequeueWrite
{
    if ([self.socket isConnected]) {
        if (self.isSendQueueData) {
            return;
        }
        self.sendQueueData = YES;
        if ([self isAckQueueCount]) {
            self.currentAckMsgId = self.ackQueueSourceKey.firstObject;
            NSData *writeData = [self.ackQueueSource valueForKey:self.currentAckMsgId];
            //            NSString *str =[[NSString alloc] initWithData:writeData encoding:NSUTF8StringEncoding];
            //            NSLog(@"再次发送 %@",str);
            [self sendData:writeData];
        }else {
            [self cancelAckQueueTimer];
        }
        self.sendQueueData = NO;
    }else {
        [self cancelAckQueueTimer];
    }
}

/*&* ack消息队列 count*/
- (BOOL)isAckQueueCount
{
    if (self.ackQueueSource.count > 0 && self.ackQueueSourceKey.count > 0) {
        return YES;
    }
    return NO;
}

/*&* 添加ack消息体到ack缓存队列里*/
- (void)addAckQueueData:(NSData *)data msgId:(NSString *)msgId
{
    [self.ackQueueSource setValue:data forKey:msgId];
    [self.ackQueueSourceKey addObject:msgId];
}

/*&* 添加收到的ack消息体msgId 只保留最近20条记录*/
- (void)addReceiveMsgId:(NSString *)msgId
{
    [self.ackRecentMsgId addObject:msgId];
    if (self.ackRecentMsgId.count == 20) {
        [self.ackRecentMsgId removeObjectsInRange:NSMakeRange(0, 10)];
    }
}

/*&* 发送command data*/
- (void)sendData:(NSData *)data
{
    [self.socket writeData:data withTimeout:-1 tag:0];
}

/*&* 连接 socket service*/
- (void)connectWithRead:(BOOL)read
{
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
    if (self.isEnabledAck) {
        if (self.ackQueue == NULL) {
            NSString *qName = [NSString stringWithFormat:@"com.ackQueue-%@", [[NSUUID UUID] UUIDString]];
            self.ackQueue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
        }
    }
}

/*&* 心跳包*/
- (void)keepLive
{
    if ([self.socket isConnected]) {
        [self send:[PWKeepLiveCommand new]];
    } else {
        if (self.keepLive_source_t) {
            dispatch_source_cancel(self.keepLive_source_t);
            self.keepLive_source_t = NULL;
        }
    }
}

/*&* 取消 ack queue source*/
- (void)cancelAckQueueTimer
{
    if (self.ackQueue_source_t && self.isAckQueueRuning) {
        self.ackQueueRuning = NO;
        dispatch_source_cancel(self.ackQueue_source_t);
        self.ackQueue_source_t = NULL;
    }
}

/*&* 恢复 ack queue source*/
- (void)resumeAckQueueTimer
{
    if (self.ackQueue_source_t && !self.isAckQueueRuning) {
        self.ackQueueRuning = YES;
        dispatch_resume(self.ackQueue_source_t);
    }else {
        [self startAckQueueTimer];
    }
}

/*&* ack队列消息体移除（收到ack回复消息后马上移除当前的ack消息体；并且循环队列里的下一个消息体）*/
- (void)ackQueueRemoveSourceMsgId:(NSString *)sourceMsgId
{
    if (self.ackQueue == NULL) {
        //        NSLog(@"return sourceMsgId = %@",sourceMsgId);
        return;
    }
    dispatch_barrier_async(self.ackQueue, ^{
        //        NSLog(@"currentAckMsgId = %@ , sourceMsgId = %@",self.currentAckMsgId,sourceMsgId);
        if (self.currentAckMsgId != nil && [self.currentAckMsgId isEqualToString:sourceMsgId]) {
            //            NSLog(@"ackQueueSourceKey = %@",self.ackQueueSourceKey);
            if ([self.ackQueueSource valueForKey:sourceMsgId]) {
                [self.ackQueueSource removeObjectForKey:sourceMsgId];
                [self.ackQueueSourceKey removeObjectAtIndex:0];
                self.currentAckMsgId = nil;
                [self ackMaybeDequeueWrite];
            }
        }
    });
}

/*&* 开始启用ack队列检测 source*/
- (void)startAckQueueTimer
{
    self.ackQueueRuning = YES;
    if (self.ackQueue == NULL) {
        NSString *qName = [NSString stringWithFormat:@"com.ackQueue-%@", [[NSUUID UUID] UUIDString]];
        self.ackQueue = dispatch_queue_create([qName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    }
    __weak PWLocalDevice *weakSelf = self;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,self.ackQueue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, PWAckQueueTimeInterval * NSEC_PER_SEC), PWAckQueueTimeInterval * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{ @autoreleasepool {
        __strong PWLocalDevice *strongSelf = weakSelf;
        if (strongSelf == nil) {return ;}
        [strongSelf ackMaybeDequeueWrite];
    }});
    dispatch_resume(timer);
    self.ackQueue_source_t = timer;
}

/*&* 开始启用心跳包 source*/
- (void)startKeepLiveTimer
{
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

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    dispatch_async(dispatch_get_main_queue(), ^{
        /*&* 作为服务端不主动发送心跳包 由客户端发送 → 服务端收到并回复 (客户端控制心跳频率)*/
        if (self.owner) {
            if (self.keepLive_source_t) {
                dispatch_source_cancel(self.keepLive_source_t);
                self.keepLive_source_t = NULL;
            }
            [self startKeepLiveTimer];
        }
        [self.delegate deviceDidConnectSuccess:self];
    });
    [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    self.socket.delegate = nil;
    self.socket = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            // socket serve closed
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

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
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
           /*&* ack回复*/
            else if ([command.msgType isEqualToString:[PWAckCommand msgType]]) {
                //                NSLog(@"收到ack 回复 消息了 %@",((PWAckCommand *)command).sourceMsgId);
                [self ackQueueRemoveSourceMsgId:((PWAckCommand *)command).sourceMsgId];
            }
            else {
                /*&* 如果接收到的'command'带有'msgId' 需要回复*/
                if (command.msgId.length > 0) {
                    /*&* 回复 ack*/
                    [self send:[[PWAckCommand alloc] initWithSourceMsgId:command.msgId sourceMsgType:command.msgType]];
                    /*&* 消息去重*/
                    if (![self.ackRecentMsgId containsObject:command.msgId]) {
                        
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


