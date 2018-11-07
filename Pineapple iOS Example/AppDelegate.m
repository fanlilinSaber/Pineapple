//
//  AppDelegate.m
//  Pineapple iOS Example
//
//  Created by Fan Li Lin on 2017/3/27.
//
//

#import "AppDelegate.h"
#import "PWHomeViewController.h"
#import "PWCodeListViewController.h"
#import "IQKeyboardManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];        
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[PWCodeListViewController new]];
    [self.window makeKeyAndVisible];
    
    [self setKeyboardManager];
    
    return YES;
}

- (void)setKeyboardManager
{
    // 初始化键盘
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    // 控制整个功能是否启用
    manager.enable = YES;
    // 控制点击背景是否收起键盘
    manager.shouldResignOnTouchOutside = YES;
    // 控制键盘上的工具条文字颜色是否用户自定义
    manager.shouldToolbarUsesTextFieldTintColor = NO;
    // 控制是否显示键盘上的工具条
    manager.enableAutoToolbar = NO;
    manager.toolbarManageBehaviour = IQAutoToolbarByPosition;
    manager.layoutIfNeededOnUpdate = YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"url=====%@ \n  sourceApplication=======%@ \n  annotation======%@", url, sourceApplication, annotation);
    return YES;
}

@end
