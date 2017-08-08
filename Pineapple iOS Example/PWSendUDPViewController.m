//
//  PWSendUDPViewController.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/8/8.
//
//

#import "PWSendUDPViewController.h"
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <Masonry/Masonry.h>

@interface PWSendUDPViewController () <GCDAsyncUdpSocketDelegate>

@property (weak, nonatomic) UILabel *textLabel;
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UILabel *hostLabel;
@property (weak, nonatomic) UITextField *hostTextField;
@property (weak, nonatomic) UILabel *portLabel;
@property (weak, nonatomic) UITextField *portTextField;
@property (weak, nonatomic) UITextView *textView;
@property (strong, nonatomic) GCDAsyncUdpSocket *socket;

@end

@implementation PWSendUDPViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发送 UDP";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];

    UILabel *textLabel = [UILabel new];
    textLabel.text = @"文本";
    
    UITextField *textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel *hostLabel = [UILabel new];
    hostLabel.text = @"IP";
    
    UITextField *hostTextField = [UITextField new];
    hostTextField.borderStyle = UITextBorderStyleRoundedRect;
    hostTextField.text = @"192.168.100.";
    
    UILabel *portLabel = [UILabel new];
    portLabel.text = @"端口";
    
    UITextField *portTextField = [UITextField new];
    portTextField.borderStyle = UITextBorderStyleRoundedRect;
    portTextField.text = @"50016";
    
    [self.view addSubview:textLabel];
    [self.view addSubview:textField];
    [self.view addSubview:hostLabel];
    [self.view addSubview:hostTextField];
    [self.view addSubview:portLabel];
    [self.view addSubview:portTextField];

    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    [hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [hostTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hostLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    [portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hostTextField.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(portLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    
    self.textLabel = textLabel;
    self.textField = textField;
    self.hostLabel = hostLabel;
    self.hostTextField = hostTextField;
    self.portLabel = portLabel;
    self.portTextField = portTextField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error = nil;
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [self.socket bindToPort:50017 error:&error];
    [self.socket enableBroadcast:YES error:&error];
}

#pragma mark - Action

- (void)cancel {
    [self.socket close];
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)send {
    NSString *text = self.textField.text;
    NSString *host = self.hostTextField.text;
    NSString *port = self.portTextField.text;
    if (![text isEqualToString:@""] && ![host isEqualToString:@""] && ![port isEqualToString:@""]) {
        [self.socket sendData:[text dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:port.intValue withTimeout:-1 tag:0];
        self.textField.text = nil;
    }
}

@end
