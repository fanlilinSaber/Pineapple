//
//  PWDeviceViewController.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWDeviceViewController.h"
@import Masonry;

@interface PWDeviceViewController () <PWDeviceDelegate>

@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) PWDevice *device;

@end

@implementation PWDeviceViewController

- (instancetype)initWithDevice:(PWDevice *)device index:(NSInteger)index {
    self = [super init];
    if (self) {
        _index = index;
        _device = device;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.device.name;
    
    UITextView *textView = [UITextView new];
    textView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    textView.editable = false;
    textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    UITextField *textField = [UITextField new];
    textField.borderStyle = UITextBorderStyleRoundedRect;

    UIButton *sendButton = [UIButton new];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:textView];
    [self.view addSubview:textField];
    [self.view addSubview:sendButton];

    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(10);
    }];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(textField.mas_trailing).with.offset(10);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-10);
        make.centerY.equalTo(textField.mas_centerY);
    }];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textField.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading);
        make.trailing.equalTo(self.view.mas_trailing);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    self.textView = textView;
    self.textField = textField;
    self.sendButton = sendButton;
    
    self.device.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.device connect];
    [self reloadStatus];
}

- (void)reloadStatus {
    NSString *status = [self.device isConnected] ? @"开启" : @"断开";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:status style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - Actions

- (void)send {
    if (self.textField.text.length > 0) {
        PWTextCommand *command = [[PWTextCommand alloc] initWithText:self.textField.text];
        [self.device send:command];
        self.textField.text = nil;
        [self meSay:command.text];
    }
}

- (void)meSay:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@我->%@\n", self.textView.text, text];
}

- (void)otherSay:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@%@:%d->%@\n", self.textView.text, self.device.host, self.device.port, text];
}

#pragma mark - PWDeviceDelegate

- (void)deviceDidConnectSuccess:(PWDevice *)device {
    [self reloadStatus];
    [self.delegate deviceViewControllerDidChangeStatus:self];
}

- (void)deviceDidConnectFailed:(PWDevice *)device {
    [self reloadStatus];
    [self.delegate deviceViewControllerDidChangeStatus:self];
}

- (void)deviceDidDisconnectSuccess:(PWDevice *)device {
    [self reloadStatus];
    [self.delegate deviceViewControllerDidChangeStatus:self];
}

- (void)deviceDidDisconnectFailed:(PWDevice *)device {
    [self reloadStatus];
    [self.delegate deviceViewControllerDidChangeStatus:self];
}

- (void)device:(PWDevice *)device didReceiveCommand:(PWCommand *)command {
    if ([command isMemberOfClass:[PWVideoCommand class]]) {
        PWVideoCommand *videoCommand = (PWVideoCommand *)command;
        [self otherSay:videoCommand.video];
    }
}

@end
