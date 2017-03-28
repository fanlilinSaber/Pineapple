//
//  ViewController.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "ViewController.h"
#import "Pineapple.h"

@interface ViewController () <PWDeviceDelegate>

@property (strong, nonatomic) PWDevice *device;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    self.device = [[PWDevice alloc] initWithAbility:[PWAbility new] name:@"Ruby" host:@"127.0.0.1" port:5000];
    self.device.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.device connect];
    [self.device send:[[PWCommand alloc] initWithText:@"Go Go Go"]];
}

// TODO: Add Manual Input Device
// TODO: List All Connected Devices
// TODO: Add Bonjour Found Device
// TODO: Send Command, Receive Command

#pragma mark - PWDeviceDelegate

- (void)deviceDidConnectSuccess:(PWDevice *)device {
}

- (void)deviceDidConnectFailed:(PWDevice *)device {
    
}

- (void)device:(PWDevice *)device didSendCommand:(PWCommand *)command {
    
}

- (void)device:(PWDevice *)device didReceiveCommand:(PWCommand *)command {
    NSLog(@"%@", command.text);
}


@end
