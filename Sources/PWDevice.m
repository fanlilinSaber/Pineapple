//
//  PWDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWDevice.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface PWDevice () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation PWDevice

- (instancetype)initWithName:(NSString *)name host:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _name = name;
        _host = host;
        _port = port;
    }
    return self;
}

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket {
    self = [super init];
    if (self) {
        _name = @"未知";
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
    if (!self.socket) {
       self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    if ([self.socket isDisconnected]) {
        NSError *error = nil;
        if (![self.socket connectToHost:self.host onPort:self.port error:&error]) {
            [self.delegate device:self didConnectFailedMessage:[error localizedDescription]];
        }
    } else {
        [self.socket readDataWithTimeout:-1 tag:0];
    }
}

- (void)disconnect {
    if ([self.socket isConnected]) {
        self.socket.delegate = nil;
        [self.socket disconnect];
        self.socket = nil;
    }
}

- (void)send:(PWCommand<PWCommandSendable> *)command {
    [self.socket writeData:command.dataRepresentation withTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate deviceDidConnectSuccess:self];
    });
    [self.socket readDataWithTimeout:-1 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
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
    PWCommand *command = [PWAbility commandWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate device:self didReceiveCommand:command];
    });
    [self.socket readDataWithTimeout:-1 tag:0];
}

@end
