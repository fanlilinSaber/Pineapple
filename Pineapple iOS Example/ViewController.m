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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PWDevice *device = [PWDevice new];
    [device send];
}

@end
