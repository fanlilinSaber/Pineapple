//
//  PWHomeViewController.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWHomeViewController.h"
#import "PWAddDeviceViewController.h"
#import "PWAddClientViewController.h"
#import "PWDeviceCell.h"
#import "Pineapple.h"
@import Masonry;

static NSString * const PWDeviceCellIdentifier = @"DeviceCell";

@interface PWHomeViewController () <UITableViewDelegate, UITableViewDataSource, PWAddDeviceViewControllerDelegate, PWAddClientViewControllerDelegate, PWProxyDelegate, PWListenerDelegate, PWDeviceDelegate>

@property (strong, nonatomic) PWProxy *proxy;
@property (strong, nonatomic) PWListener *listener;
@property (copy, nonatomic) NSArray *devicesAndClients;
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UITextView *textView;

@end

@implementation PWHomeViewController

- (void)loadView {
    [super loadView];
    
    self.title = @"设备列表";
    
    self.proxy = [[PWProxy alloc] initWithHost:@"mqf-er9w0k6ntu.mqtt.aliyuncs.com" port:1883 user:@"aEACwHFvAqv1A3eK" pass:@"LC4uWeVKgBiG9QigL3cP+estMYQ=" groupId:@"GID_equipment001" deviceId:@"Apple" rootTopic:@"topic_equipment001"];
    self.proxy.delegate = self;
    
    self.listener = [[PWListener alloc] initWithPort:5000];
    self.listener.delegate = self;
    
    self.devicesAndClients = @[];
    
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
    PWAddClientViewController *addClientViewController = [[PWAddClientViewController alloc] init];
    addClientViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addClientViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)addSocket {
    PWAddDeviceViewController *addDeviceViewController = [PWAddDeviceViewController new];
    addDeviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addDeviceViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)send {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    NSString *text = self.textField.text;
    if (indexPath && ![text isEqualToString:@""]) {
        PWTextCommand *comand = [[PWTextCommand alloc] initWithText:text];
        NSObject *deviceOrClient = self.devicesAndClients[indexPath.row];
        if ([deviceOrClient isKindOfClass:[PWDevice class]]) {
            PWDevice *device = (PWDevice *)deviceOrClient;
            comand.clientId = [[NSString alloc] initWithFormat:@"%@:%d", device.host, device.port];
            [device send:comand];
        } else {
            PWClient *client = (PWClient *)deviceOrClient;
            [self.proxy send:comand toClient:client];
        }
        self.textField.text = nil;
    }
}

#pragma mark - Private

- (void)addDevice:(PWDevice *)device {
    device.delegate = self;
    [device connect];
    NSMutableArray *devicesAndClients = [self.devicesAndClients mutableCopy];
    [devicesAndClients addObject:device];
    self.devicesAndClients = devicesAndClients;
    [self.tableView reloadData];
}

- (void)addClient:(PWClient *)client {
    BOOL existed = NO;
    for (NSObject *deviceOrClient in self.devicesAndClients) {
        if ([deviceOrClient isKindOfClass:[PWClient class]]) {
            PWClient *eachClient = (PWClient *)deviceOrClient;
            if ([eachClient.clientId isEqualToString:client.clientId]) {
                existed = YES;
                break;
            }
        }
    }
    if (!existed) {
        NSMutableArray *devicesAndClients = [self.devicesAndClients mutableCopy];
        [devicesAndClients addObject:client];
        self.devicesAndClients = devicesAndClients;
        [self.tableView reloadData];
    }
}

- (void)log:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@%@\n", self.textView.text, text];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicesAndClients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PWDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:PWDeviceCellIdentifier];
    NSObject *deviceOrClient = self.devicesAndClients[indexPath.row];
    if ([deviceOrClient isKindOfClass:[PWDevice class]]) {
        PWDevice *device = (PWDevice *)deviceOrClient;
        cell.nameLabel.text = device.name;
        cell.addressLabel.text = [[NSString alloc] initWithFormat:@"%@:%d", device.host, device.port];
    } else {
        PWClient *client = (PWClient *)deviceOrClient;
        cell.nameLabel.text = client.name;
        cell.addressLabel.text = client.clientId;
    }
    return cell;
}

#pragma mark - PWAddDeviceViewControllerDelegate

- (void)addDeviceViewControllerDidSave:(PWAddDeviceViewController *)addDeviceViewController withDevice:(PWDevice *)device {
    [self dismissViewControllerAnimated:true completion:^{
        [self addDevice:device];
    }];
}

#pragma mark - PWAddClientViewControllerDelegate

- (void)addClientViewControllerDidSave:(PWAddClientViewController *)addClientViewController withClient:(PWClient *)client {
    [self dismissViewControllerAnimated:true completion:^{
        [self addClient:client];
    }];
}

#pragma mark - PWListenerDelegate

- (void)listenerDidStartSuccess:(PWListener *)listener {
    [self log:@"Socket 监听成功"];
}

- (void)listenerDidStartFailed:(PWListener *)listener {
    [self log:@"Socket 监听失败"];
}

- (void)listener:(PWListener *)listener didConnectDevice:(PWDevice *)device {
    [self addDevice:device];
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
    if ([command isMemberOfClass:[PWVideoCommand class]]) {
        PWVideoCommand *videoCommand = (PWVideoCommand *)command;
        [self log:[NSString stringWithFormat:@"%@->%@", videoCommand.clientId, videoCommand.video]];
        PWClient *client = [[PWClient alloc] initWithName:@"未知" clientId:videoCommand.clientId];
        [self addClient:client];
    }
}

#pragma mark - PWDeviceDelegate

- (void)deviceDidConnectSuccess:(PWDevice *)device {
    [self log:[NSString stringWithFormat:@"%@:%d->开启连接成功", device.host, device.port]];
}

- (void)device:(PWDevice *)device didConnectFailedMessage:(NSString *)message {
    [self log:[NSString stringWithFormat:@"%@:%d->开启连接失败: %@", device.host, device.port, message]];
}

- (void)deviceDidDisconnectSuccess:(PWDevice *)device {
    [self log:[NSString stringWithFormat:@"%@:%d->断开连接成功", device.host, device.port]];
}

- (void)device:(PWDevice *)device didDisconnectFailedMessage:(NSString *)message {
    [self log:[NSString stringWithFormat:@"%@:%d->断开连接失败: %@", device.host, device.port, message]];
}

- (void)device:(PWDevice *)device didReceiveCommand:(PWCommand *)command {
    if ([command isMemberOfClass:[PWVideoCommand class]]) {
        PWVideoCommand *videoCommand = (PWVideoCommand *)command;
        [self log:[NSString stringWithFormat:@"%@:%d->%@", device.host, device.port, videoCommand.video]];
    }
}

@end

