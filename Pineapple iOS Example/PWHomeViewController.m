//
//  PWHomeViewController.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "PWHomeViewController.h"
#import "PWBonjourViewController.h"
#import "PWAddDeviceViewController.h"
#import "PWDeviceViewController.h"
#import "PWDeviceCell.h"
#import "Pineapple.h"
@import Masonry;

static NSString * const PWDeviceCellIdentifier = @"DeviceCell";

@interface PWHomeViewController () <PWDeviceDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) PWDevice *device;

@end

@implementation PWHomeViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备列表";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Bonjour" style:UIBarButtonItemStylePlain target:self action:@selector(bonjour)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    
    UITableView *tableView = [UITableView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 40;
    [tableView registerClass:[PWDeviceCell class] forCellReuseIdentifier:PWDeviceCellIdentifier];
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.tableView = tableView;
    
    self.device = [[PWDevice alloc] initWithAbility:[PWAbility class] name:@"Ruby" host:@"127.0.0.1" port:5000];
    self.device.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.device connect];
    PWTextCommand *command = [[PWTextCommand alloc] initWithText:@"Go Go Go"];
    [self.device send:command];
}

#pragma mark - Action

- (void)bonjour {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[PWBonjourViewController new]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)add {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[PWAddDeviceViewController new]];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PWDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:PWDeviceCellIdentifier];
    cell.nameLabel.text = @"PC";
    cell.addressLabel.text = [[NSString alloc] initWithFormat:@"%@:%d", @"192.168.0.1", 2000];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    [self showViewController:[PWDeviceViewController new] sender:nil];
}

#pragma mark - PWDeviceDelegate

- (void)deviceDidConnectSuccess:(PWDevice *)device {
}

- (void)deviceDidConnectFailed:(PWDevice *)device {
    
}

- (void)device:(PWDevice *)device didSendCommand:(PWCommand *)command {

}

- (void)device:(PWDevice *)device didReceiveCommand:(PWCommand *)command {
    NSLog(@"%@", command);
}


@end
