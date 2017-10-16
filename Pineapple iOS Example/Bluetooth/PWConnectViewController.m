//
//  PWConnectViewController.m
//  Pineapple
//
//  Created by 范李林 on 2017/10/16.
//
//

#import "PWConnectViewController.h"


static NSString * const uartServiceUUIDString = @"0000fff0-0000-1000-8000-00805F9B34FB";
static NSString * const uartTXCharacteristicUUIDString = @"0000fff1-0000-1000-8000-00805F9B34FB";
static NSString * const uartRXCharacteristicUUIDString = @"0000fff2-0000-1000-8000-00805F9B34FB";

@interface PWConnectViewController ()<PWBluetoothClientDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UITextField *input_tf;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextView *show_tv;

/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *dataSource;
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *serviceArray;
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *characteristicArray;
/*&* nsmud*/
@property (nonatomic, strong) NSMutableDictionary *dataDict;

@property (nonatomic, strong) CBUUID *UART_Service_UUID;
@property (nonatomic, strong) CBUUID *UART_RX_Characteristic_UUID;
@property (nonatomic, strong) CBUUID *UART_TX_Characteristic_UUID;

@property (strong, nonatomic)CBCharacteristic *uartRXCharacteristic;
@property (strong, nonatomic)CBCharacteristic *uartTXCharacteristic;

@end

@implementation PWConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备连接中...";
    
    UIBarButtonItem *getInfo = [[UIBarButtonItem alloc] initWithTitle:@"获取" style:UIBarButtonItemStylePlain target:self action:@selector(getInfo)];
    UIBarButtonItem *send = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
    UIBarButtonItem *timer = [[UIBarButtonItem alloc] initWithTitle:@"自动" style:UIBarButtonItemStylePlain target:self action:@selector(timer)];
    
    self.navigationItem.rightBarButtonItems = @[getInfo, send, timer];
    _dataSource = [NSMutableArray array];
    _serviceArray = [NSMutableArray array];
    _characteristicArray = [NSMutableArray array];
    _dataDict = [NSMutableDictionary dictionary];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.sectionHeaderHeight = 44;
    _show_tv.editable = NO;
    self.UART_Service_UUID = [CBUUID UUIDWithString:uartServiceUUIDString];
    self.UART_TX_Characteristic_UUID = [CBUUID UUIDWithString:uartTXCharacteristicUUIDString];
    self.UART_RX_Characteristic_UUID = [CBUUID UUIDWithString:uartRXCharacteristicUUIDString];
    self.bluetoothClient.delecgate = self;
    [self startConnect];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.bluetoothClient cancelPeripheralConnection:self.peripheral];
    self.bluetoothClient.delecgate = nil;
    _show_tv = nil;
}

#pragma mark -
- (void)startConnect{
    self.bluetoothClient.services_uuid = @[[CBUUID UUIDWithString:@"0000180D-0000-1000-8000-00805F9B34FB"]];
    self.bluetoothClient.subscibe_uuid = @[[CBUUID UUIDWithString:@"00002A37-0000-1000-8000-00805F9B34FB"]];
    [self.bluetoothClient connectPeripheral:self.peripheral];
}

- (void)getInfo{
    [self getHeartRate];
}

- (void)send{
    
}

- (void)timer{
    [self starTimer];
}

#pragma mark - FLBluetoothClientDelegate
- (void)bluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.title = [NSString stringWithFormat:@"连接成功 %@",peripheral.name];
    self.show_tv.text = [NSString stringWithFormat:@"发现设备：%@\n名称：%@\n",peripheral.identifier.UUIDString,peripheral.name];
}

-(void)bluetoothCentralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.title = @"连接失败";
}

- (void)bluetoothCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.title = @"断开连接";
}

