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

@interface PWHomeViewController () <UITableViewDelegate, UITableViewDataSource, PWAddDeviceViewControllerDelegate, PWListenerDelegate>

@property (strong, nonatomic) PWListener *listener;
@property (copy, nonatomic) NSArray *devices;
@property (weak, nonatomic) UITableView *tableView;

@end

@implementation PWHomeViewController

- (void)loadView {
    [super loadView];
    
    self.listener = [PWListener new];
    self.listener.delegate = self;
    
    self.devices = @[];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发现" style:UIBarButtonItemStylePlain target:self action:@selector(bonjour)];
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.listener start];
}

#pragma mark - Action

- (void)bonjour {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[PWBonjourViewController new]];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)add {
    PWAddDeviceViewController *addDeviceViewController = [PWAddDeviceViewController new];
    addDeviceViewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addDeviceViewController];
    [self presentViewController:navigationController animated:true completion:nil];
}

#pragma mark - Helper

- (void)addDevice:(PWDevice *)device {
    NSMutableArray *devices = [self.devices mutableCopy];
    [devices addObject:device];
    self.devices = devices;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PWDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:PWDeviceCellIdentifier];
    PWDevice *device = self.devices[indexPath.row];
    cell.nameLabel.text = device.name;
    cell.addressLabel.text = [[NSString alloc] initWithFormat:@"%@:%d", device.host, device.port];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PWDevice *device = self.devices[indexPath.row];
    [self showViewController:[[PWDeviceViewController alloc] initWithDevice:device] sender:nil];
}

#pragma mark - PWAddDeviceViewControllerDelegate

- (void)addDeviceViewControllerDidSave:(PWAddDeviceViewController *)addDeviceViewController withDevice:(PWDevice *)device {
    [self dismissViewControllerAnimated:true completion:^{
        [self addDevice:device];
    }];
}

#pragma mark - PWListenerDelegate

- (void)listenerDidStartSuccess:(PWListener *)listener {
    self.title = @"监听成功";
}

- (void)listenerDidStartFailed:(PWListener *)listener {
    self.title = @"监听失败";
}

- (void)listener:(PWListener *)listener didConnectDevice:(PWDevice *)device {
    [self addDevice:device];
}

@end
