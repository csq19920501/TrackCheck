//
//  AppDelegate.h
//  TrackCheck
//
//  Created by ethome on 2021/1/6.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
//@property(nonatomic,strong)NSMutableArray *deviceArr;
@property(nonatomic,strong)NSThread *scoketThread;

-(void)preSocke;
@end

//     __weak typeof(self) weakSelf = self;
//            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.23/*延迟执行时间*/ * NSEC_PER_SEC));
//            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//
//            });
//异步主线程
//dispatch_async(dispatch_get_main_queue(), ^{ \
//typeof(weakSelf) self = weakSelf; \
//{x} \
//});
//全局线程
//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//  viewcontroller changeView  smooth lttb max
//  reportviewcontroller viewdidload  smooth lttb max
