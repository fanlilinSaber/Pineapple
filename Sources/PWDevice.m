//
//  PWDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWDevice.h"
#import "PWAbility.h"
@import CocoaAsyncSocket;

@interface PWDevice () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) Class ability;

@end

@implementation PWDevice

- (instancetype)initWithAbility:(Class)ability name:(NSString *)name host:(NSString *)host port:(int)port {
    self = [super init];
    if (self) {
        _ability = ability;
        _name = name;
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
            [self.delegate deviceDidConnectFailed:self];
        }
    }
}

- (void)send:(PWCommand<PWCommandSendable> *)command {
    [self.socket writeData:command.dataRepresentation withTimeout:-1 tag:0];
    [self.socket readDataWithTimeout:-1 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self.delegate deviceDidConnectSuccess:self];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    // TODO: Tag with Command
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {    
    PWCommand *command = [self.ability commandWithData:data];
    [self.delegate device:self didReceiveCommand:command];
}

@end
