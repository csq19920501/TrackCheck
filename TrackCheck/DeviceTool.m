//
//  DeviceTool.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "DeviceTool.h"
#import "TestDataModel.h"
#import "UIColor+PYSearchExtension.h"
@implementation DeviceTool
+ (DeviceTool *)shareInstance{
    
    static DeviceTool *tcpSocket =nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tcpSocket = [[DeviceTool alloc] init];
        tcpSocket.isDebug = NO;
        tcpSocket.isX3 = NO;
        tcpSocket.seleLook = ONE;
        tcpSocket.shenSuo = NoSet;
        tcpSocket.jOrX = J;
        tcpSocket.deviceNameArr = @[@"J1",@"J2",@"J3",@"J4",@"J5",@"J6"];
        tcpSocket.deviceArr = [NSMutableArray array];
        tcpSocket.deviceDataArr1 = [NSMutableArray array];
        tcpSocket.deviceDataArr2 = [NSMutableArray array];
        tcpSocket.deviceDataArr3 = [NSMutableArray array];
        tcpSocket.deviceDataArr4 = [NSMutableArray array];
        tcpSocket.deviceDataArr5 = [NSMutableArray array];
        
        tcpSocket.stationStrArr = [NSMutableArray array];
        tcpSocket.roadSwitchNoArr = [NSMutableArray array];
        tcpSocket.savedStationArr = [NSMutableArray array];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        tcpSocket.stationStr = [user objectForKey:@"stationStr"];
        tcpSocket.roadSwitchNo = [user objectForKey:@"roadSwitchNo"];
        tcpSocket.tianqiStr = [user objectForKey:@"tianqiStr"];
        tcpSocket.wenduStr = [user objectForKey:@"wenduStr"];
        tcpSocket.nameStr = [user objectForKey:@"nameStr"];
        
        
        NSArray *stationStrArr = [user objectForKey:@"stationStrArr"];
        if(stationStrArr.count == 0){
            stationStrArr = @[@"杭州南站",@"杭州基地",@"杭州站",@"杭州南站2"];
        }
        tcpSocket.stationStrArr = [NSMutableArray arrayWithArray:stationStrArr];
        tcpSocket.roadSwitchNoArr = [NSMutableArray arrayWithArray:[user objectForKey:@"roadSwitchNoArr"]];
        tcpSocket.savedStationArr = [NSMutableArray arrayWithArray:[user objectForKey:@"savedStationArr"]];
        [tcpSocket.savedStationArr addObjectsFromArray:tcpSocket.stationStrArr];
        tcpSocket.saveStaionTime = [[user objectForKey:@"saveStaionTime"] longLongValue];
        
        tcpSocket.shenSuo = [user integerForKey:[NSString stringWithFormat:@"%@%@",tcpSocket.stationStr,tcpSocket.roadSwitchNo]];
        
        tcpSocket.reportSele1 = 0;
        tcpSocket.reportSele2 = 0;
        tcpSocket.reportSele3 = 0;
        tcpSocket.reportSele4 = 0;
        [tcpSocket getSavedStationArr];
        
        NSNumber *maxCount = [user valueForKey:@"maxCount"];
        if(!maxCount){
            tcpSocket.testMaxCount = 180;
        }else{
            tcpSocket.testMaxCount = maxCount.integerValue;
        }
    });
    return tcpSocket;
}
-(void)removeAllData{
    [self.deviceDataArr1 removeAllObjects];
    [self.deviceDataArr2 removeAllObjects];
    [self.deviceDataArr3 removeAllObjects];
    [self.deviceDataArr4 removeAllObjects];
    [self.deviceDataArr5 removeAllObjects];
    
    self.checkModel1 = nil;
    self.checkModel2 = nil;
    self.checkModel3 = nil;
    self.checkModel4 = nil;
    self.checkModel5 = nil;
    
    for (Device*dev in _deviceArr) {
        [dev.reportArr removeAllObjects];
        [dev.colorArr removeAllObjects];
        [dev.fanColorArr removeAllObjects];
        [dev.close_transArr removeAllObjects];
    }
}
-(void)syncArr{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSArray arrayWithArray:_stationStrArr] forKey:@"stationStrArr"];
    [user setObject:[NSArray arrayWithArray:_roadSwitchNoArr] forKey:@"roadSwitchNoArr"];
    [user setObject:[NSArray arrayWithArray:_savedStationArr] forKey:@"savedStationArr"];
    NSLog(@"userdefault 保存 _roadSwitchNoArr = %@",_roadSwitchNoArr);
    [user setObject:_stationStr forKey:@"stationStr"];
    [user setObject:_roadSwitchNo forKey:@"roadSwitchNo"];
    
    [user setObject:_nameStr forKey:@"nameStr"];
    [user setObject:_wenduStr forKey:@"wenduStr"];
    [user setObject:_tianqiStr forKey:@"tianqiStr"];
    
    long long currentTime = [[NSDate date] timeIntervalSince1970];
    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
    [user setObject:time forKey:@"saveStaionTime"];
    [user synchronize];
   
}
-(void)getSavedStationArr{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法 forPrimaryKey
    dispatch_async(queue, ^{
//        NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
//         where:nil];
//        for (TestDataModel *model in results) {
//            NSArray*statArr = [NSArray arrayWithArray:arr];
//            BOOL isExit = NO;
//            for(NSString *str  in statArr){
//                if([str isEqualToString:model.station]){
//                    isExit = YES;
//                    break;
//                }
//            }
//            if(!isExit){
//                [arr addObject:model.station];
//            }
//        }
//        self.savedStationArr = [NSMutableArray arrayWithArray:arr];
    });
}

