//
//  PWHomeViewController.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWHomeViewController.h"
#import "PWAddLocalDeviceViewController.h"
#import "PWAddRemoteDeviceViewController.h"
#import "PWSendUDPViewController.h"
#import "PWDeviceCell.h"
#import "Pineapple.h"
#import <Masonry/Masonry.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import "PWASRStatusCommand.h"
#import "PWAddRMQViewController.h"
#import "PWUserLoginStatusCommand.h"

static NSString * const PWDeviceCellIdentifier = @"DeviceCell";

@interface PWHomeViewController () <UITableViewDelegate, UITableViewDataSource, PWAddLocalDeviceViewControllerDelegate, PWAddRemoteDeviceViewControllerDelegate, PWProxyDelegate, PWListenerDelegate, PWLocalDeviceDelegate, GCDAsyncUdpSocketDelegate, PWAddRMQViewControllerDelegate>

@property (strong, nonatomic) PWAbility *ability;
@property (strong, nonatomic) PWProxy *proxy;
@property (strong, nonatomic) PWListener *listener;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;
@property (copy, nonatomic) NSArray *devices;
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextView *textView;

@end

@implementation PWHomeViewController

- (void)dealloc {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}

- (void)loadView {
    [super loadView];
    
    self.title = @"设备列表";
    
    self.ability = [PWAbility new];
    [self.ability addCommand:[PWUserLoginStatusCommand class] withMsgType:[PWUserLoginStatusCommand msgType]];
    
    self.devices = @[];
    
    UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithTitle:@"开启" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    UIBarButtonItem *connect = [[UIBarButtonItem alloc] initWithTitle:@"连接" style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
    self.navigationItem.rightBarButtonItems = @[start, connect];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"开启" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"连接" style:UIBarButtonItemStylePlain target:self action:@selector(connect)];
    
    UITextField *textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    UIButton *sendButton = [UIButton new];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];

    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 40;
    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;    
    [tableView registerClass:[PWDeviceCell class] forCellReuseIdentifier:PWDeviceCellIdentifier];
    
    UITextView *textView = [UITextView new];
    textView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    textView.editable = false;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addSubview:textField];
    [self.view addSubview:sendButton];
    [self.view addSubview:tableView];
    [self.view addSubview:textView];

    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(10);
    }];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(textField.mas_trailing).with.offset(10);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-10);
        make.centerY.equalTo(textField.mas_centerY);
    }];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
    }];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tableView.mas_bottom);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.equalTo(@200);
    }];
    
    self.tableView = tableView;
    self.textView = textView;
    self.textField = textField;
    self.sendButton = sendButton;
}

#pragma mark - Action

