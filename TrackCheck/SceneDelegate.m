#import "SceneDelegate.h"
#import "SetAddressViewController.h"
#import "SetDeviceViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)){
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        [self.window setWindowScene:windowScene];
        [self.window setBackgroundColor:[UIColor whiteColor]];
        
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
        [self.window makeKeyAndVisible];
    } else {
        // Fallback on earlier versions
    }
    NSLog(@"willConnectToSession");
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    NSLog(@"sceneDidDisconnect");
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    NSLog(@"sceneDidBecomeActive");
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    NSLog(@"sceneWillResignActive");
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    NSLog(@"sceneWillEnterForeground");
}

- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    NSLog(@"sceneDidEnterBackground");
    
}
@end
