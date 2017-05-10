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
#import "PWDeviceCell.h"
#import "Pineapple.h"
#import <Masonry/Masonry.h>

static NSString * const PWDeviceCellIdentifier = @"DeviceCell";

@interface PWHomeViewController () <UITableViewDelegate, UITableViewDataSource, PWAddLocalDeviceViewControllerDelegate, PWAddRemoteDeviceViewControllerDelegate, PWProxyDelegate, PWListenerDelegate, PWLocalDeviceDelegate>

@property (strong, nonatomic) PWAbility *ability;
@property (strong, nonatomic) PWProxy *proxy;
@property (strong, nonatomic) PWListener *listener;
@property (copy, nonatomic) NSArray *devices;
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextView *textView;

@end

@implementation PWHomeViewController

- (void)loadView {
    [super loadView];
    
    self.title = @"设备列表";
    
    self.ability = [PWAbility new];
    
    self.proxy = [[PWProxy alloc] initWithAbility:self.ability host:@"mqf-er9w0k6ntu.mqtt.aliyuncs.com" port:1883 user:@"aEACwHFvAqv1A3eK" pass:@"LC4uWeVKgBiG9QigL3cP+estMYQ=" clientId:@"GID_equipment001@@@Banana" rootTopic:@"topic_equipment001"];
    
    self.proxy.delegate = self;
    
    self.listener = [[PWListener alloc] initWithAbility:self.ability port:5000];
    self.listener.delegate = self;
    
    self.devices = @[];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"MQTT" style:UIBarButtonItemStylePlain target:self action:@selector(addMQTT)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Socket" style:UIBarButtonItemStylePlain target:self action:@selector(addSocket)];
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.proxy connect];
    [self.listener start];
}

#pragma mark - Action

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

- (void)send {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    NSString *text = self.textField.text;
    if (indexPath && ![text isEqualToString:@""]) {
        PWTextCommand *comand = [[PWTextCommand alloc] initWithText:text];
        PWDevice *device = self.devices[indexPath.row];
        if ([device isKindOfClass:[PWLocalDevice class]]) {
            PWLocalDevice *localDevice = (PWLocalDevice *)device;
            [localDevice send:comand];
        } else {
            PWRemoteDevice *remoteDevice = (PWRemoteDevice *)device;
            [self.proxy send:comand toDevice:remoteDevice];
        }
        self.textField.text = nil;
    }
}

#pragma mark - Private

- (void)addLocalDevice:(PWLocalDevice *)device {
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

- (void)device:(PWLocalDevice *)device didConnectFailedMessage:(NSString *)message {
    [self log:[NSString stringWithFormat:@"%@:%d->开启连接失败: %@", device.host, device.port, message]];
    [self removeLocalDevice:device];
}

- (void)deviceDidDisconnectSuccess:(PWLocalDevice *)device {
    [self log:[NSString stringWithFormat:@"%@:%d->断开连接成功", device.host, device.port]];
    [self removeLocalDevice:device];
}

- (void)device:(PWLocalDevice *)device didDisconnectFailedMessage:(NSString *)message {
    [self log:[NSString stringWithFormat:@"%@:%d->断开连接失败: %@", device.host, device.port, message]];
    [self removeLocalDevice:device];
}

- (void)device:(PWLocalDevice *)device didReceiveCommand:(PWCommand *)command {
    if ([command.msgType isEqualToString:PWTextCommand.msgType]) {
        PWTextCommand *textCommand = (PWTextCommand *)command;
        [self log:[NSString stringWithFormat:@"%@:%d->%@", device.host, device.port, textCommand.text]];
    }
}

@end

