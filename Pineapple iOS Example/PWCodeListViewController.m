//
//  PWCodeListViewController.m
//  Pineapple
//
//  Created by 范李林 on 2017/10/13.
//
//

#import "PWCodeListViewController.h"
#import "Masonry.h"
#import "PWHomeViewController.h"
#import "PWBluetoothViewController.h"
#import "PWDrawViewController.h"
@interface PWCodeListViewController () <UITableViewDelegate, UITableViewDataSource>
/*&* <##>*/
@property (nonatomic, strong) UITableView *tableView;
/*&* <##>*/
@property (nonatomic, strong) NSArray *dataArray;


@end

@implementation PWCodeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataArray = @[@{@"name" : @"TCP - UDP - MQTT", @"className" : @"PWHomeViewController"},
                       @{@"name" : @"蓝牙客户端", @"className" : @"PWBluetoothViewController"},
                       @{@"name" : @"画线", @"className" : @"PWDrawViewController"}];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


#pragma mark - delegate

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.dataArray[indexPath.row][@"name"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *className = self.dataArray[indexPath.row][@"className"];
    Class class = NSClassFromString(className);
    UIViewController *vc = [[class alloc] init];
    
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
