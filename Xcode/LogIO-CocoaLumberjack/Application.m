//
//  Application.m
//  LogIO-CocoaLumberjack
//
//  Created by Ivan Sanchez on 16/05/2014.
//  Copyright (c) 2014 Ivan Sanchez. All rights reserved.
//

#import "Application.h"
#import "MainViewController.h"
#import "LogIOLogger.h"

int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation Application

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[LogIOLogger sharedInstance]];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    [LogIOLogger configureNode:deviceName stream:appName];
    [LogIOLogger connectTo:@"localhost" port:28777];

    DDLogInfo(@"Application started.");

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    MainViewController *viewController = [[MainViewController alloc] init];
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end