//-(void)changeReport:(PYOption *)option reportArr:(NSArray*)device maxCount:(int)maxCount{
//    int maxCountNow = 8;
//    if(maxCount){
//        maxCountNow = maxCount;
//    }
//    if(device.count > 0){
//        NSString *text = @"监测报告:\n" ;
//        int start = 1; int end = (int)device.count;
//        if(device.count <=maxCountNow){
//            start = 1 ;
//        }else{
//            start =  (int)device.count - maxCountNow +1;
//        }
//           for(int i =start;i<end + 1;i++){
//               ReportModel *rep = device[i-1];
////               NSLog(@"ReportModel.reportType = %ld",rep.reportType);
//               switch (rep.reportType) {
//                   case 1:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:定扳反 峰值%ld 均值%ld\n",text,i,rep.all_Top,rep.all_mean];
//                       }
//                       break;
//                       case 2:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:定扳反受阻 峰值%ld 稳态均值%ld\n",text,i,rep.blocked_Top,rep.blocked_stable];
//                       }
//                       break;
//                       case 3:
//                                          {
//                                              text = [NSString stringWithFormat:@"%@%d:反扳定 峰值%ld 均值%ld\n",text,i,rep.all_Top,rep.all_mean];
//                                          }
//                       break;
//                       case 4:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:反扳定受阻 峰值%ld 稳态均值%ld\n",text,i,rep.blocked_Top,rep.blocked_stable];
//                       }
//                                          break;
//
//                       case 5:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:定扳反 反位锁闭力净值%ld\n",text,i,rep.close_fan - rep.keep_fan];
////                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
////                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
//                       }
//                                          break;
//                       case 6:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:定扳反受阻\n",text,i];
//                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
//                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
//                       }
//                                          break;
//                       case 7:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:反扳定 定位锁闭力净值%ld\n",text,i,rep.close_ding-rep.keep_ding];
////                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
////                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
//                       }
//                                          break;
//                       case 8:
//                       {
//                           text = [NSString stringWithFormat:@"%@%d:反扳定受阻\n",text,i];
//                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
//                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
//                       }
//                                          break;
//                   default:
//                       break;
//               }
//           }
////        NSLog(@"text = %@",text);
//           option.graphic.style= @{
//                   @"fill": @"#333",
//                   @"text": text,
//                   @"font": @"12px Microsoft YaHei"
//           };
////           option.graphic.onclick = @"(function report(){function add(){}; add();let y = 1; return y;})";
//       }
//}

