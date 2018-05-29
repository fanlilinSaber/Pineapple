//
//  PWNetViewController.m
//  Pineapple iOS Example
//
//  Created by 范李林 on 2018/4/16.
//

#import "PWNetViewController.h"
#import "PWAPIController.h"
#import "NSString+Additions.h"

@interface PWNetViewController ()

@end

@implementation PWNetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *stt = @"普忘研发ipadtablet24@b11.0.0b101524205848781F84E0E38DB45B2FA52C1B40A906C5";
    NSLog(@"utf8 = %@",[stt stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    NSLog(@"1---%@",[stt md5String]);
    

}

- (IBAction)login:(UIButton *)sender {
    NSString *password = @"like1234";
    NSDictionary *dict = @{@"credential" : @"ios",
                           @"password" : @"ebcb588140bdea86f30af2b79885c617",
                           @"randomNum" : @"MYIBAJAHSSYLBYVYCRNDZJDJSWNDWPPR",
                           @"captchaKey" : @"",
                           @"captchaVerifyCode" : @"",
                           @"clientName" : [UIDevice currentDevice].name,
                           @"isForceLogin" : @"0"
                           };
    NSLog(@"--%@",[password md5String]);
//    [PWAPIController sharedInstance].enabledMD5Sign = NO;
//    [[PWAPIController sharedInstance] requestJsonDataWithPath:@"api/user/login" withParams:dict withMethodType:Post andSuccess:^(NSString *message, id data) {
//        NSLog(@"data = %@",data);
//        NSString *toKen = data[@"x_access_token"];
//        [PWAPIController sharedInstance].toKen = toKen;
//    } andError:^(NSString *message, int code) {
//        NSLog(@"andError = %@",message);
//    } andFailure:^(NSError *error) {
//        NSLog(@"andFailure = %@",error);
//    }];
    
    [[PWAPIController sharedInstance] requestJsonDataWithPath:@"api/user/login" withParams:dict withMethodType:Post withEnabledSign:NO andSuccess:^(NSString *message, id data) {
        NSLog(@"data = %@",data);
        NSString *toKen = data[@"x_access_token"];
        [PWAPIController sharedInstance].toKen = toKen;
    } andError:^(NSString *message, int code) {
        NSLog(@"andError = %@",message);
    } andFailure:^(NSError *error) {
        NSLog(@"andFailure = %@",error);
    }];
    
}

- (IBAction)start:(UIButton *)sender {
    NSDictionary *dict = @{@"clientName" : @"普忘研发ipad",
                           @"softwareVersion" : @"24@b1",
                           @"systemVersion" : @"1.0.0b10",
                           @"clientType" : @"tablet"
                           };
    NSString *path = @"api/push/register";
//    NSDictionary *dict = @{@"applicationId" : @"184"};
    
//    NSString *path = @"api/scenes/findList";
    [PWAPIController sharedInstance].enabledMD5Sign = YES;
    [[PWAPIController sharedInstance] requestJsonDataWithPath:path withParams:dict withMethodType:Post andSuccess:^(NSString *message, id data) {
        NSLog(@"data = %@",data);
    } andError:^(NSString *message, int code) {
        NSLog(@"andError = %@",message);
    } andFailure:^(NSError *error) {
        NSLog(@"andFailure = %@",error);
    }];
    
}

- (IBAction)start1:(UIButton *)sender {
    NSDictionary *dict = @{@"confirmPassword" : [@"12345" md5String],
                           @"oldPassword" : @"ebcb588140bdea86f30af2b79885c617",
                           @"opType" : @"updatePwd",
                           @"password" : [@"12345" md5String],
                           @"userId" : @"177144089095237633"
                           };
    [PWAPIController sharedInstance].enabledMD5Sign = NO;
    [[PWAPIController sharedInstance] requestBodyJsonDataWithPath:@"api/user/password/update" withParams:dict withMethodType:Post andSuccess:^(NSString *message, id data) {
        NSLog(@"data = %@",data);
    } andError:^(NSString *message, int code) {
        NSLog(@"andError = %@",message);
    } andFailure:^(NSError *error) {
        NSLog(@"andFailure = %@",error);
    }];
}

@end
