//
//  PWListener.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/31.
//
//

#import "PWListener.h"
@import CocoaAsyncSocket;

NSInteger const PWListenerPort = 5000;

@interface PWListener () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *listenSocket;

@end

@implementation PWListener

- (void)start {
    if (!self.listenSocket) {
        self.listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    NSError *error = nil;
    if (![self.listenSocket acceptOnPort:PWListenerPort error:&error]) {
        [self.delegate listenerDidStartFailed:self];
    } else {
        [self.delegate listenerDidStartSuccess:self];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    PWDevice *device = [[PWDevice alloc] initWithAbility:[PWAbility new] socket:newSocket];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate listener:self didConnectDevice:device];
    });
}

@end
