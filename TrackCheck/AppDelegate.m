//
//  AppDelegate.m
//  TrackCheck
//
//  Created by ethome on 2021/1/6.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "AppDelegate.h"
#import "CSQScoketService.h"
#import "SetAddressViewController.h"
#import "SetDeviceViewController.h"
#import "TestDataModel.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (@available(iOS 13.0, *)) {
    
      } else {
          self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
          NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
          long long currentTime = [[NSDate date] timeIntervalSince1970];
          long long saveTime = [[user objectForKey:@"saveStaionTime"] longLongValue];
          NSLog(@"current - save = %lld %lld = %lld",currentTime,saveTime,currentTime-saveTime);
          if(currentTime - saveTime >= 8 *3600){
              NSLog(@"SetAddressViewController");
              SetAddressViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]  instantiateViewControllerWithIdentifier:@"SetAddressViewController"];
              UKNavigationViewController *nav = [[UKNavigationViewController alloc]initWithRootViewController:homeVC];
              [self.window setRootViewController:nav];
          }else{
              NSLog(@"SetDeviceViewController");
              SetDeviceViewController *homeVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]  instantiateViewControllerWithIdentifier:@"SetDeviceViewController"];
              UKNavigationViewController *nav = [[UKNavigationViewController alloc]initWithRootViewController:homeVC];
   
              [self.window setRootViewController:nav];
          }
          self.window.backgroundColor = [UIColor whiteColor];
          [self.window makeKeyAndVisible];
      }
    [self preSocke];
//    long revData = (long)strtoul([@"8000" UTF8String],0,16);  //16进制字符串转换成long
//    NSLog(@"%ld",revData);

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return YES;
}




-(void)preSocke{
    NSLog(@"重启socket");
    [self.scoketThread cancel];
    self.scoketThread = nil;
    self.scoketThread = [[NSThread alloc]initWithTarget:self selector:@selector(startSocket) object:nil];
    [self.scoketThread start];
}
-(void)startSocket{
    [CSQScoketService deallocSocket];
    CSQScoketService *socketSerview = [CSQScoketService shareInstance];
    //开始服务
    [socketSerview start];
        
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]run];//目的让服务器不停止//循环运行
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}
@end
