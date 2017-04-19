//
//  PWListener.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/31.
//
//

#import "PWListener.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface PWListener () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *listenSocket;
@property (nonatomic) NSInteger port;

@end

@implementation PWListener

- (instancetype)initWithPort:(NSInteger)port {
    self = [super init];
    if (self) {
        _port = port;
    }
    return self;
}

- (void)start {
    if (!self.listenSocket) {
        self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:self.port error:&error]) {
        [self.delegate listenerDidStartFailed:self];
    } else {
        [self.delegate listenerDidStartSuccess:self];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    PWDevice *device = [[PWDevice alloc] initWithSocket:newSocket];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate listener:self didConnectDevice:device];
    });
}

@end
