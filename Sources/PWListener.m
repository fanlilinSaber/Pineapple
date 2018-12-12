//
//  PWListener.m
//  Pineapple
//
//  Created by Fan Li Lin on 2017/3/31.
//
//

#import "PWListener.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@interface PWListener () <GCDAsyncSocketDelegate>
/*&* 核心 socket */
@property (strong, nonatomic) GCDAsyncSocket *listenSocket;
/*&* ability*/
@property (strong, nonatomic) PWAbility *ability;
/*&* port*/
@property (nonatomic) NSInteger port;

@end

@implementation PWListener

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - @init Method

- (instancetype)initWithAbility:(PWAbility *)ability port:(NSInteger)port
{
    self = [super init];
    if (self) {
        _ability = ability;
        _port = port;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

#pragma mark - @public Method

- (void)start
{
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

- (void)disconnect
{
    [self.listenSocket disconnect];
}

#pragma mark - @Handle App Life Cycle

- (void)appWillResignActive
{
    [self.listenSocket disconnect];
}

- (void)appDidBecomeActive
{
    [self start];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    PWLocalDevice *device = [[PWLocalDevice alloc] initWithAbility:self.ability socket:newSocket];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate listener:self didConnectDevice:device];
    });
}

@end
