//
//  ViewController.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "ViewController.h"
#import "Pineapple.h"

@interface ViewController ()

@property (nonatomic, strong) PWDevice *device;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    self.device = [[PWDevice alloc] initWithAbility:[PWAbility new] host:@"127.0.0.2" port:2000];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.device connect];
}

@end
