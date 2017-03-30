//
//  PWAddDeviceViewController.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/3/29.
//
//

#import "PWAddDeviceViewController.h"
@import Masonry;

@interface PWAddDeviceViewController ()

@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UITextField *nameTextField;
@property (weak, nonatomic) UILabel *hostLabel;
@property (weak, nonatomic) UITextField *hostTextField;
@property (weak, nonatomic) UILabel *portLabel;
@property (weak, nonatomic) UITextField *portTextField;

@end

@implementation PWAddDeviceViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加设备";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"名称";
    
    UITextField *nameTextField = [UITextField new];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel *hostLabel = [UILabel new];
    hostLabel.text = @"IP";
    
    UITextField *hostTextField = [UITextField new];
    hostTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel *portLabel = [UILabel new];
    portLabel.text = @"端口";
    
    UITextField *portTextField = [UITextField new];
    portTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    [self.view addSubview:nameLabel];
    [self.view addSubview:nameTextField];
    [self.view addSubview:hostLabel];
    [self.view addSubview:hostTextField];
    [self.view addSubview:portLabel];
    [self.view addSubview:portTextField];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    [hostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameTextField.mas_bottom).with.offset(10);
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
    
    self.nameLabel = nameLabel;
    self.nameTextField = nameTextField;
    self.hostLabel = hostLabel;
    self.hostTextField = hostTextField;
    self.portLabel = portLabel;
    self.portTextField = portTextField;
}

#pragma mark - Action

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)save {
    if (self.nameTextField.text.length > 0 && self.hostTextField.text.length > 0 && self.portTextField.text.length > 0) {
        PWDevice *device = [[PWDevice alloc] initWithAbility:[PWAbility class] name:self.nameTextField.text host:self.hostTextField.text port:self.portTextField.text.intValue];
        [self.delegate addDeviceViewControllerDidSave:self withDevice:device];
    }
}

@end
