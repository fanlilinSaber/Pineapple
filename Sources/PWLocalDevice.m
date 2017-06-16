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
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

static NSInteger const PWTagHeader = 10;
static NSInteger const PWTagBody = 11;
static NSTimeInterval const PWKeepLiveTimeInterval = 60;

@interface PWLocalDevice () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) PWAbility *ability;
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSTimer *keepLiveTimer;
@property (nonatomic, getter=isOwner) BOOL owner;

@end

@implementation PWLocalDevice

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
}

- (void)send:(PWCommand<PWCommandSendable> *)command {
    NSData *body = command.dataRepresentation;
    NSData *header = [[[PWHeader alloc] initWithContentLength:body.length] dataRepresentation];
    NSMutableData *data = [[NSMutableData alloc] initWithData:header];
    [data appendData:body];
    [self.socket writeData:data withTimeout:-1 tag:0];
}

#pragma mark - Handle App Life Style

- (void)appDidBecomeActive {
    [self connectWithRead:NO];
}

#pragma mark - Private

- (void)connectWithRead:(BOOL)read {
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    if ([self.socket isDisconnected]) {
        NSError *error = nil;
        if (![self.socket connectToHost:self.host onPort:self.port error:&error]) {
            [self.delegate device:self didConnectFailedMessage:[error localizedDescription]];
        }
    } else if (read) {
        [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
    }
    if (self.keepLiveTimer) {
        [self.keepLiveTimer invalidate];
        self.keepLiveTimer = nil;
    }
    self.keepLiveTimer = [NSTimer scheduledTimerWithTimeInterval:PWKeepLiveTimeInterval target:self selector:@selector(keepLive) userInfo:nil repeats:YES];
}

- (void)keepLive {
    if ([self.socket isConnected]) {
        [self send:[PWKeepLiveCommand new]];
    } else {
        [self.keepLiveTimer invalidate];
        self.keepLiveTimer = nil;
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceDidConnectSuccess:self];
    });
    [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    self.socket.delegate = nil;
    self.socket = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.delegate device:self didDisconnectFailedMessage:[error localizedDescription]];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate device:self didReceiveCommand:command];
            });
        }
        [self.socket readDataToData:[PWHeader endTerm] withTimeout:-1 tag:PWTagHeader];
    }
}

@end
