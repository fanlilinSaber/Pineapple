//
//  AppDelegate.m
//  Pineapple iOS Example
//
//  Created by Dan Jiang on 2017/3/27.
//
//

#import "AppDelegate.h"
#import "PWHomeViewController.h"
#import "PWCodeListViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];        
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[PWCodeListViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
