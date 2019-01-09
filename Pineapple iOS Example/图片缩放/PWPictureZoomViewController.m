//
//  PWPictureZoomViewController.m
//  Pineapple iOS Example
//
//  Created by Fan Li Lin on 2019/1/3.
//

#import "PWPictureZoomViewController.h"
#import "PWZoomImageView.h"
#import "Masonry.h"

@interface PWPictureZoomViewController ()<UINavigationControllerDelegate>
/*&* <##>*/
@property (nonatomic, strong) PWZoomImageView *zoomImageView;

@end

@implementation PWPictureZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
//    // 设置导航控制器的代理为self
//    self.navigationController.delegate = self;
    
    //设置导航栏透明
    [self.navigationController.navigationBar setTranslucent:true];
    //把背景设为空
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //处理导航栏有条线的问题
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];

//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self.view addSubview:self.zoomImageView];
    
    [self.zoomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

//#pragma mark - UINavigationControllerDelegate
//// 将要显示控制器
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    // 判断要显示的控制器是否是自己
//    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
//
//    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
//}
//
//- (void)dealloc {
//    self.navigationController.delegate = nil;
//}


#pragma mark - getters and setters

- (PWZoomImageView *)zoomImageView
{
    if (_zoomImageView == nil) {
        _zoomImageView = [[PWZoomImageView alloc] initWithImage:[UIImage imageNamed:@"2334.jpg"] boundsSize:self.view.bounds.size];
    }
    return _zoomImageView;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
