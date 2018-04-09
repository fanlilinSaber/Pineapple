//
//  PWMQDevice.m
//  Pineapple iOS
//
//  Created by 范李林 on 2018/3/12.
//

#import "PWMQDevice.h"
#import <RMQClient/RMQClient.h>

@interface PWMQDevice ()

@property (strong, nonatomic) PWAbility *ability;
/*&* <##>*/
@property (nonatomic, strong) RMQConnection *conn;
/*&* <##>*/
@property (nonatomic, weak) id<RMQChannel> ch;


@end

@implementation PWMQDevice

- (instancetype)initWithAbility:(PWAbility *)ability name:(NSString *)name uri:(NSString *)uri {
    self = [super initWithName:name clientId:nil];
    if (self) {
        _ability = ability;
        _uri = uri;
    }
    return self;
}

- (void)connect {
    if (!self.conn) {
        self.conn = [[RMQConnection alloc] initWithUri:self.uri delegate:[RMQConnectionDelegateLogger new]];
//        self.conn = [[RMQConnection alloc] initWithDelegate:[RMQConnectionDelegateLogger new]];
    }
    [self.conn start];
    
    id<RMQChannel> ch = [self.conn createChannel];
    self.ch = ch;
    
//    RMQExchange *x = [ch fanout:@"exchangeTest" options:RMQExchangeDeclareDurable];
    RMQExchange *x = [ch topic:@"exchangeTest" options:RMQExchangeDeclareDurable];
//    RMQQueue *q = [ch queue:@"" options:RMQQueueDeclareExclusive];
    
    RMQQueue *q = [ch queue:@"queue_one_key_ios" options:RMQQueueDeclareExclusive];
    [q bind:x routingKey:@"queue_one_key_ios1"];
    
    NSLog(@"Waiting for logs.");
    [q subscribe:RMQBasicConsumeNoOptions handler:^(RMQMessage * _Nonnull message) {
        NSLog(@"---Received %@", [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
    }];
//    NSLog(@"q.name = %@",q.name);
//    [ch.defaultExchange publish:[@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding] routingKey:q.name]; // 发送
    [x publish:[@"Hello World!" dataUsingEncoding:NSUTF8StringEncoding] routingKey:@"queue_one_key1"];
//    [self.conn close];
}

- (void)send:(NSString *)text {
    [self.ch.defaultExchange publish:[text dataUsingEncoding:NSUTF8StringEncoding] routingKey:@"queue_one_key1"];
}


#pragma mark - RMQConnectionDelegate

//- (void)connection:(RMQConnection *)connection failedToConnectWithError:(NSError *)error {
//    if (error) {
//        NSLog(@"%@",error);
//        NSLog(@"连接超时");
//    }
//}
//
//- (void)connection:(RMQConnection *)connection disconnectedWithError:(NSError *)error {
//    if (error) {
//        NSLog(@"%@",error);
//    }else {
//        NSLog(@"连接成功");
//    }
//}
//
//- (void)willStartRecoveryWithConnection:(RMQConnection *)connection {
//
//}

@end
