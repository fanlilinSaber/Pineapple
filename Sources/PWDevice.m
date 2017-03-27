//
//  PWDevice.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWDevice.h"
@import CocoaAsyncSocket;

@implementation PWDevice

- (void)send {
    NSLog(@"send");

    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

@end
