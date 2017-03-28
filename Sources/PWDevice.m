//
//  PWDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWDevice.h"
@import CocoaAsyncSocket;

@interface PWDevice () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation PWDevice

- (instancetype)initWithAbility:(PWAbility *)ability host:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _ability = ability;
        _host = host;
        _port = port;
    }
    return self;
}

- (void)connect {
    if (!self.socket) {
       self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    if ([self.socket isDisconnected]) {
        NSError *error = nil;
        if (![self.socket connectToHost:self.host onPort:self.port error:&error]) {
            NSLog(@"Connect to host failed: %@", error);
        }
    }
}

- (void)send:(PWCommand *)command {
    // TODO: Send Command: RCAsyncSocket
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"Connected to %@:%d", host, port);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUnicodeStringEncoding];
    NSLog(@"%@", message);
}

@end