-(void)changeReport:(PYOption *)option reportArr:(NSArray*)device maxCount:(int)maxCount{
    int maxCountNow = 8;
    if(maxCount){
        maxCountNow = maxCount;
    }
    NSMutableArray *graphicAr = [NSMutableArray array];
    long y = 0;
    if(device.count > 0){
        NSString *text = @"监测报告:" ;
        NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
            @"fill": @"#333",
            @"text": text,
            @"font": @"12px Microsoft YaHei"
        }};
        [graphicAr addObject:dict];
        y = y+ 12;

        int start = 1; int end = (int)device.count;
        if(device.count <=maxCountNow){
            start = 1 ;
        }else{
            start =  (int)device.count - maxCountNow +1;
        }
           for(int i =start;i<end + 1;i++){
               ReportModel *rep = device[i-1];

               NSString *textColor = @"#333";
               if(rep.warnType == 1){
                   textColor =  organiColor;
               }else if(rep.warnType == 2){
                   textColor =  realRedColor;
               }

               switch (rep.reportType) {
                   case 1:
                       {
                           text = [NSString stringWithFormat:@"%d:定扳反 峰值%ld 均值%ld",i,rep.all_Top,rep.all_mean];

                           NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                               @"fill": textColor,
                               @"text": text,
                               @"font": @"12px Microsoft YaHei"
                           }};
                           [graphicAr addObject:dict];
                           y = y+ 12;
                       }
                       break;
                       case 2:
                       {
                           text = [NSString stringWithFormat:@"%d:定扳反受阻 峰值%ld 稳态均值%ld",i,rep.blocked_Top,rep.blocked_stable];
                           NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                               @"fill": textColor,
                               @"text": text,
                               @"font": @"12px Microsoft YaHei"
                           }};
                           [graphicAr addObject:dict];
                           y = y+ 12;
                       }
                       break;
                       case 3:
                                          {
                                              text = [NSString stringWithFormat:@"%d:反扳定 峰值%ld 均值%ld",i,rep.all_Top,rep.all_mean];
                                              NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                                                  @"fill": textColor,
                                                  @"text": text,
                                                  @"font": @"12px Microsoft YaHei"
                                              }};
                                              [graphicAr addObject:dict];
                                              y = y+ 12;
                                          }
                       break;
                       case 4:
                       {
                           text = [NSString stringWithFormat:@"%d:反扳定受阻 峰值%ld 稳态均值%ld",i,rep.blocked_Top,rep.blocked_stable];
                           NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                               @"fill": textColor,
                               @"text": text,
                               @"font": @"12px Microsoft YaHei"
                           }};
                           [graphicAr addObject:dict];
                           y = y+ 12;
                       }
                                          break;

                       case 5:
                       {
                           text = [NSString stringWithFormat:@"%d:定扳反 反位锁闭力净值%ld",i,rep.close_fan - rep.keep_fan];
                           NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                               @"fill": textColor,
                               @"text": text,
                               @"font": @"12px Microsoft YaHei"
                           }};
                           [graphicAr addObject:dict];
                           y = y+ 12;
                       }
                                          break;
                       case 6:
                       {
//                           text = [NSString stringWithFormat:@"%@%d:定扳反受阻\n",text,i];
//                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
//                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
                       }
                                          break;
                       case 7:
                       {
                           text = [NSString stringWithFormat:@"%d:反扳定 定位锁闭力净值%ld",i,rep.close_ding-rep.keep_ding];

                           NSDictionary *dict = @{@"type":@"text",@"z":@(100),@"y":@(y),@"style":@{
                               @"fill": textColor,
                               @"text": text,
                               @"font": @"12px Microsoft YaHei"
                           }};
                           [graphicAr addObject:dict];
                           y = y+ 12;

                       }
                                          break;
                       case 8:
                       {
//                           text = [NSString stringWithFormat:@"%@%d:反扳定受阻\n",text,i];
//                           text = [NSString stringWithFormat:@"%@定位锁闭力%ld 定位保持力%ld\n",text,rep.close_ding,rep.keep_ding];
//                           text = [NSString stringWithFormat:@"%@反位锁闭力%ld 反位保持力%ld\n",text,rep.close_fan,rep.keep_fan];
                       }
                                          break;
                   default:
                       break;
               }
           }

           option.graphic.children= graphicAr;
       }
}


-(NSString *)getLinkDevice{
    if([DEVICETOOL.closeLinkDevice isEqualToString:@"J1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J4"]){
        return @"1";
    }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J5"]){
        return @"2";
    }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J6"]){
        return @"3";
    }
    return nil;
}
@end
