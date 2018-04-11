//
//  PWAddRMQViewController.m
//  Pineapple iOS Example
//
//  Created by 范李林 on 2018/3/8.
//

#import "PWAddRMQViewController.h"
#import <Masonry/Masonry.h>

@interface PWAddRMQViewController ()
/*&* <##>*/
@property (nonatomic, strong) UILabel *name_lb;
/*&* <##>*/
@property (nonatomic, strong) UITextField *linkAddress_tfd;

@property (strong, nonatomic) PWAbility *ability;

@end

@implementation PWAddRMQViewController

- (instancetype)initWithAbility:(PWAbility *)ability {
    self = [super init];
    if (self) {
        _ability = ability;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"添加 RMQ 服务端";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"服务端URL";
    
    UITextField *nameTextField = [UITextField new];
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
//    nameTextField.text = @"amqp://test:test@139.196.111.86:5672";
    nameTextField.text = @"amqp://test:test@192.168.0.159:5672";
    
    [self.view addSubview:nameLabel];
    [self.view addSubview:nameTextField];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
    }];
    [nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).with.offset(10);
        make.leading.equalTo(self.view.mas_leading).with.offset(16);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-16);
    }];
    
    self.name_lb = nameLabel;
    self.linkAddress_tfd = nameTextField;
}


#pragma mark - Action

- (void)cancel {
    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

- (void)save {
    if (self.linkAddress_tfd.text.length > 0) {
        PWMQDevice *device = [[PWMQDevice alloc] initWithAbility:self.ability name:@"ios" uri:self.linkAddress_tfd.text];
        [self.delegate addMQDeviceViewControllerDidSave:self withDevice:device];
    }
}


@end
