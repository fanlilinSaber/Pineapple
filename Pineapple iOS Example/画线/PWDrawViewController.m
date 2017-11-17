//
//  PWDrawViewController.m
//  Pineapple iOS Example
//
//  Created by 范李林 on 2017/11/3.
//

#import "PWDrawViewController.h"
#import "PWDrawView.h"
@interface PWDrawViewController ()

@end

@implementation PWDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    PWDrawView *draw = [[PWDrawView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:draw];
    
    
}



@end
