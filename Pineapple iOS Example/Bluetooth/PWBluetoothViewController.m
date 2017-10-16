//
//  PWBluetoothViewController.m
//  Pineapple
//
//  Created by 范李林 on 2017/10/13.
//
//

#import "PWBluetoothViewController.h"
#import "Masonry.h"
#import "Pineapple.h"
#import "PWConnectViewController.h"
@interface PWBluetoothViewController ()<UITableViewDelegate, UITableViewDataSource, PWBluetoothClientDelegate>
/*&* <##>*/
@property (nonatomic, strong) PWBluetooth *bluetoothClient;
/*&* <##>*/
@property (nonatomic, strong) UITableView *tableView;
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation PWBluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _deviceArray = [NSMutableArray array];
    _bluetoothClient = [[PWBluetooth alloc] init];
    _bluetoothClient.delecgate = self;
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    UIBarButtonItem *start = [[UIBarButtonItem alloc] initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(start)];
    
    self.navigationItem.rightBarButtonItems = @[refresh, start];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)refresh{
    [self.bluetoothClient stopScan];
    [self.deviceArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)start{
    [self.bluetoothClient startScan];
}

#pragma mark - PWBluetoothClientDelegate
- (void)bluetoothCentralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (peripheral.name != nil) {
        NSArray *peripherals = [self.deviceArray valueForKey:@"peripheral"];
        if(![peripherals containsObject:peripheral]) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:peripheral forKey:@"peripheral"];
            [dict setValue:RSSI forKey:@"RSSI"];
            [dict setValue:advertisementData forKey:@"advertisementData"];
            [self.deviceArray addObject:dict];
            [self.tableView reloadData];
        }
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.deviceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *item = self.deviceArray[indexPath.row];
    CBPeripheral *peripheral = item[@"peripheral"];
    NSNumber *RSSI = item[@"RSSI"];
    NSString *peripheralName = peripheral.name;
    cell.textLabel.text = peripheralName;
    //信号和服务
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI:%@",RSSI];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.bluetoothClient stopScan];
    
    NSDictionary *item = self.deviceArray[indexPath.row];
    CBPeripheral *peripheral = item[@"peripheral"];
    PWConnectViewController *vc = [PWConnectViewController new];
    vc.bluetoothClient = self.bluetoothClient;
    vc.peripheral = peripheral;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - get
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    return _tableView;
}

@end