- (void)start {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"开启"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                          handler:nil];
    UIAlertAction* mqttAction = [UIAlertAction actionWithTitle:@"MQTT" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self startMQTT];
                                                       }];
    UIAlertAction* socketAction = [UIAlertAction actionWithTitle:@"Socket" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self startSocket];
                                                         }];
    UIAlertAction* udpAction = [UIAlertAction actionWithTitle:@"UDP" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self startUDP];
                                                      }];
    [alert addAction:defaultAction];
    [alert addAction:mqttAction];
    [alert addAction:socketAction];
    [alert addAction:udpAction];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        alert.popoverPresentationController.sourceView = self.view;
        alert.popoverPresentationController.sourceRect = CGRectMake(0,0,1.0,1.0);;

    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startMQTT {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"开启 MQTT"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"GID_equipment001@@@";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *savelAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *clientId = alert.textFields.firstObject.text;
        self.proxy = [[PWProxy alloc] initWithAbility:self.ability host:@"mqf-er9w0k6ntu.mqtt.aliyuncs.com" port:1883 user:@"aEACwHFvAqv1A3eK" pass:@"LC4uWeVKgBiG9QigL3cP+estMYQ=" clientId:clientId rootTopic:@"topic_equipment001" nodeId:@"room1"];
        self.proxy.delegate = self;
        [self.proxy connect];
    }];
    [alert addAction:savelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startSocket {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"开启 Socket"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"50015";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *savelAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger port = alert.textFields.firstObject.text.intValue;
        self.listener = [[PWListener alloc] initWithAbility:self.ability port:port];
        self.listener.delegate = self;
        [self.listener start];
    }];
    [alert addAction:savelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startUDP {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"开启 UDP"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"50016";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    UIAlertAction *savelAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSInteger port = alert.textFields.firstObject.text.intValue;
        self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        NSError *error = nil;
        [self.socket bindToPort:port error:&error];
        [self.socket beginReceiving:&error];
        [self.socket setReceiveFilter:^BOOL(NSData * _Nonnull data, NSData * _Nonnull address, id  _Nullable __autoreleasing * _Nonnull context) {
            return [GCDAsyncUdpSocket isIPv4Address:address];
        } withQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) isAsynchronous:YES];
        if (error) {
            [self log:@"UDP 绑定失败"];
        } else {
            [self log:@"UDP 绑定成功"];
        }
    }];
    [alert addAction:savelAction];
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)connect {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"连接"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                          handler:nil];
    UIAlertAction* mqttAction = [UIAlertAction actionWithTitle:@"MQTT" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self addMQTT];
                                                       }];
    UIAlertAction* socketAction = [UIAlertAction actionWithTitle:@"Socket" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self addSocket];
                                                       }];
    UIAlertAction* udpAction = [UIAlertAction actionWithTitle:@"UDP" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           [self addUDP];
                                                       }];
    
    UIAlertAction* rmqAction = [UIAlertAction actionWithTitle:@"RMQ" style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [self addRMQ];
                                                      }];
    [alert addAction:defaultAction];
    [alert addAction:mqttAction];
    [alert addAction:socketAction];
    [alert addAction:udpAction];
    [alert addAction:rmqAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addMQTT {
    PWAddRemoteDeviceViewController *addRemoteDeviceViewController = [[PWAddRemoteDeviceViewController alloc] init];
    addRemoteDeviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addRemoteDeviceViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addSocket {
    PWAddLocalDeviceViewController *addDeviceViewController = [[PWAddLocalDeviceViewController alloc] initWithAbility:self.ability];
    addDeviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addDeviceViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addUDP {
    PWSendUDPViewController *sendUDPViewController = [[PWSendUDPViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:sendUDPViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addRMQ {
    PWAddRMQViewController *vc = [[PWAddRMQViewController alloc] initWithAbility:self.ability];
    vc.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)send {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    NSString *text = self.textField.text;
    if (indexPath && ![text isEqualToString:@""]) {
        PWTextCommand *comand = [[PWTextCommand alloc] initWithText:text];
//        NSArray *strs = [text componentsSeparatedByString:@"."];
//        PWASRStatusCommand *comand = [[PWASRStatusCommand alloc] initWithParams:@{@"operType" : strs.firstObject,
//                                                                                  @"topicNumber" : strs.lastObject
//                                                                                  }];
        
//        PWUserLoginStatusCommand *comand = [[PWUserLoginStatusCommand alloc] initWithUserToken:text];
        
        PWDevice *device = self.devices[indexPath.row];
        
        if ([device isKindOfClass:[PWLocalDevice class]]) {
            PWLocalDevice *localDevice = (PWLocalDevice *)device;
//            // 测试
            for (int i = 0; i < 30; i ++) {
//                PWTextCommand *comandNew = [[PWTextCommand alloc] initWithText:[NSString stringWithFormat:@"%d",i]];
                PWUserLoginStatusCommand *comandNew = [[PWUserLoginStatusCommand alloc] initWithUserToken:[NSString stringWithFormat:@"%d",i]];
//                PWTextCommand *comandNew = [[PWTextCommand alloc] initWithText:@"2"];
                [localDevice send:comandNew];

            }
//            [localDevice send:comand];
        }
        else if ([device isKindOfClass:[PWMQDevice class]]) {
            PWMQDevice *mqDevice = (PWMQDevice *)device;
            [mqDevice send:text];
        }
        else {
            PWRemoteDevice *remoteDevice = (PWRemoteDevice *)device;
            [self.proxy send:comand toDevice:remoteDevice];
        }
        self.textField.text = nil;
    }
}

#pragma mark - Private

- (void)addLocalDevice:(PWLocalDevice *)device {
    device.enabledAck = YES;
    device.delegate = self;
    [device connect];
    NSMutableArray *devices = [self.devices mutableCopy];
    [devices addObject:device];
    self.devices = devices;
    [self.tableView reloadData];
}

- (void)addRemoteDevice:(PWRemoteDevice *)device {
    BOOL existed = NO;
    for (PWDevice *eachDevice in self.devices) {
        if ([eachDevice isKindOfClass:[PWRemoteDevice class]]) {
            PWRemoteDevice *remoteDevice = (PWRemoteDevice *)eachDevice;
            if ([remoteDevice.clientId isEqualToString:device.clientId]) {
                existed = YES;
                break;
            }
        }
    }
    if (!existed) {
        NSMutableArray *devices = [self.devices mutableCopy];
        [devices addObject:device];
        self.devices = devices;
        [self.tableView reloadData];
    }
}

- (void)addMQDevice:(PWMQDevice *)device {
    [device connect];
    NSMutableArray *devices = [self.devices mutableCopy];
    [devices addObject:device];
    self.devices = devices;
    [self.tableView reloadData];
}

- (void)removeLocalDevice:(PWLocalDevice *)device {
    for (PWDevice *eachDevice in self.devices) {
        if ([eachDevice isKindOfClass:[PWLocalDevice class]]) {
            PWLocalDevice *localDevice = (PWLocalDevice *)eachDevice;
            if ([localDevice.host isEqualToString:device.host] && localDevice.port == device.port) {
                NSMutableArray *devices = [self.devices mutableCopy];
                [devices removeObject:device];
                self.devices = devices;
                [self.tableView reloadData];
            }
        }
    }
}

- (void)log:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text, text];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PWDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:PWDeviceCellIdentifier];
    PWDevice *device = self.devices[indexPath.row];
    if ([device isKindOfClass:[PWLocalDevice class]]) {
        PWLocalDevice *localDevice = (PWLocalDevice *)device;
        cell.nameLabel.text = localDevice.name;
        cell.addressLabel.text = [[NSString alloc] initWithFormat:@"%@:%d", localDevice.host, localDevice.port];
    } else {
        PWRemoteDevice *remoteDevice = (PWRemoteDevice *)device;
        cell.nameLabel.text = remoteDevice.name;
        cell.addressLabel.text = remoteDevice.clientId;
    }
    return cell;
}

#pragma mark - PWAddLocalDeviceViewControllerDelegate

- (void)addLocalDeviceViewControllerDidSave:(PWAddLocalDeviceViewController *)addLocalDeviceViewController withDevice:(PWLocalDevice *)device {
    [self dismissViewControllerAnimated:true completion:^{
        [self addLocalDevice:device];
    }];
}

#pragma mark - PWAddRemoteDeviceViewControllerDelegate

- (void)addRemoteDeviceViewControllerDidSave:(PWAddRemoteDeviceViewController *)addRemoteDeviceViewController withDevice:(PWRemoteDevice *)device {
    [self dismissViewControllerAnimated:true completion:^{
        [self addRemoteDevice:device];
    }];
}

#pragma mark - PWAddRMQViewControllerDelegate

- (void)addMQDeviceViewControllerDidSave:(PWAddRMQViewController *)addMQDeviceViewController withDevice:(PWMQDevice *)device {
    [self dismissViewControllerAnimated:true completion:^{
        [self addMQDevice:device];
    }];
}

#pragma mark - PWListenerDelegate

- (void)listenerDidStartSuccess:(PWListener *)listener {
    [self log:@"Socket 监听成功"];
}

- (void)listenerDidStartFailed:(PWListener *)listener {
    [self log:@"Socket 监听失败"];
}

- (void)listener:(PWListener *)listener didConnectDevice:(PWLocalDevice *)device {
    [self addLocalDevice:device];
}

#pragma mark - PWProxyDelegate

- (void)proxyClosed:(PWProxy *)proxy {
    [self log:@"MQTT 已关闭"];
}

- (void)proxyClosing:(PWProxy *)proxy {
    [self log:@"MQTT 关闭中"];
}

- (void)proxyConnected:(PWProxy *)proxy {
    [self log:@"MQTT 已连接"];
}

- (void)proxyConnecting:(PWProxy *)proxy {
    [self log:@"MQTT 连接中"];
}

- (void)proxyError:(PWProxy *)proxy {
    [self log:@"MQTT 出错了"];
}

- (void)proxyStarting:(PWProxy *)proxy {
    [self log:@"MQTT 开始中"];
}

- (void)proxy:(PWProxy *)proxy didReceiveCommand:(PWCommand *)command {
    if ([command.msgType isEqualToString:PWTextCommand.msgType]) {
        PWTextCommand *textCommand = (PWTextCommand *)command;
        [self log:[NSString stringWithFormat:@"%@->%@", textCommand.fromId, textCommand.text]];
        PWRemoteDevice *device = [[PWRemoteDevice alloc] initWithName:@"未知" clientId:textCommand.fromId];
        [self addRemoteDevice:device];
    }
}

#pragma mark - PWLocalDeviceDelegate

- (void)deviceDidConnectSuccess:(PWLocalDevice *)device {
    [self log:[NSString stringWithFormat:@"%@:%d->开启连接成功", device.host, device.port]];
}

- (void)device:(PWLocalDevice *)device didConnectFailedError:(NSError *)error {
    [self log:[NSString stringWithFormat:@"%@:%d->开启连接失败: %@", device.host, device.port, [error localizedDescription]]];
    [self removeLocalDevice:device];
}

- (void)deviceDidDisconnectSuccess:(PWLocalDevice *)device {
    [self log:[NSString stringWithFormat:@"%@:%d->断开连接成功", device.host, device.port]];
    [self removeLocalDevice:device];
}

//- (void)device:(PWLocalDevice *)device didDisconnectFailedMessage:(NSString *)message {
//    [self log:[NSString stringWithFormat:@"%@:%d->断开连接失败: %@", device.host, device.port, message]];
//    [self removeLocalDevice:device];
//}

- (void)device:(PWLocalDevice *)device remoteDidDisconnectError:(NSError *)error{
    [self log:[NSString stringWithFormat:@"%@:%d->远端断开连接: %@", device.host, device.port, [error localizedDescription]]];
    [self removeLocalDevice:device];
}


- (void)device:(PWLocalDevice *)device didReceiveCommand:(PWCommand *)command {
    if ([command.msgType isEqualToString:PWTextCommand.msgType]) {
        PWTextCommand *textCommand = (PWTextCommand *)command;
        [self log:[NSString stringWithFormat:@"%@:%d->%@", device.host, device.port, textCommand.text]];
    }else if ([command.msgType isEqualToString:PWUserLoginStatusCommand.msgType]) {
        PWUserLoginStatusCommand *userCommand = (PWUserLoginStatusCommand *)command;
        [self log:[NSString stringWithFormat:@"%@:%d->%@", device.host, device.port, userCommand.userToken]];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext {
    NSString *host;
    uint16_t port;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self log:[NSString stringWithFormat:@"%@:%d->%@", host, port, text]];
    });
}

@end

