//
//  PWAddClientViewController.m
//  Pineapple
//
//  Created by Dan Jiang on 2017/4/18.
//
//

#import "PWAddClientViewController.h"
@import Masonry;

@interface PWAddClientViewController ()

@property (weak, nonatomic) UILabel *nameLabel;
@property (weak, nonatomic) UITextField *nameTextField;
@property (weak, nonatomic) UILabel *clientLabel;
@property (weak, nonatomic) UITextField *clientTextField;

@end

@implementation PWAddClientViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加 MQTT 设备";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"名称";
    
    UITextField *nameTextField = [UITextField new];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    
    UILabel *clientLabel = [UILabel new];
    clientLabel.text = @"Client ID";
    
    UITextField *clientTextField = [UITextField new];
    clientTextField.borderStyle = UITextBorderStyleRoundedRect;
    clientTextField.text = @"GID_equipment001@@@";
    
    [self.view addSubview:nameLabel];
    [self.view addSubview:nameTextField];
    [self.view addSubview:clientLabel];
    [self.view addSubview:clientTextField];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    [clientLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameTextField.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [clientTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(clientLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    
    self.nameLabel = nameLabel;
    self.nameTextField = nameTextField;
    self.clientLabel = clientLabel;
    self.clientTextField = clientTextField;
}

#pragma mark - Action

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)save {
    if (self.nameTextField.text.length > 0 && self.clientTextField.text.length > 0) {
        PWClient *client = [[PWClient alloc] initWithName:self.nameTextField.text clientId:self.clientTextField.text];
        [self.delegate addClientViewControllerDidSave:self withClient:client];
    }
}

@end