-(void)bluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error){
        NSLog(@"扫描外设服务出错：%@ -> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
//    for (CBService *service in peripheral.services) {
//        [self.serviceArray addObject:service];
//        [peripheral discoverCharacteristics:nil forService:service];
//    }
//    [self.dataDict setObject:self.serviceArray forKey:@"CBService"];
//    [self.tableView reloadData];
//    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
}

//- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
//    if (error){
//        NSLog(@"扫描外设的特征失败！\n%@ -> %@-> %@",peripheral.name,service.UUID, [error localizedDescription]);
//        return;
//    }
//    NSLog(@"扫描到外设服务特征有：%@ -> %@ -> %@",peripheral.name,service.UUID,service.characteristics);
//    //获取Characteristic的值
//    if ([service.UUID isEqual:self.UART_Service_UUID]) {
//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//            [self.characteristicArray addObject:characteristic];
//            if ([characteristic.UUID isEqual:self.UART_TX_Characteristic_UUID]) {
//                NSLog(@"UART TX characteritsic is found");
//                self.uartTXCharacteristic = characteristic;
//                //使能notify
//                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                
//                //[self performSelector:@selector(syncTime) withObject:nil afterDelay:0.1f];
//            }
//            else if ([characteristic.UUID isEqual:self.UART_RX_Characteristic_UUID]) {
//                NSLog(@"UART RX characteristic is found");
//                if (characteristic.isNotifying) {
//                    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                }
//                self.uartRXCharacteristic = characteristic;
//                [self getPower];
//                [self getHeartRate];
//                
//            }
//        }
//    }
//    /*&* 实时获取心率值*/
//    else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"0000180D-0000-1000-8000-00805F9B34FB"]]){
//        NSLog(@"心率服务");
//        for (CBCharacteristic *characteristic in service.characteristics)
//        {
//            NSLog(@"is Notify %d",characteristic.isNotifying);
//            [self.characteristicArray addObject:characteristic];
//            NSLog(@"心率服务 UUID = %@",characteristic.UUID);
//            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"00002A37-0000-1000-8000-00805F9B34FB"]]) {
//                //使能notify
//                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//                NSLog(@"111");
//            }
//            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"00002A38-0000-1000-8000-00805F9B34FB"]]) {
//                NSLog(@"222");
//                
//            }
//
//        }
//        
//    }
//    [self.dataDict setObject:self.characteristicArray forKey:@"CBCharacteristic"];
//    [self.tableView reloadData];
//}

- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"扫描外设的具体值失败！%@ -> %@",peripheral.name, [error localizedDescription]);
        return;
    }
    if (characteristic.value.length != 0) {
        Byte *notifydata = (Byte *)[characteristic.value bytes];
        
        NSLog(@"characteristic.value = %@",characteristic.value);
        
        /*&* 如果订阅了 实时心率 取到值就是心率值*/
        int hr = *(notifydata+1);
        
        NSLog(@"----%d",hr);
        self.show_tv.text = [self.show_tv.text stringByAppendingFormat:@"\n具体值UUID：%@\n心率：%d",characteristic.UUID.UUIDString,hr];
        
        if(*notifydata == 0x68)
        {
            Byte ctrl = *(notifydata+1) & 0x7f;
            switch (ctrl) {
                case 0x03:
                {
                    int power = *(notifydata+4);
                    NSLog(@"电量 %d", power);
                    self.show_tv.text = [self.show_tv.text stringByAppendingFormat:@"\n具体值UUID：%@\n电量：%d",characteristic.UUID.UUIDString,power];
                    
                    break;
                }
                case 0x06:{
                    Byte type = *(notifydata+5);
                    if (type == 0x46) {
                        
                        NSLog(@"111111");
                    }
                    int power = *(notifydata+5);
                    NSLog(@"心率 %d", power);
                    self.show_tv.text = [self.show_tv.text stringByAppendingFormat:@"\n具体值UUID：%@\n心率：%d",characteristic.UUID.UUIDString,power];
                }
                default:
                {
                    break;
                }
            }
        }
        [self.show_tv scrollRangeToVisible:NSMakeRange(self.show_tv.text.length, 1)];
    }
    
}

- (void)bluetoothPeripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"didUpdateNotificationStateForCharacteristic接收数据发生错误,%@", error);
        return;
    }
    if (characteristic.isNotifying) {
        [peripheral readValueForCharacteristic:characteristic];
    }
    NSString *string=[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"didUpdateNotificationStateForCharacteristic收到的数据为:%@", string);
}

- (void)getPower{
    Byte transData[6] = {0x68, 0x03, 0x00, 0x00, 0x00, 0x16};
    
    transData[4] = [self calCS:transData withLen:4];
    NSData *lData = [NSData dataWithBytes:transData length:sizeof(transData)];
    [self.peripheral writeValue:lData forCharacteristic:self.uartRXCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)getHeartRate{
    if (self.uartRXCharacteristic == nil) {
        return;
    }
    Byte transData[7] = {0x68, 0x06, 0x01, 0x00, 0x00, 0x6f, 0x16};
    NSData *lData = [NSData dataWithBytes:transData length:sizeof(transData)];
    [self.peripheral writeValue:lData forCharacteristic:self.uartRXCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(Byte)calCS:(Byte *)data withLen:(int)len{
    UInt32 i, cs = 0;
    
    for(i = 0; i < len; i++)
    {
        cs += data[i];
    }
    return (Byte)cs;
}


#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.dataDict allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.dataDict allValues][section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    id obj = [self.dataDict allValues][indexPath.section][indexPath.row];
    if ([obj isKindOfClass:[CBService  class]]) {
        CBService *service = (CBService *)obj;
        cell.textLabel.text = [NSString stringWithFormat:@"UUID = %@",service.UUID.UUIDString];
        cell.detailTextLabel.text = @"";
        
    }
    else if ([obj isKindOfClass:[CBCharacteristic class]]){
        CBCharacteristic *characteristic = (CBCharacteristic *)obj;
        cell.textLabel.text = [NSString stringWithFormat:@"UUID = %@",characteristic.UUID.UUIDString];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"CBServiceUUID = %@",characteristic.service.UUID.UUIDString];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }
    NSString *key = [self.dataDict allKeys][section];
    headerView.textLabel.text = key;
    return headerView;
}

- (void)respondsToTimer:(NSTimer *)timer{
    [self getHeartRate];
}


#pragma mark -定时器
- (void)starTimer{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(respondsToTimer:) userInfo:nil repeats:YES];
    }
    _timer.fireDate = [NSDate date];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)pauseTimer{
    if (_timer&&_timer.isValid) {
        _timer.fireDate = [NSDate distantFuture];
    }
}

- (void)stopTimer{
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

@end
