//
//  CSQScoketService.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "CSQScoketService.h"
#import "Device.h"
#import "CheckModel.h"
#import "ReportModel.h"
#import "ETAFNetworking.h"
#import "TestDataModel.h"
//#import "TcpManager.h"
static CSQScoketService *tcpSocket =nil;
static dispatch_once_t onceToken;
@interface CSQScoketService ()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) GCDAsyncSocket *socket;

@property (assign, nonatomic) int socketNum;
//@property(strong,nonatomic) GCDAsyncSocket *testSocket;
@property (strong,nonatomic)NSMutableDictionary *socketDic;

@end
@implementation CSQScoketService

+ (CSQScoketService *)shareInstance{
    dispatch_once(&onceToken, ^{
        tcpSocket = [[CSQScoketService alloc] init];
    });
    return tcpSocket;
}
+(void)deallocSocket{
    [tcpSocket.timer invalidate];
    tcpSocket.timer = nil;
    [tcpSocket.clientSockets removeAllObjects];
    [tcpSocket.socket disconnect];
    tcpSocket=nil;
    onceToken=0l;
    NSLog(@"销毁单例");
}
- (NSMutableArray *)clientSockets
{
    if (_clientSockets == nil) {
        _clientSockets = [[NSMutableArray alloc]init];
    }
    return _clientSockets;
}

- (void)start
{
    //1.创建scoket对象
    _clientSockets = [[NSMutableArray alloc]init];
    _socketDic = [NSMutableDictionary dictionary];
    GCDAsyncSocket *serviceScoket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    //2.绑定端口(5288)
   //端口任意，但遵循有效端口原则范围：0~65535，其中0~1024由系统使用或者保留端口，开发中建议使用1024以上的端口
    NSError *error = nil;
    [serviceScoket acceptOnPort:5288 error:&error];

    //3.开启服务(实质第二步绑定端口的同时默认开启服务)
    if (error == nil)
    {
        NSLog(@"start开启成功");
    }
    else
    {
        NSLog(@"start开启失败%@",error);
    }
    self.socket = serviceScoket;
    _socketNum = 0;
    if(!DEVICETOOL.isDebug){
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(manangeSocket) userInfo:nil repeats:YES];
    }
}
-(void)manangeSocket{
    if(DEVICETOOL.isDebug ){
        return;
    }
    NSArray *socketA = [self.clientSockets copy];
    for (GCDAsyncSocket *socket in socketA) {
        NSLog(@"self.clientSockets.count = %ld",self.clientSockets.count);
        NSLog(@"socket = %@",[NSString stringWithFormat:@"%@",socket]);
        NSNumber* number = [_socketDic valueForKey:[NSString stringWithFormat:@"%@",socket]];
        int num = number.intValue;
        num++;
        if(num>5){
            NSLog(@"num>3删掉socket%@",socket);
            [self.clientSockets removeObject:socket];
        }else{
            [_socketDic setValue:[NSNumber numberWithInt:num] forKeyPath:[NSString stringWithFormat:@"%@",socket]];
        }
    }
    
    if(self.clientSockets.count==0 || self.clientSockets.count>5){
        _socketNum ++;
        if(_socketNum>4){
            _socketNum = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                AppDelegate *delete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
                [delete preSocke];
//                NSError *error = nil;
//                [self.socket disconnect];
//                [self.socket acceptOnPort:5288 error:&error];
//                if (error == nil)
//                {
//                    NSLog(@"重新开启成功");
//                }
//                else
//                {
//                    NSLog(@"重新开启失败%@",error);
//                }
            });
        }
    }else{
        _socketNum = 0;
    }
}

-(void)addDebugDevice{
    NSDictionary *deviceDict22 = @{
        @"id":@"2",
        @"version":@"sss"
    };
    [self changeDevice:deviceDict22];
    
    NSDictionary *deviceDict = @{
        @"id":@"1",
        @"version":@"sss"
    };
    [self changeDevice:deviceDict];
    
    NSDictionary *deviceDict33 = @{
        @"id":@"3",
        @"version":@"sss"
    };
    [self changeDevice:deviceDict33];
    
    NSDictionary *deviceDict2 = @{
        @"id":@"11",
        @"version":@"sss11"
    };
    [self changeDevice:deviceDict2];
    
    NSDictionary *deviceDict3 = @{
           @"id":@"12",
           @"version":@"sss12"
       };
    [self changeDevice:deviceDict3];
}
#pragma mark GCDAsyncSocketDelegate
//连接到客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    //sock 服务端的socket
    NSLog(@"新增链接%@----%@",sock, newSocket);

    //1.保存连接的客户端socket(否则newSocket释放掉后链接会自动断开)
    [self.clientSockets addObject:newSocket];
    [newSocket readDataWithTimeout:-1 tag:0];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
//    NSLog(@"断开链接%@----%@",sock, err);
    NSLog(@"断开链接localizedDescription---%@", err.localizedDescription);
    [self.clientSockets removeObject:sock];
}
//接收到客户端数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //1.接受到用户数据
    
    [_socketDic setValue:@(0) forKeyPath:[NSString stringWithFormat:@"%@",sock]];
     
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"recv:%@",str);
    NSLog(@"新增数据%@----%@",[NSString stringWithFormat:@"%@",sock], str);
    NSDictionary *dic = str.mj_JSONObject;
//    dic = @{@"cmd":@"push_msg",@"id":@"1",@"charging":@"0",@"vol":@"3.99",@"version":@"1.0.0",@"time":@"2021-04-28 13:47:54"};
    
    id cmd = dic[@"cmd"];
    
    if(![cmd isKindOfClass:[NSString class]]){
        NSLog(@"cmd数据非字符串");
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD showAlertWithText:@"cmd数据非字符串"];
        });
    
        return;
    }
    id idStr = dic[@"id"];
   
    if(![idStr isKindOfClass:[NSString class]]){
        NSLog(@"id数据非字符串");
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD showAlertWithText:@"id数据非字符串"];
        });
        return;
    }
    if([idStr isEqualToString:@""]|| [idStr isEqual:[NSNull null]]){
        NSLog(@"id为空");
        dispatch_async(dispatch_get_main_queue(), ^{
            [HUD showAlertWithText:@"id数据为空"];
        });
        return;
    }
    
    NSString *dataStr = nil;
    if([cmd isEqualToString:@"push_msg"]){
        NSDictionary *dict =  @{@"cmd":@"push_msg_ack",@"packnum":@"0"};
        dataStr = dict.mj_JSONString;
    
        if( DEVICETOOL.testStatus != TestStarted){
            [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
            [sock readDataWithTimeout:-1 tag:0];
            return;
        }
        if(!DEVICETOOL.isDebug){
            if(DEVICETOOL.testStatus == TestStarted){
                   [self getData:dic];
            }
        }
    }else if([cmd isEqualToString:@"time"]){
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSNumber *time = [NSNumber numberWithLongLong:currentTime];
        NSDictionary *dict =  @{@"cmd":@"time_ack",@"timestamp":time};
        dataStr = dict.mj_JSONString;
        
        DEVICETOOL.timeOk = YES;
    }
    else if([cmd isEqualToString:@"ping"]){
        [self  changeDevice:dic];
        NSDictionary *dict =  @{@"cmd":@"pong"};
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if([device.id isEqualToString:dic[@"id"]]){
                device.percent = dic[@"percent"];
                device.vol = dic[@"vol"];
                device.charging = dic[@"charging"];
            }
        }
        dataStr = dict.mj_JSONString;
        
    }else if([cmd isEqualToString:@"push_info"]){
        NSDictionary *dict =  @{@"cmd":@"push_info_ack"};
        dataStr = dict.mj_JSONString;
        
//        [self  changeDevice:dic];
    }else if([cmd isEqualToString:@"version_ack"]){
        [self  changeDevice:dic];
//        NSDictionary *dict =  @{@"cmd":@"version_ack"};
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if([device.id isEqualToString:dic[@"id"]]){
                device.percent = dic[@"percent"];
                device.vol = dic[@"vol"];
                device.charging = dic[@"charging"];
            }
        }
//        dataStr = dict.mj_JSONString;
        
    }
    [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    [sock readDataWithTimeout:-1 tag:0];
}
-(void)startSample{
    for (GCDAsyncSocket *sock in self.clientSockets) {
        NSString *dataStr = nil;
        NSDictionary *dict =  @{@"cmd":@"sample",@"flag":@"1"};
        dataStr = dict.mj_JSONString;
        [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [sock readDataWithTimeout:-1 tag:0];
    }
}
-(void)stopSample{
    for (GCDAsyncSocket *sock in self.clientSockets) {
        NSString *dataStr = nil;
        NSDictionary *dict =  @{@"cmd":@"sample",@"flag":@"0"};
        dataStr = dict.mj_JSONString;
        [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [sock readDataWithTimeout:-1 tag:0];
    }
}
-(void)getVersion{
    for (GCDAsyncSocket *sock in self.clientSockets) {
        NSString *dataStr = nil;
        NSDictionary *dict =  @{@"cmd":@"version"};
        dataStr = dict.mj_JSONString;
        [sock writeData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
        [sock readDataWithTimeout:-1 tag:0];
        NSLog(@"发送version指令");
    }
}
-(void)getData:(NSDictionary*)dic{
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                id timeStr = dic[@"time"];
                if(![timeStr isKindOfClass:[NSString class]]){
                    NSLog(@"time数据不正常");
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HUD showAlertWithText:@"time数据非字符串"];
                    });
                    return;
                }
                if([timeStr isEqualToString:@""]|| [timeStr isEqual:[NSNull null]]){
                    NSLog(@"time数据为空");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HUD showAlertWithText:@"time数据为空"];
                    });
                    return;
                }
                NSString *time = timeStr;
                if(time.length != 19){
                    NSLog(@"时间数据长度不对");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [HUD showAlertWithText:@"时间数据长度不对"];
                    });
                    return;
                }
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                NSDate *localDate = [dateFormatter dateFromString:timeStr];
                NSTimeInterval timeinterval = [localDate timeIntervalSince1970]*1000;
                
    //            NSLog(@"timeinterval 收到时间 = %@-%f",timeStr,timeinterval);
    //            long long timeinter = (long long)timeinterval;
//                NSString * idStr = dic[@"id"];
                
                id idStr = dic[@"id"];
//                if([idStr isEmpty] ||[idStr isEqualToString:@""]|| [idStr isEqual:[NSNull null]]){
//                    [HUD showAlertWithText:@"id数据不正常"];
//                    return;
//                }
//                if(![idStr isKindOfClass:[NSString class]]){
//                    NSLog(@"数据不正常");
//                    [HUD showAlertWithText:@"id数据不正常"];
//                    return;
//                }
                
                if(DEVICETOOL.seleLook == ONE){

                    if([idStr intValue] == 11 || [idStr intValue] == 12){
                        return ;
                    }
                }else if(DEVICETOOL.seleLook == TWO){
                    
                    if([idStr intValue] == 11 || [idStr intValue] == 12){
                    NSLog(@"[idStr intValue] = %d",[idStr intValue]);
                    }else{
                    
                    if([DEVICETOOL.closeLinkDevice isEqualToString:@"J1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J4"]){
                          if([idStr intValue] != 1 ){
                              return ;
                          }
                       }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J5"]){
                           if([idStr intValue] != 2){
                               return ;
                           }
                          
                       }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J6"]){
                           if([idStr intValue] != 3 ){
                               return ;
                           }
                       }
                       }
                    
                }
                
                NSString *typeStr ;
                for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                    Device *device = DEVICETOOL.deviceArr[i];
                    if(!device.selected &&  [device.id isEqualToString:idStr]){
                        return;
                    }else if([device.id isEqualToString:idStr]){
                        typeStr = device.typeStr;
                    }
                }
                
                NSMutableArray *dataArr = nil;
                CheckModel *checkModel ;
                NSLog(@"[idStr intValue] = %d",[idStr intValue]);
                switch ([idStr intValue]) {
                    case 1:{
                        dataArr = [DeviceTool shareInstance].deviceDataArr1;
                        checkModel = DEVICETOOL.checkModel1;
                    }
                        break;
                    case 2:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr2;
                            checkModel = DEVICETOOL.checkModel2;
                        }
                        break;
                    case 3:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr3;
                            checkModel = DEVICETOOL.checkModel3;
                        }
                        break;
                    case 11:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr4;
                            checkModel = DEVICETOOL.checkModel4;
                            NSLog(@"添加11数据");
                        }
                        break;
                    case 12:
                        {
                            dataArr = [DeviceTool shareInstance].deviceDataArr5;
                            checkModel = DEVICETOOL.checkModel5;
                            NSLog(@"添加12数据");
                        }
                        break;
                    default:
                        break;
                }
                //初始时间 初始时间
                id dataStr = dic[@"data"];
                if(![dataStr isKindOfClass:[NSString class]]){
                    NSLog(@"dataStr数据不正常");
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [HUD showAlertWithText:@"dataStr数据不正常"];
                    });
                    return;
                }
                
                
                NSArray *reciveataArr = [dataStr componentsSeparatedByString:@","];
                NSMutableArray *checkArr = [NSMutableArray array];
                NSMutableArray *timeArr = [NSMutableArray array];
                [reciveataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    long revData = (long)strtoul([obj UTF8String],0,16);  //16进制字符串转换成long
                    revData = revData - 32768;  //  85317
                    if(DEVICETOOL.shenSuo == Shen_Fan_zuo || DEVICETOOL.shenSuo == Shen_Ding_zuo){
                        revData = 0 - revData;
                    }
                    NSTimeInterval  timeinterval2 = timeinterval + idx*20;
                    [dataArr addObject:@[@(timeinterval2),@(revData)]];
                    [checkArr addObject:@(revData)];
                    [timeArr addObject:@(timeinterval2)];

                }];
                
                switch ([idStr intValue]) {
                    case 1:{
                        if(!DEVICETOOL.checkModel1){
                            DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
                        }
                        [self checkData:checkArr withModel:DEVICETOOL.checkModel1 withTypeStr:typeStr  withId:[idStr intValue] withTimeArr:timeArr];
                    }
                        break;
                    case 2:
                        {
                            if(!DEVICETOOL.checkModel2){
                                DEVICETOOL.checkModel2 = [[CheckModel alloc]init];
                            }
                            [self checkData:checkArr withModel:DEVICETOOL.checkModel2 withTypeStr:typeStr withId:[idStr intValue] withTimeArr:timeArr];
                        }
                        break;
                    case 3:
                        {
                            if(!DEVICETOOL.checkModel3){
                                DEVICETOOL.checkModel3 = [[CheckModel alloc]init];
                            }
                             [self checkData:checkArr withModel:DEVICETOOL.checkModel3 withTypeStr:typeStr withId:[idStr intValue] withTimeArr:timeArr];
                        }
                        break;
                    case 11:
                    {
                            if(!DEVICETOOL.checkModel4){
                                DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
                            }
                        
                        
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:[idStr intValue] withTimeArr:timeArr];
                        }
                        break;
                    case 12:
                        {
                            if(!DEVICETOOL.checkModel4){
                                DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
                            }
                            [self check56Data:checkArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:[idStr intValue] withTimeArr:timeArr];
                        }
                        break;
                    default:
                        break;
                }

               
            });
}
-(void)test1234_{
    
    _testCount = 0;
    __weak typeof(self) weakSelf = self;
//    NSString *url = @"http://118.31.39.28:21006/getresistance.cpp?starttime=2021-01-20%2002:51:00&endtime=2021-01-20%2002:51:20&IMEI=860588048931334&name=%E6%99%AE%E5%AE%8914%E5%8F%B7%E5%B2%94%E5%BF%83&idx=0&timestamp=1611107677743&idxname=X2";
//    NSString *url2 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //阻力转换
//
//     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-03-04%2013:18:10&endtime=2021-03-04%2013:20:20&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
//
//    [ETAFNetworking getLMK_AFNHttpSrt:url3 andTimeout:8.f andParam:nil success:^(id responseObject) {
//        NSArray *series = responseObject[@"series"];
//        if(series.count>2){
//            weakSelf.testArray = series[2][@"data"];
//            NSLog(@"获取到的历史数据数量%ld  %@ %@ ",weakSelf.testArray.count,series[2][@"name"],series[2][@"data"]);
//             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer) userInfo:nil repeats:YES];
//        }
//    } failure:^(NSError *error) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [HUD hideUIBlockingIndicator];
//        });
//
//
//    } WithHud:NO AndTitle:nil];
    
   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@",@"2021-03-29",@"21:02:55"];
    NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    
    NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@",@"2021-03-29",@"23:59:59"];
    NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];

    NSString *stationS = DEVICETOOL.stationStr;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
        where: @"station = '%@' and timeLong > %@ and timeLong < %@",stationS,@(startTimeInterval),@(endTimeInterval)];
      
        dispatch_async(dispatch_get_main_queue(), ^{
            if(results.count != 0){
                TestDataModel *dataModel = results[0];
                    weakSelf.testArray = dataModel.dataArr;
//                    weakSelf.testArray2 = dataModel.dataArr[1];
//                    weakSelf.testArray3 = dataModel.dataArr[2];
                    NSLog(@"获取到的历史数据数量%ld  %@  ",weakSelf.testArray.count,dataModel.dataArr);
                if(self.timer){
                    [self.timer invalidate];
                    self.timer = nil;
                }
                     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer) userInfo:nil repeats:YES];
                
            }
        });
    });
    
}
-(void)test1234{
    
    _testCount = 0;
    __weak typeof(self) weakSelf = self;

//    NSString *url2 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2010:20:07&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //阻力转换
//
////     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:02:00&endtime=2021-01-10%2010:03:00&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
//
//     NSString *url3 = @"http://202.107.226.68:21006/getresistance.cpp?starttime=2021-01-10%2010:15:38&endtime=2021-01-10%2023:20:08&IMEI=860588048955283&name=%E5%9F%BA%E5%9C%B021%E5%8F%B7%E5%B2%94%E5%B0%96&idx=0&timestamp=1611139739392&idxname=J1";  //多时间
//
//    [ETAFNetworking getLMK_AFNHttpSrt:url3 andTimeout:8.f andParam:nil success:^(id responseObject) {
//        NSArray *series = responseObject[@"series"];
//        if(series.count>2){
//            weakSelf.testArray = series[1][@"data"];
//            weakSelf.testArray2 = series[0][@"data"];
//
//            NSLog(@"获取到的历史数据数量%ld  %@ %@ ",weakSelf.testArray.count,series[1][@"name"],series[1][@"data"]);
//             self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer56) userInfo:nil repeats:YES];
//        }
//    } failure:^(NSError *error) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [HUD hideUIBlockingIndicator];
//        });
//    } WithHud:NO AndTitle:nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *startTimeStr = [NSString stringWithFormat:@"%@ %@",@"2021-03-29",@"20:52:02"];
    NSDate *startDate = [dateFormatter dateFromString:startTimeStr];
    NSTimeInterval startTimeInterval = [startDate timeIntervalSince1970];
    
    NSString *endTimeStr = [NSString stringWithFormat:@"%@ %@",@"2021-03-29",@"23:59:59"];
    NSDate *endDate = [dateFormatter dateFromString:endTimeStr];
    NSTimeInterval endTimeInterval = [endDate timeIntervalSince1970];

    NSString *stationS = DEVICETOOL.stationStr;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        NSArray <TestDataModel *> * results = [[LPDBManager defaultManager] findModels: [TestDataModel class]
        where: @"station = '%@' and timeLong > %@ and timeLong < %@",stationS,@(startTimeInterval),@(endTimeInterval)];
      
        dispatch_async(dispatch_get_main_queue(), ^{
            if(results.count != 0){
                TestDataModel *dataModel = results[0];
                
          
                    weakSelf.testArray = dataModel.dataArr[0];
                    weakSelf.testArray2 = dataModel.dataArr[1];
                    weakSelf.testArray3 = dataModel.dataArr[2];
                    NSLog(@"获取到的历史数据数量%ld  %@  ",weakSelf.testArray.count,dataModel.dataArr);
                               if(self.timer){
                                   [self.timer invalidate];
                                   self.timer = nil;
                               }
                     self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(testTimer56) userInfo:nil repeats:YES];
                
            }
            
        });
    });
}
-(void)stopTest1234{
    [self.timer invalidate];
    self.timer = nil;
    _testCount = 0;
}
-(void)testTimer{
    if(DEVICETOOL.testStatus != TestStarted){
        NSLog(@"还未点击开始");
        return;
    }
    if(!DEVICETOOL.checkModel1){
        NSLog(@"生成DEVICETOOL.checkModel1");
        DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
    }
    if(!DEVICETOOL.checkModel2){
           NSLog(@"生成DEVICETOOL.checkModel2");
           DEVICETOOL.checkModel2 = [[CheckModel alloc]init];
       }
    if(!DEVICETOOL.checkModel3){
           NSLog(@"生成DEVICETOOL.checkModel3");
           DEVICETOOL.checkModel3 = [[CheckModel alloc]init];
       }

    NSMutableArray *testArr = [NSMutableArray array];
    NSMutableArray *timeArr = [NSMutableArray array];
    if(_testCount + 50 < self.testArray.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
            [timeArr addObject:data[0]];
            [DEVICETOOL.deviceDataArr1 addObject:data];
            [DEVICETOOL.deviceDataArr2 addObject:data];
            [DEVICETOOL.deviceDataArr3 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray.count; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
             [timeArr addObject:data[0]];
            [DEVICETOOL.deviceDataArr1 addObject:data];
            [DEVICETOOL.deviceDataArr2 addObject:data];
            [DEVICETOOL.deviceDataArr3 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
//    [self checkData:testArr withModel:DEVICETOOL.checkModel1 withTypeStr:@"J1" withId:1 withTimeArr:timeArr];
//    [self checkData:testArr withModel:DEVICETOOL.checkModel2 withTypeStr:@"J2" withId:2 withTimeArr:timeArr];
    [self checkData:testArr withModel:DEVICETOOL.checkModel3 withTypeStr:@"J3" withId:3 withTimeArr:timeArr];
    _testCount = _testCount + 50;
    
}
-(void)testTimer56{
    if(DEVICETOOL.testStatus != TestStarted){
        NSLog(@"_Din 还未点击开始");
        return;
    }
    if(!DEVICETOOL.checkModel4){
        NSLog(@"_Din _Fab 生成DEVICETOOL.checkModel4");
        DEVICETOOL.checkModel4 = [[CheckModel alloc]init];
    }
    if(!DEVICETOOL.checkModel1){
        NSLog(@"生成DEVICETOOL.checkModel5");
        DEVICETOOL.checkModel1 = [[CheckModel alloc]init];
    }
    NSMutableArray *timeArr = [NSMutableArray array];
    NSMutableArray *testArr = [NSMutableArray array];
    if(_testCount + 50 < self.testArray.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray[a];
            [testArr addObject:data[1]];
             [timeArr addObject:data[0]];
            [DEVICETOOL.deviceDataArr4 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray.count; a++) {
            NSArray *data = self.testArray[a];
//            NSString *dataStr = data[1];
//            long long dataLong = [dataStr longLongValue];
//            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
//            [testArr addObject:num];
              [testArr addObject:data[1]];
             [timeArr addObject:data[0]];
            [DEVICETOOL.deviceDataArr4 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self check56Data:testArr withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:11 withTimeArr:timeArr];
    
    NSMutableArray *testArr2 = [NSMutableArray array];
    NSMutableArray *timeArr2 = [NSMutableArray array];
    if(_testCount + 50 < self.testArray2.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray2[a];
            [testArr2 addObject:data[1]];
            [timeArr2 addObject:data[0]];
            [DEVICETOOL.deviceDataArr5 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray2.count; a++) {
            NSArray *data = self.testArray2[a];
            NSString *dataStr = data[1];
            long long dataLong = [dataStr longLongValue];
            NSNumber *num = [NSNumber numberWithLongLong:dataLong];
            [testArr2 addObject:num];
            [timeArr2 addObject:data[0]];
            [DEVICETOOL.deviceDataArr5 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self check56Data:testArr2 withModel:DEVICETOOL.checkModel4 withTypeStr:@"锁闭力" withId:12 withTimeArr:timeArr2];
    
    
    NSMutableArray *testArr3 = [NSMutableArray array];
    NSMutableArray *timeArr3 = [NSMutableArray array];
    if(_testCount + 50 < self.testArray3.count){
        for (long a = _testCount; a< _testCount + 50; a++) {
            NSArray *data = self.testArray3[a];
            [testArr3 addObject:data[1]];
            [timeArr3 addObject:data[0]];
            [DEVICETOOL.deviceDataArr1 addObject:data];
        }
    }else{
        for (long a = _testCount; a< self.testArray3.count; a++) {
            NSArray *data = self.testArray3[a];
            [testArr3 addObject:data[1]];
             [timeArr3 addObject:data[0]];
            [DEVICETOOL.deviceDataArr1 addObject:data];
        }
        [self.timer invalidate];
        self.timer = nil;
    }
    [self checkData:testArr3 withModel:DEVICETOOL.checkModel1 withTypeStr:@"J1" withId:1 withTimeArr:timeArr3];
    _testCount = _testCount + 50;
    
}
//检测56类型
-(void)check56Data:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id withTimeArr:(NSArray*)timeArr{
    
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
        dispatch_async(queue, ^{
            if(id == 11){
                if(dataArr.count > 10){
                        if(model.startValue == -10000){
                               long long sum = 0;
                               for(int i=0 ;i<5;i++){
                                    NSNumber *number = dataArr[i];  //调试修改
                                    sum += number.longValue;        //调试修
                               }
                               model.startValue = sum/5;
                               NSLog(@"_Din 前五个数据生成model.startValue = %ld",model.startValue);
                        }

                        long min = 100000;
                        long max = -100000;
                        long sun = 0;
                        for (NSNumber *number in dataArr) {
                            long num = number.longValue - model.startValue;
                            sun += num;
//                            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
                            if(num < min){
                                min = num;
                            }
                            if(num > max){
                                max = num;
                            }
                        }
                        if(min < model.min){
                            model.min = min;
                        }
                        if(max > model.max){
                            model.max = max;
                        }
                        
                        long mean = sun/(int)dataArr.count;
                        
//                        NSLog(@"_Din mean = %ld min = %ld max=%ld",mean,min,max);
                        long meanSum = 0;
                        for (NSNumber *number in dataArr ) {
                            long num = number.longValue - model.startValue;
                            if((num - mean)>0){
                                meanSum += (num - mean);
                            }else{
                                meanSum += (mean - num);
                            }
                        }
                        long average = meanSum/(int)dataArr.count;
                        NSLog(@"_Din average = %ld",average);
                        if(average > 12){
                            if(!model.closeDingChange2_OK && average > 100){
                                NSLog(@"_Din average > 100  model.closeDingChange2_OK = YES");
                                model.closeDingChange2_OK = YES;
                            }
                            if(!model.closeDingChange_OK){
                                NSLog(@"_Din average > 30  model.closeDingChange_OK = YES");
                                model.closeDingChange_OK = YES;
                            }
                            [model.dataArr addObjectsFromArray:dataArr];
                            [model.timeArr addObjectsFromArray:timeArr];
                        }else{
                            if(mean  > 30 || mean  < -30){
                                if(!model.reportEdDing){
                                    [model.dataArr addObjectsFromArray:dataArr];
                                    [model.timeArr addObjectsFromArray:timeArr];
                                }
                            
                                if(!model.blockedStable1_OK){
                                    model.blockedStable1_OK = YES;
                                    NSLog(@"_Din average < 30  model.blockedStable1_OK = YES");
                                }
                               else if(!model.blockedStable2_OK){
                                    model.blockedStable2_OK = YES;
                                    NSLog(@"_Din average < 30  model.blockedStable2_OK = YES");
                                }
                                else if(!model.blockedStable3_OK){
                                    model.blockedStable3_OK = YES;
                                }
                                //判断正反锁闭力 是否生成受阻锁闭力报告
                                if(!model.reportEdDing && model.blockedStable3_OK){
                                    model.reportEdDing = YES;
                                    model.reportBlockDing = YES;
                                    model.dataModel.station = DEVICETOOL.stationStr;
                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                    
                                    model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                    model.dataModel.timeLong = currentTime;
                                    model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld%@",currentTime,@"锁闭力"];
                                    
                                    
                                    if(mean < 0){
                                        model.dataModel.close_ding = model.startValue ;
                                        model.dataModel.keep_ding = model.startValue  + mean;
                                        model.dataModel.reportType = 5;
                                         NSLog(@"_Din mean  > 3500 定扳反生成");
                                    }else{
                                        NSLog(@"_Din mean  > 3500 反扳定生成");
                                        model.dataModel.reportType = 7;
                                        model.dataModel.close_ding = model.startValue + mean;
                                        model.dataModel.keep_ding = model.startValue;
                                    }
                                  }
                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                     model.reportEd = YES;
                                     NSLog(@"_11 锁闭力生成受阻锁闭力曲线报告 清除model %@  %@",model.dataModel.idStr, model.dataModel.timeLongStr);
                                     
//                                     ReportModel *dataModel = [ReportModel initWithReport:model.dataModel];
//                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                     [self device:id addReport:model.dataModel withModel:model];
                                     [self setCheckNilWith:id];
                                 }
                                 return;
                            }else{
//                                    if(model.closeDingChange_OK){
//
//                                        if(!model.stable_1){
//                                            model.stable_1 = YES;
//                                        }else if(!model.stable_2){
//                                            model.stable_2 = YES;
//                                        }
//                                        else if(!model.stable_3){
//                                            model.stable_3 = YES;
//                                            NSLog(@"小波动 舍弃掉");
//                                            [self setCheckNilWith:id];
//                                        }
//
//                                    }
//                                    return;
                            }
                            
//                            if(!model.closeDingChange_OK){
//                                NSLog(@"_Din 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
//                                model.startValue = mean + model.startValue;
//                            }
                        }
                    }
            }else{
                if(dataArr.count > 10){
                        if(model.startValue_Fan == -10000){
                               long long sum = 0;
                               for(int i=0 ;i<5;i++){
                                    NSNumber *number = dataArr[i];  //调试修改
                                    sum += number.longValue;        //调试修
                               }
                               model.startValue_Fan = sum/5;
                               NSLog(@"_Fan 前五个数据生成model.startValue = %ld",model.startValue_Fan);
                        }

                        long min = 100000;
                        long max = -100000;
                        long sun = 0;
                        for (NSNumber *number in dataArr) {
                            long num = number.longValue - model.startValue_Fan;
                            sun += num;
                //            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
                            if(num < min){
                                min = num;
                            }
                            if(num > max){
                                max = num;
                            }
                        }
                        if(min < model.min_Fan){
                            model.min_Fan = min;
                        }
                        if(max > model.max_Fan){
                            model.max_Fan = max;
                        }
                        
                        long mean = sun/(int)dataArr.count;
                        
                        NSLog(@"_Fan mean = %ld min = %ld max=%ld",mean,min,max);
                        long meanSum = 0;
                        for (NSNumber *number in dataArr ) {
                            long num = number.longValue - model.startValue_Fan;
                            if((num - mean)>0){
                                meanSum += (num - mean);
                            }else{
                                meanSum += (mean - num);
                            }
                        }
                        long average = meanSum/(int)dataArr.count;
                        NSLog(@"_Fan average = %ld",average);
                        if(average > 12){
                            
                            if(!model.closeFanChange2_OK &&  average > 100){
                                model.closeFanChange2_OK = YES;
                            }
                            
                            if(!model.closeFanChange_OK){
                                NSLog(@"_Fan average > 400  model.closeFanChange_OK = YES");
                                model.closeFanChange_OK = YES;
                            }
                            [model.dataArr_Fan addObjectsFromArray:dataArr];
                            [model.fanTimeArr addObjectsFromArray:timeArr];
                        }else{
                            if(mean  > 30 || mean  < -30){
                                if(!model.reportEdFan){
                                    [model.dataArr_Fan addObjectsFromArray:dataArr];
                                    [model.fanTimeArr addObjectsFromArray:timeArr];
                                }
                                if(!model.blockedStable1_OK_Fan){
                                    model.blockedStable1_OK_Fan = YES;
                                    NSLog(@"_Fan average < 70  model.blockedStable1_OK = YES");
                                }
                                else if(!model.blockedStable2_OK_Fan){
                                    model.blockedStable2_OK_Fan = YES;
                                    NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES");
                                }
                                else if(!model.blockedStable3_OK_Fan){
                                   
                                    model.blockedStable3_OK_Fan = YES;
                                }
                                //判断正反锁闭力 是否生成受阻锁闭力报告
                                if(!model.reportEdFan && model.blockedStable3_OK_Fan){
                                    model.reportEdFan = YES;
                                    model.reportBlockFan = YES;
                                    model.dataModel.station = DEVICETOOL.stationStr;
                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                    model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                    model.dataModel.timeLong = currentTime;
                                    model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld%@",currentTime,@"锁闭力"];
                                      
                                    if(mean < 0){
                                        model.dataModel.close_fan = model.startValue_Fan ;
                                        model.dataModel.keep_fan = model.startValue_Fan  + mean;
                                         NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 反扳定生成");
                                       model.dataModel.reportType = 7;
                                    }else{
                                        NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 定扳反生成");
                                        model.dataModel.reportType = 5;
                                        model.dataModel.close_fan = model.startValue_Fan + mean;
                                        model.dataModel.keep_fan = model.startValue_Fan;
                                    }
                                  }
                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
                                     model.reportEd = YES;
                                     NSLog(@"_12 锁闭力生成受阻锁闭力曲线报告 清除model %@  %@",model.dataModel.idStr, model.dataModel.timeLongStr);
//                                     ReportModel *dataModel = [ReportModel initWithReport:model.dataModel];
    
//                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
                                     [self device:id addReport:model.dataModel withModel:model];
                                     [self setCheckNilWith:id];
                                 }
                                 return;
                            }else{
//
//                                    if(model.closeFanChange_OK){
//                                        if(!model.stableFan_1){
//                                            model.stableFan_1 = YES;
//                                        }else if(!model.stableFan_2){
//                                            model.stableFan_2 = YES;
//                                        }
//                                        else if(!model.stableFan_3){
//                                            model.stableFan_3 = YES;
//                                            NSLog(@"小波动 舍弃掉");
//                                            [self setCheckNilWith:id];
//                                        }
//                                    }
//                                    return;
                                
                            }
//                            if(!model.closeFanChange_OK){
//                                NSLog(@"_Fan 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
//                                model.startValue_Fan = mean + model.startValue_Fan;
//                            }
                        }
                    }
            }
        });
};
//检测1234类型
-(void)checkData:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id withTimeArr:(NSArray*)timeArr{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
    if(dataArr.count > 10){
        if(model.startValue == -10000){
               long long sum = 0;
               for(int i=0 ;i<5;i++){
                    NSNumber *number = dataArr[i];  //调试修改
                    sum += number.longValue;        //调试修
               }
               model.startValue = sum/5;
               NSLog(@"前五个数据生成model.startValue = %ld",model.startValue);
        }

        long min = 100000;
        long max = -100000;
        long sun = 0;
        for (NSNumber *number in dataArr) {
            long num = number.longValue - model.startValue;
            sun += num;
//            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
            if(num < min){
                min = num;
            }
            if(num > max){
                max = num;
            }
        }
        if(min < model.min){
            model.min = min;
        }
        if(max > model.max){
            model.max = max;
        }
        
        long mean = sun/(int)dataArr.count;
        
        NSLog(@"mean = %ld min = %ld max=%ld",mean,min,max);
        long meanSum = 0;
        for (NSNumber *number in dataArr ) {
            long num = number.longValue - model.startValue;
            if((num - mean)>0){
                meanSum += (num - mean);
            }else{
                meanSum += (mean - num);
            }
        }
        long average = meanSum/(int)dataArr.count;
        NSLog(@"average = %ld",average);
        if(average > 10){
            model.stable_1 = NO;
            model.stable_2 = NO;
            model.stable_3 = NO;
            if(!model.blockedStable3_OK){
                if(model.dataArr.count == 0){
                    for(int a = 0;a<dataArr.count;a++){
                        NSNumber *num = dataArr[a];
                        if(num.longValue - model.startValue < -2 || num.longValue - model.startValue > 2){
                            [model.dataArr addObject:dataArr[a]];
                            [model.timeArr addObject:timeArr[a]];
                        }
                    }
                }else{
                    [model.dataArr addObjectsFromArray:dataArr];
                    [model.timeArr addObjectsFromArray:timeArr];
                }
            }
            else if(model.blockedStable3_OK){
                //受阻空转生成
                
                long meanAll = 0;
                for(NSNumber *num in model.dataBlockArr){
                    meanAll += num.longValue;
                }
                meanAll = meanAll/(int)model.dataBlockArr.count;
                
                if(meanAll>=model.startValue){
                    for(int a = 0;a<dataArr.count;a++){
                        NSNumber *num = dataArr[a];
                        if(num.longValue >0){
                            [model.dataArr addObject:dataArr[a]];
                            [model.timeArr addObject:timeArr[a]];
                        }
                    }
                }else{
                    for(int a = 0;a<dataArr.count;a++){
                        NSNumber *num = dataArr[a];
                        if(num.longValue <0){
                            [model.dataArr addObject:dataArr[a]];
                            [model.timeArr addObject:timeArr[a]];
                        }
                    }
                }
            }
           
            
            if(average > 400){

                if(!model.step2_OK){
                    //小变化没两秒就急速升高则是受阻空转后错误曲线
                    model.blockedError = YES;
                    if(mean > 0){
                        model.blockedErrorTypeUp = YES;
                    }
                     NSLog(@"average > 400  model.blockedError = YES");
                    
                    
                }else{
                    if(!model.blockedChange1_OK){
                        model.blockedChange1_OK = YES;
                        NSLog(@"average > 400  model.blockedChange_OK = YES");
                        
                    }else{
                        if(model.blockedStable2_OK){
                            model.blockedChange2_OK = YES;
                             NSLog(@"average > 400  model.blockedChange2_OK = YES");
                        }
                       
                    }
                    if(model.blockedStable3_OK){
                        //受阻空转生成
                        if(!model.reportEd){
                            model.reportEd = YES;
                            long meanAll = 0;
                            for(NSNumber *num in model.dataBlockArr){
                                meanAll += num.longValue;
                            }
                            meanAll = meanAll/(int)model.dataBlockArr.count;
                            
                            ReportModel *dataModel = [[ReportModel alloc]init];
                            dataModel.station = DEVICETOOL.stationStr;
                            dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                            dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                            dataModel.deviceType = typeStr;
                            long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                            dataModel.timeLong = currentTime;
                            dataModel.timeLongStr = [NSString stringWithFormat:@"%lld%@转换阻力",currentTime,typeStr];
                            if(meanAll < model.startValue){
                                model.blocked_max = min;
                                if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                                      dataModel.reportType = 2;
                                }else {
                                      dataModel.reportType = 4;
                                }
                                dataModel.blocked_Top = model.min + model.startValue;
                                 NSLog(@"average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
                            }else{
                                 model.blocked_max = max;
                               if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                                      dataModel.reportType = 4;
                                }else {
                                      dataModel.reportType = 2;
                                }
                                dataModel.blocked_Top = model.max + model.startValue;
                                NSLog(@"average < 70  model.blockedStable2_OK = YES 反扳定受阻空转生成");
                            }
                            dataModel.blocked_stable = meanAll + model.startValue;
                            [self device:id addReport:dataModel withModel:model];
                        }
                        
                        
                    }
                }
                
            }else{

                if(!model.step1_OK){
                               //波动开始
                               model.step1_OK = YES;
                               NSDate *now = [NSDate date];
                               NSTimeInterval nowInt = [now timeIntervalSince1970];
                               model.startTime = nowInt;
                                NSLog(@"average > 70 波动开始 model.step1_OK = YES");
                           }
                           else if (!model.step2_OK){
                               model.step2_OK = YES;
                               NSLog(@"average > 70  model.step2_OK = YES");
                           }
                           else if (!model.step3_OK){
                               model.step3_OK = YES;
                               NSLog(@"average > 70  model.step3_OK = YES");
                           }
                           else if (!model.step4_OK){
                               model.step4_OK = YES;
                               NSLog(@"average > 70  model.step4_OK = YES");
                           }
            }
            
            if(model.blockedStable5_OK){
                //受阻空转生成
                if(!model.reportEd){
                    model.reportEd = YES;
                    long meanAll = 0;
                    for(NSNumber *num in model.dataBlockArr){
                        meanAll += num.longValue;
                    }
                    meanAll = meanAll/(int)model.dataBlockArr.count;
                    
                    ReportModel *dataModel = [[ReportModel alloc]init];
                    dataModel.station = DEVICETOOL.stationStr;
                    dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                    dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                    dataModel.deviceType = typeStr;
                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                    dataModel.timeLong = currentTime;
                    dataModel.timeLongStr = [NSString stringWithFormat:@"%lld%@转换阻力",currentTime,typeStr];
                    if(meanAll < model.startValue){
                        model.blocked_max = min;
                        if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                              dataModel.reportType = 2;
                        }else {
                              dataModel.reportType = 4;
                        }
                        dataModel.blocked_Top = model.min + model.startValue;
                         NSLog(@"average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
                    }else{
                         model.blocked_max = max;
                       if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                              dataModel.reportType = 4;
                        }else {
                              dataModel.reportType = 2;
                        }
                        dataModel.blocked_Top = model.max + model.startValue;
                        NSLog(@"average < 70  model.blockedStable2_OK = YES 反扳定受阻空转生成");
                    }
                    dataModel.blocked_stable = meanAll + model.startValue;
                    [self device:id addReport:dataModel withModel:model];
                }
            }
//            NSLog(@"分段 dataArr.count = %ld ",model.dataArr.count);
        }else{
            if(mean  > 1400 || mean  < -1400){
                [model.dataArr addObjectsFromArray:dataArr];
                [model.timeArr addObjectsFromArray:timeArr];
                if(!model.blockedStable1_OK){
                    model.blockedStable1_OK = YES;
                    NSLog(@"average < 70  model.blockedStable1_OK = YES");
                    [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
               
                }
               else if(!model.blockedStable2_OK){
                    model.blockedStable2_OK = YES;
                   [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
                    NSLog(@"average < 70  model.blockedStable2_OK = YES");
                }
                else if(!model.blockedStable3_OK){
                    model.blockedStable3_OK = YES;
                    [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
                    NSLog(@"average < 70  model.blockedStable3_OK = YES");
                }
                else if(!model.blockedStable4_OK){
                    model.blockedStable4_OK = YES;
                    [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
                    NSLog(@"average < 70  model.blockedStable4_OK = YES");
                }
                else if(!model.blockedStable5_OK){
                   
                    model.blockedStable5_OK = YES;
                    [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
                    //受阻空转生成
//                    ReportModel *dataModel = [[ReportModel alloc]init];
//                    dataModel.station = DEVICETOOL.stationStr;
//                    dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
//                    dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
//                    dataModel.deviceType = typeStr;
//                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
//                    dataModel.timeLong = currentTime;
//                    dataModel.timeLongStr = [NSString stringWithFormat:@"%lld转换阻力",currentTime];
//                    if(mean < model.startValue){
//                        model.blocked_max = min;
//                        if(DEVICETOOL.shenSuo == Shen_Ding){
//                              dataModel.reportType = 2;
//                        }else if(DEVICETOOL.shenSuo == Shen_Fan){
//                              dataModel.reportType = 4;
//                        }
//                        dataModel.blocked_Top = model.min + model.startValue;
//                         NSLog(@"average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
//                    }else{
//                         model.blocked_max = max;
//                       if(DEVICETOOL.shenSuo == Shen_Ding){
//                              dataModel.reportType = 4;
//                        }else if(DEVICETOOL.shenSuo == Shen_Fan){
//                              dataModel.reportType = 2;
//                        }
//                        dataModel.blocked_Top = model.max + model.startValue;
//                        NSLog(@"average < 70  model.blockedStable2_OK = YES 反扳定受阻空转生成");
//                    }
//                    long meanAll = 0;
//                    for(NSNumber *num in model.dataBlockArr){
//                        meanAll += num.longValue;
//                    }
//                    meanAll = meanAll/(int)model.dataBlockArr.count;
//
//                    dataModel.blocked_stable = mean;//meanAll + model.startValue;
////                    [[LPDBManager defaultManager] saveModels: @[dataModel]];
//                    [self device:id addReport:dataModel withModel:model];
////                    [self setCheckNilWith:id];
//                    return;
                }else{
                    [model.dataBlockArr addObject:[NSNumber numberWithLong:mean]];
                }
                
            }else{
                if(model.step2_OK){
                    if(!model.stable_1){
                        model.stable_1 = YES;
                        NSLog(@"model.step2_OK model.stable_1 = YES");
                        return;
                    }else if(!model.stable_2){
                        model.stable_2 = YES;
                        NSLog(@"model.step2_OK model.stable_2 = YES");
                        return;
                    }
                    else if(!model.stable_3){
                        model.stable_3 = YES;
                        NSLog(@"三秒平稳期已过 生成报告");
                    }
                    
                    
                    //波动结束
                    NSDate *now = [NSDate date];
                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
                    model.endTime = nowInt;
                    
                    if(model.blockedChange2_OK || model.blockedStable3_OK){
                        NSLog(@"受阻空转后恢复平稳值 清空掉model");
                        [self setCheckNilWith:id];
                        return;
                    }
                    
                    if(!model.blockedStable3_OK){

                                            long allMin = 100000;
                                            long allMax = -100000;
                                            long allSun = 0;
                                            for (NSNumber *number in model.dataArr) {
                                                long num = number.longValue ;
                                                allSun += num;
                                                if(num < allMin){
                                                    allMin = num;
                                                }
                                                if(num > allMax){
                                                    allMax = num;
                                                }
                                            }
                                            long  allMean = (long)allSun/(int)model.dataArr.count;
                                            long openInt = (long)(model.dataArr.count * (1./5.5));
                                            long transformInt = (long)(model.dataArr.count * (3.5/5.5));
                                            long closeInt = model.dataArr.count - openInt - transformInt;
                        
                        if([typeStr isEqualToString:@"J1"]){
                            if(model.dataArr.count < 5.2*50){
//                                [self setCheckNilWith:id];
//                                return;;
                            }else{
                                openInt = (long)(2*50);
                                transformInt = (long)(2.4*50);
                                closeInt = model.dataArr.count - openInt - transformInt;
                            }
                        }else if([typeStr isEqualToString:@"J2"]){
                            if(model.dataArr.count < 5.2*50){
//                                [self setCheckNilWith:id];
//                                return;;
                            }else{
                                openInt = (long)(2.92*50);
                                transformInt = (long)(1.48*50);
                                closeInt = model.dataArr.count - openInt - transformInt;
                            }
                        }
                        else if([typeStr isEqualToString:@"J3"]){
                            if(model.dataArr.count < 5.15*50){
//                                [self setCheckNilWith:id];
//                                return;;
                            }else{
                                openInt = (long)(2.92*50);
                                transformInt = (long)(1.43*50);
                                closeInt = model.dataArr.count - openInt - transformInt;
                                
                                NSLog(@"J3 openInt = %ld,transformInt = %ld,closeInt = %ld",openInt,transformInt,closeInt);
                            }
                        }else if([typeStr isEqualToString:@"X1"]){
                            if(model.dataArr.count < 5.2*50){
//                                [self setCheckNilWith:id];
//                                return;;
                            }else{
                                openInt = (long)(2.1*50);
                                transformInt = (long)(2.2*50);
                                closeInt = model.dataArr.count - openInt - transformInt;
                            }
                        }else if([typeStr isEqualToString:@"X2"]){
                            if(model.dataArr.count < 5.2*50){
//                                [self setCheckNilWith:id];
//                                return;;
                            }else{
                                openInt = (long)(2.9*50);
                                transformInt = (long)(1.4*50);
                                closeInt = model.dataArr.count - openInt - transformInt;
                            }
                        }
                        
                        
                        NSLog(@"分段 dataArr.count = %ld openInt = %ld transformInt=%ld",dataArr.count,openInt,transformInt);
                        NSLog(@"检测到扳动 allMean = %ld allMin = %ld allMax=%ld",allMean,allMin,allMax);
//
//                        long halfMean;
//                        long halfSum = 0;
                        
//                        for(long i =0; i<model.dataArr.count/2;i++){
//                            NSNumber *number = model.dataArr[i];
//                            long num = number.longValue ;
//                            halfSum += num;
//                        }
//                        halfMean = halfSum/(int)model.dataArr.count/2;
//                        if(!model.blockedError){
//                            for(long i =0; i<model.dataArr.count/2;i++){
//                                NSNumber *number = model.dataArr[i];
//                                long num = number.longValue ;
//                                halfSum += num;
//                            }
//                             halfMean = halfSum/(int)model.dataArr.count/2;
//                        }else{
//                            NSLog(@"model.dataArr.coun = %ld",model.dataArr.count);
//                            long aa= 0;
//                            for(NSNumber *number in model.dataArr){
//                                long num = number.longValue ;
//                                if(model.blockedErrorTypeUp) //错误类型上往上突出
//                                {
//                                    if(num < model.startValue){
//                                        halfSum += num;
//                                        aa++;
//                                    }
//                                }else{
//                                    if(num > model.startValue){
//                                        halfSum += num;
//                                        aa++;
//                                    }
//                                }
//                            }
//                            halfMean = (int)halfSum/aa ;
//
//                            if(model.dataArr.count > 50){
//
//                            }else{
//                                if(model.step1_OK){
//                                    NSLog(@"短波动 舍弃掉");
//                                    [self setCheckNilWith:id];
//                                }
//                                return;
//                            }
//                        }
                        
//                                            if(halfMean < model.startValue){
//                                                NSLog(@"检测到定扳反 halfMean=%ld model.startValue = %ld ",halfMean,model.startValue);
//                                                if(allMax - halfMean > 2500){
//                                                    NSLog(@"检测到定扳反 但是halfMean=%ld -平均值>2500，放弃掉 受阻空转后会出现错误曲线",halfMean);
//                                                    [self setCheckNilWith:id];
//                                                    return;
//                                                }
//                                            }else{
//                                                NSLog(@"检测到反扳定 halfMean=%ld model.startValue = %ld ",halfMean,model.startValue);
//                                               if(allMin - halfMean < -2500){
//                                                   NSLog(@"检测到反扳定 但是最小值-平均值<-2500，放弃掉");
//                                                   [self setCheckNilWith:id];
//                                                   return;
//                                               }
//                                            }
                        
                        //转换阻力正常 生成
                       ReportModel *dataModel = [[ReportModel alloc]init];
                                           dataModel.station = DEVICETOOL.stationStr;
                                           dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                                           dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
                                           dataModel.deviceType = typeStr;
                                           long long currentTime = [[NSDate date] timeIntervalSince1970] ;
                                           dataModel.timeLong = currentTime;
                       dataModel.timeLongStr = [NSString stringWithFormat:@"%lld%@转换阻力",currentTime,typeStr];
                                            
                        long openMin = 100000;
                        long openMax = -100000;
                        long openSun = 0;
                        
                        for(long i =0; i<openInt;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            openSun += num;
                            if(num < openMin){
                                openMin = num;
                            }
                            if(num > openMax){
                                openMax = num;
                            }
                        }
                        
                        long  openMean = (long)openSun/openInt;
                        long transformMin = 100000;
                        long transformMax = -100000;
                        //nihaolihaideganhuo
                        long transformSun = 0;
                        for(long i =openInt; i<openInt + transformInt;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            transformSun += num;
                            if(num < transformMin){
                                transformMin = num;
                            }
                            if(num > transformMax){
                                transformMax = num;
                            }
                        }
                        long  transformMean = (long)transformSun/transformInt;
                        
                        long closeMin = 100000;
                        long closeMax = -100000;
                        long closeSun = 0;
                        for(long i =openInt + transformInt; i<model.dataArr.count;i++){
                            NSNumber *number = model.dataArr[i];
                            long num = number.longValue ;
                            closeSun += num;
                            if(num < closeMin){
                                closeMin = num;
                            }
                            if(num > closeMax){
                                closeMax = num;
                            }
                        }
                        long  closeMean = (long)closeSun/closeInt;

                        
                                           if(allMean - model.startValue < 0){
                                               if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                                                     dataModel.reportType = 1;
                                               }else {
                                                     dataModel.reportType = 3;
                                               }
                                               dataModel.all_Top = allMin;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMin;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMin;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMin;
                                               dataModel.close_mean = closeMean;
                                               NSLog(@" 扳动类型%ld allMean= %ld  model.startValue= %ld",dataModel.reportType, allMean,model.startValue);
                                           }else{
                                               if(DEVICETOOL.shenSuo == Shen_Fan || DEVICETOOL.shenSuo == Shen_Fan_zuo){
                                                      dataModel.reportType = 3;
                                               }else {
                                                     dataModel.reportType = 1;
                                               }
                                               dataModel.all_Top = allMax;
                                               dataModel.all_mean = allMean;
                                               
                                               dataModel.open_Top = openMax;
                                               dataModel.open_mean = openMean;
                                               
                                               dataModel.transform_Top = transformMax;
                                               dataModel.transform_mean = transformMean;
                                               
                                               dataModel.close_Top = closeMax;
                                               dataModel.close_mean = closeMean;
                                               
                                               NSLog(@" 扳动类型%ld allMean= %ld  model.startValue= %ld",dataModel.reportType, allMean,model.startValue);
                                           }
                                            
                                            NSLog(@"average < 100  波动结束 !model.blockedStable2_OK  正常阻力转换生");
                        NSLog(@"J3 dataModel.close_Top = %ld,dataModel.close_mean = %ld",dataModel.close_Top,dataModel.close_mean);
//                                           [[LPDBManager defaultManager] saveModels: @[dataModel]];
                                           [self device:id addReport:dataModel withModel:model];
                        [self setCheckNilWith:id];
                        return;
                    }
                }else{
                    if(model.step1_OK){
                        if(!model.stable_1){
                            model.stable_1 = YES;
                        }else if(!model.stable_2){
                            model.stable_2 = YES;
                        }
                        else if(!model.stable_3){
                            model.stable_3 = YES;
                            NSLog(@"小波动 舍弃掉");
                            [self setCheckNilWith:id];
                        }
                    }
                    return;
                }
            }
            
            
            if(!model.step1_OK){
                NSLog(@"检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
                model.startValue = mean + model.startValue;
            }
        }
    }
  });
}
-(void)setCheckNilWith:(NSInteger)id{
                       if(id == 1){
                           DEVICETOOL.checkModel1 = nil;
                       }
                       else if(id == 2){
                           DEVICETOOL.checkModel2 = nil;
                       }
                       if(id == 3){
                           DEVICETOOL.checkModel3 = nil;
                       }
                       else if(id == 11){
                           DEVICETOOL.checkModel4 = nil;
                       }
                       if(id == 12){
                           DEVICETOOL.checkModel4 = nil;
                       }
}
-(void)device:(NSInteger)id addReport:(ReportModel*)report withModel:(CheckModel*)checkModel{
    
//    NSArray *arr ;
//    if(id == 1){
//        arr = [NSArray arrayWithArray:DEVICETOOL.deviceDataArr1];
//    }else if(id == 2){
//        arr = [NSArray arrayWithArray:DEVICETOOL.deviceDataArr2];
//    }
//    else if(id == 3){
//        arr = [NSArray arrayWithArray:DEVICETOOL.deviceDataArr3];
//    }else if(id == 11){
//        arr = [NSArray arrayWithArray:DEVICETOOL.deviceDataArr4];
//    }else if(id == 12){
//        arr = [NSArray arrayWithArray:DEVICETOOL.deviceDataArr5];
//    }
    
   Device *dev;
   NSInteger devID = id;
   if(devID == 12){
          devID = 11;
      }
    for(Device *devi in DEVICETOOL.deviceArr){
        if([devi.id intValue] == devID){
            dev = devi;
            break;
        }
    }
    if(dev){
//        [dev.reportArr addObject:report];
        NSNumber *railType = @(0);
        NSNumber *railType_fan = @(0);
        if(id == 12 || id == 11){
            NSNumber *startT = checkModel.fanTimeArr[0];
            startT = [NSNumber numberWithLongLong:(startT.longLongValue-800)];
            
            NSNumber *endT = checkModel.fanTimeArr.lastObject;
            endT = [NSNumber numberWithLongLong:(endT.longLongValue+500)];
            
            
            if(report.close_fan - report.keep_fan > 3000 || report.close_fan - report.keep_fan < 500){
                railType_fan = @(1);
            }
            if(report.close_fan - report.keep_fan > 3800 || report.close_fan - report.keep_fan < 300){
                railType_fan = @(2);
            }
            [dev.fanColorArr addObject:@[startT,endT,railType_fan]];
            
            NSNumber *startT_Ding = checkModel.timeArr[0];
            startT = [NSNumber numberWithLongLong:(startT_Ding.longLongValue-800)];
            
            NSNumber *endT_Ding = checkModel.timeArr.lastObject;
            endT = [NSNumber numberWithLongLong:(endT_Ding.longLongValue+500)];
            
            
            if(report.close_ding - report.keep_ding > 3000 || report.close_ding - report.keep_ding < 500){
                railType = @(1);
            }
            if(report.close_ding - report.keep_ding > 3800 || report.close_ding - report.keep_ding < 300){
                railType = @(2);
            }

            [dev.colorArr addObject:@[startT,endT,railType]];
            
            if(report.reportType == 5){
                report.warnType = railType_fan.integerValue;
            }else if(report.reportType == 7){
                report.warnType = railType.integerValue;
            }
           
        }else{
            if([dev.typeStr isEqualToString:@"J1"]){
                if(report.reportType == 1 || report.reportType == 3){
                    if(report.all_Top > 1500 || report.all_Top < -1500){
                        railType = @(1);
                    }
                    if(report.all_Top > 1800 || report.all_Top < -1800){
                        railType = @(2);
                    }
                }
                else if(report.reportType == 2 || report.reportType == 4){
                    if(report.blocked_stable < 3500 && report.blocked_stable > -3500){
                        railType = @(1);
                    }
                    if(report.blocked_stable < 3000 && report.blocked_stable > -3000){
                        railType = @(2);
                    }
                }
            }else if([dev.typeStr isEqualToString:@"J2"]){
                if(report.reportType == 1 || report.reportType == 3){
                    if(report.all_Top > 1600 || report.all_Top < -1600){
                        railType = @(1);
                    }
                    if(report.all_Top > 1900 || report.all_Top < -1900){
                        railType = @(2);
                    }
                }
                else if(report.reportType == 2 || report.reportType == 4){
                    if(report.blocked_stable < 3500 && report.blocked_stable > -3500){
                        railType = @(1);
                    }
                    if(report.blocked_stable < 3000 && report.blocked_stable > -3000){
                        railType = @(2);
                    }
                }
            }else if([dev.typeStr isEqualToString:@"J3"]){
                if(report.reportType == 1 || report.reportType == 3){
                    if(report.all_Top > 2100 || report.all_Top < -2100){
                        railType = @(1);
                    }
                    if(report.all_Top > 2450 || report.all_Top < -2450){
                        railType = @(2);
                    }
                }
                else if(report.reportType == 2 || report.reportType == 4){
                    if(report.blocked_stable < 5000 && report.blocked_stable > -5000){
                        railType = @(1);
                    }
                    if(report.blocked_stable < 4400 && report.blocked_stable > -4400){
                        railType = @(2);
                    }
                }
            }else if([dev.typeStr isEqualToString:@"X1"]){
                if(report.reportType == 1 || report.reportType == 3){
                    if(report.all_Top > 1300 || report.all_Top < -1300){
                        railType = @(1);
                    }
                    if(report.all_Top > 1500 || report.all_Top < -1500){
                        railType = @(2);
                    }
                }
                else if(report.reportType == 2 || report.reportType == 4){
                    if(report.blocked_stable < 2800 && report.blocked_stable > -2800){
                        railType = @(1);
                    }
                    if(report.blocked_stable < 2500 && report.blocked_stable > -2500){
                        railType = @(2);
                    }
                }
            }else if([dev.typeStr isEqualToString:@"X2"]){
                if(report.reportType == 1 || report.reportType == 3){
                    if(report.all_Top > 3100 || report.all_Top < -3100){
                        railType = @(1);
                    }
                    if(report.all_Top > 3600 || report.all_Top < -3600){
                        railType = @(2);
                    }
                }
                else if(report.reportType == 2 || report.reportType == 4){
                    if(report.blocked_stable < 6800 && report.blocked_stable > -6800){
                        railType = @(1);
                    }
                    if(report.blocked_stable < 6100 && report.blocked_stable > -6100){
                        railType = @(2);
                    }
                }
            }
            NSNumber *startT = checkModel.timeArr[0];
            startT = [NSNumber numberWithLongLong:(startT.longLongValue)];
            
            NSNumber *endT = checkModel.timeArr.lastObject;
            
            report.transformTime = endT.longLongValue - startT.longLongValue;
            
            long endDelay = 200;
            if(report.reportType == 2 || report.reportType == 4){
                endDelay = 0;
            }
            endT = [NSNumber numberWithLongLong:(endT.longLongValue)];
            [dev.colorArr addObject:@[startT,endT,railType]];
            report.warnType = railType.integerValue;
        }
        NSLog(@"添加报告成功");
        [dev.reportArr addObject:report];
    }
}
-(void)changeDevice:(NSDictionary *)dic{
            DeviceTool *delegate = [DeviceTool shareInstance];
            BOOL isExit = NO;
            for(int a = 0;a<delegate.deviceArr.count;a++){
                Device *device = delegate.deviceArr[a];
                if([device.id isEqualToString:dic[@"id"]]){
                    isExit = YES;
                    break;
                }
            }
            if(!isExit){
                Device *newDevice = [[Device alloc]init];
    //            newDevice.selected = YES;
    //            newDevice.typeNum = dic[@"type"];
                newDevice.version = dic[@"version"];
                newDevice.fitstAdd = YES;
                newDevice.looked = YES;
                newDevice.id = dic[@"id"];
                NSInteger type = [newDevice.id integerValue];
                switch (type) {
//                    case 1:
//                        newDevice.typeStr = delegate.deviceNameArr[0];
//                        break;
//                    case 2:
//                        newDevice.typeStr = delegate.deviceNameArr[1];
//                        break;
//                    case 3:
//                        newDevice.typeStr = delegate.deviceNameArr[2];
//                        break;
                    case 11:
                        newDevice.typeStr = @"定位锁闭力";
                        break;
                    case 12:
                        newDevice.typeStr = @"反位锁闭力";
                        break;
                    default:
                        break;
                }
                [delegate.deviceArr addObject:newDevice];
//                [delegate.deviceArr sortedArrayUsingComparator:^(Device *obj1,Device*obj2){
//                               if([obj1.id integerValue] < [obj2.id integerValue]){
//                                   return NSOrderedAscending;
//                               }else{
//                                   return NSOrderedAscending;
//                               }
//                }];
                NSArray *arr = [delegate.deviceArr sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
                        NSLog(@"%@~%@",obj1,obj2); // 3~4 2~1 3~1 3~2
                    Device* device1 = (Device*)obj1;
                    Device* device2 = (Device*)obj2;
                    NSNumber* dev1Id = [NSNumber numberWithInteger:device1.id.integerValue];
                    NSNumber* dev2Id = [NSNumber numberWithInteger:device2.id.integerValue];
                        return [dev1Id compare:dev2Id]; // 升序
                    }];
                delegate.deviceArr = [NSMutableArray arrayWithArray:arr];
            }
}
-(void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
}

////检测56类型
//-(void)check56Data:(NSArray <NSNumber*>*)dataArr withModel:(CheckModel*)model withTypeStr:(NSString*)typeStr withId:(NSInteger)id withTimeArr:(NSArray*)timeArr{
//
//
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    // 异步执行任务创建方法
//        dispatch_async(queue, ^{
//            if(id == 11){
//                if(dataArr.count > 10){
//                        if(model.startValue == -10000){
//                               long long sum = 0;
//                               for(int i=0 ;i<5;i++){
//                                    NSNumber *number = dataArr[i];  //调试修改
//                                    sum += number.longValue;        //调试修
//                               }
//                               model.startValue = sum/5;
//                               NSLog(@"_Din 前五个数据生成model.startValue = %ld",model.startValue);
//                        }
//
//                        long min = 100000;
//                        long max = -100000;
//                        long sun = 0;
//                        for (NSNumber *number in dataArr) {
//                            long num = number.longValue - model.startValue;
//                            sun += num;
////                            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
//                            if(num < min){
//                                min = num;
//                            }
//                            if(num > max){
//                                max = num;
//                            }
//                        }
//                        if(min < model.min){
//                            model.min = min;
//                        }
//                        if(max > model.max){
//                            model.max = max;
//                        }
//
//                        long mean = sun/(int)dataArr.count;
//
////                        NSLog(@"_Din mean = %ld min = %ld max=%ld",mean,min,max);
//                        long meanSum = 0;
//                        for (NSNumber *number in dataArr ) {
//                            long num = number.longValue - model.startValue;
//                            if((num - mean)>0){
//                                meanSum += (num - mean);
//                            }else{
//                                meanSum += (mean - num);
//                            }
//                        }
//                        long average = meanSum/(int)dataArr.count;
//                        NSLog(@"_Din average = %ld",average);
//                        if(average > 30){
//                            if(average > 600){
////                                if(!model.closeDingChange2_OK){
////                                    //小变化没两秒就急速升高则是受阻空转后错误曲线
////                                    model.blockedError = YES;
////                                    if(mean > 0){
////                                        model.blockedErrorTypeUp = YES;
////                                    }
////                                     NSLog(@"_Din average > 400  model.blockedError = YES");
////                                }else{
//                                    if(!model.blockedChange1_OK){
//                                        model.blockedChange1_OK = YES;
//                                        NSLog(@"_Din average > 600  model.blockedChange_OK = YES");
//                                    }else{
//                                        if(model.blockedStable2_OK){
//                                            if(!model.blockedChange2_OK){
//                                                model.blockedChange2_OK = YES;
//                                                NSLog(@"_Din average > 600  model.blockedChange2_OK = YES");
//                                            }
//                                        }
//                                    }
////                                }
//
//                            }
//                            if(!model.closeDingChange2_OK && average > 100){
//                                NSLog(@"_Din average > 100  model.closeDingChange2_OK = YES");
//                                model.closeDingChange2_OK = YES;
//                            }
//                            if(!model.closeDingChange_OK){
//                                NSLog(@"_Din average > 30  model.closeDingChange_OK = YES");
//                                model.closeDingChange_OK = YES;
//                            }
//                            [model.dataArr addObjectsFromArray:dataArr];
//                            [model.timeArr addObjectsFromArray:timeArr];
//                        }else{
//                            if(mean  > 3500 || mean  < -3500){
//                                [model.dataArr addObjectsFromArray:dataArr];
//                                [model.timeArr addObjectsFromArray:timeArr];
//                                if(!model.blockedStable1_OK){
//                                    model.blockedStable1_OK = YES;
//                                    NSLog(@"_Din average < 30  model.blockedStable1_OK = YES");
//                                }
//                               else if(!model.blockedStable2_OK){
//                                    model.blockedStable2_OK = YES;
//                                    NSLog(@"_Din average < 30  model.blockedStable2_OK = YES");
//                                }
//                                else if(!model.blockedStable3_OK){
//                                    model.blockedStable3_OK = YES;
//                                }
//                                //判断正反锁闭力 是否生成受阻锁闭力报告
//                                if(!model.reportEdDing && model.blockedStable2_OK){
//                                    model.reportEdDing = YES;
//                                    model.reportBlockDing = YES;
//                                    model.dataModel.station = DEVICETOOL.stationStr;
//                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
//                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
//
//                                    model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
//                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
//                                    model.dataModel.timeLong = currentTime;
//                                     model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld",currentTime];
//                                    model.dataModel.reportType = 8;
//
//                                    if(mean < 0){
//                                        model.dataModel.close_ding = model.startValue ;
//                                        model.dataModel.keep_ding = model.startValue  + mean;
//                                         NSLog(@"_Din mean  > 3500 定扳反受阻空转生成");
//                                    }else{
//                                        NSLog(@"_Din mean  > 3500 反扳定受阻空转生成");
//                                        model.dataModel.close_ding = model.startValue + mean;
//                                        model.dataModel.keep_ding = model.startValue;
//                                    }
//                                  }
//                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
//                                     model.reportEd = YES;
//                                     NSLog(@"_Din 锁闭力生成受阻锁闭力曲线报告 暂不清除model");
//                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
//                                     [self device:id addReport:model.dataModel withModel:model];
//                                 }
//                                 return;
//                            }else{
//                                if(model.closeDingChange2_OK){
//                                    //波动结束
//                                    NSDate *now = [NSDate date];
//                                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
//                                    model.endTime = nowInt;
//
////                                    if(model.blockedChange2_OK || model.blockedStable3_OK){
////                                        NSLog(@"受阻空转后恢复平稳值 清空掉model");
////                                        [self setCheckNilWith:id];
////                                        return;
////                                    }
//
//                                    if(!model.blockedStable3_OK){
//
//                                        if(! model.closeDingAfter1_OK){
//                                            model.closeDingAfter1_OK = YES;
//                                            NSLog(@"_Din model.closeDingAfter1_OK = YES");
//                                        }else if( !model.closeDingAfter2_OK){
//                                             model.closeDingAfter2_OK  = YES;
//                                            NSLog(@"_Din model.closeDingAfter2_OK = YES");
//                                        }else if( !model.closeDingAfter3_OK){
//                                             model.closeDingAfter3_OK  = YES;
//                                            NSLog(@"_Din model.closeDingAfter31_OK = YES");
//                                        }
//                                        if(model.dataArr.count < 50){
//                                            if(model.closeDingChange_OK){
//                                                NSLog(@"_Din 短波动 舍弃掉<50");
//                                                [self setCheckNilWith:id];
//                                            }
//                                            return;
//                                        }
//                                                            long allMin = 100000;
//                                                            long allMax = -100000;
//                                                            long allSun = 0;
//                                                            for (NSNumber *number in model.dataArr) {
//                                                                long num = number.longValue ;
//                                                                allSun += num;
//                                                                if(num < allMin){
//                                                                    allMin = num;
//                                                                }
//                                                                if(num > allMax){
//                                                                    allMax = num;
//                                                                }
//                                                            }
//
//                                                            if(allMax - allMin > 3500 || allMax - allMin < -3500){
//                                                                NSLog(@"_Din 检测到allMax - allMin > 3500 || allMax - allMin < -3500 舍弃掉");
//                                                                [self setCheckNilWith:id];
//                                                                return;
//                                                            }
//
//                                                             if(!model.reportEdDing && model.closeDingAfter2_OK){
//
//                                                                model.reportEdDing = YES;
//                                                                model.dataModel.station = DEVICETOOL.stationStr;
//                                                                model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
//                                                                model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
//                                                                model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
//                                                                long long currentTime = [[NSDate date] timeIntervalSince1970] ;
//                                                                model.dataModel.timeLong = currentTime;
//                                                                model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld",currentTime];
//
//                                                                if(mean < 0){
//                                                                    model.dataModel.close_ding = model.startValue ;
//                                                                    model.dataModel.keep_ding = model.startValue + mean;
//                                                                     NSLog(@"_Din  正常定扳反锁闭力生成");
//                                                                    if(model.dataModel.reportType != 6){
//                                                                        model.dataModel.reportType = 5;
//                                                                    }
//                                                                }else{
//                                                                    NSLog(@"_Din  正常反扳定锁闭生成");
//                                                                    model.dataModel.close_ding = model.startValue + mean;
//                                                                    model.dataModel.keep_ding = model.startValue;
//
//                                                                    if(model.dataModel.reportType != 8){
//                                                                        model.dataModel.reportType = 7;
//                                                                    }
//                                                                }
//                                                              }
//                                                             if(model.reportEdFan && model.reportEdDing && !model.reportEd){
//                                                                 model.reportEd = YES;
//                                                                 [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
//                                                                 [self device:id addReport:model.dataModel withModel:model];
//                                                                 NSLog(@"_Din 正常锁闭力曲线报告 ");
//                                                                 if(!model.reportBlockFan){
//                                                                     NSLog(@"_Din 正常锁闭力曲线报告 且清除model");
//                                                                     [self setCheckNilWith:id];
//                                                                 }
//                                                                 return;
//                                                             }
//
//                                    }else{
//                                        NSLog(@"_Din 受阻曲线结束 且清除model");
//                                        [self setCheckNilWith:id];
//                                        return;
//                                    }
//                                }else{
////                                    if(model.closeDingChange_OK){
////                                        NSLog(@"_Din 小波动 舍弃掉");
////                                        [self setCheckNilWith:id];
////                                    }
////                                    return;
//                                }
//                            }
//                            if(!model.closeDingChange_OK){
//                                NSLog(@"_Din 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
//                                model.startValue = mean + model.startValue;
//                            }
//                        }
//                    }
//            }else{
//                if(dataArr.count > 10){
//                        if(model.startValue_Fan == -10000){
//                               long long sum = 0;
//                               for(int i=0 ;i<5;i++){
//                                    NSNumber *number = dataArr[i];  //调试修改
//                                    sum += number.longValue;        //调试修
//                               }
//                               model.startValue_Fan = sum/5;
//                               NSLog(@"_Fan 前五个数据生成model.startValue = %ld",model.startValue_Fan);
//                        }
//
//                        long min = 100000;
//                        long max = -100000;
//                        long sun = 0;
//                        for (NSNumber *number in dataArr) {
//                            long num = number.longValue - model.startValue_Fan;
//                            sun += num;
//                //            NSLog(@" number = %ld num = %ld sun = %ld",number.longValue,num,sun);
//                            if(num < min){
//                                min = num;
//                            }
//                            if(num > max){
//                                max = num;
//                            }
//                        }
//                        if(min < model.min_Fan){
//                            model.min_Fan = min;
//                        }
//                        if(max > model.max_Fan){
//                            model.max_Fan = max;
//                        }
//
//                        long mean = sun/(int)dataArr.count;
//
//                        NSLog(@"_Fan mean = %ld min = %ld max=%ld",mean,min,max);
//                        long meanSum = 0;
//                        for (NSNumber *number in dataArr ) {
//                            long num = number.longValue - model.startValue_Fan;
//                            if((num - mean)>0){
//                                meanSum += (num - mean);
//                            }else{
//                                meanSum += (mean - num);
//                            }
//                        }
//                        long average = meanSum/(int)dataArr.count;
//                        NSLog(@"_Fan average = %ld",average);
//                        if(average > 30){
//                            if(average > 600){
////                                if(!model.closeFanChange2_OK){
////                                    //小变化没两秒就急速升高则是受阻空转后错误曲线
////                                    model.blockedError_Fan = YES;
////                                    if(mean > 0){
////                                        model.blockedErrorTypeUp_Fan = YES;
////                                    }
////                                     NSLog(@"_Fan average > 400  model.blockedError = YES");
////                                }else{
//                                    if(!model.blockedChange1_OK_Fan){
//                                        model.blockedChange1_OK_Fan = YES;
//                                        NSLog(@"_Fan average > 400  model.blockedChange_OK = YES");
//                                    }else{
//                                        if(model.blockedStable2_OK_Fan){
//                                            model.blockedChange2_OK_Fan = YES;
//                                             NSLog(@"_Fan average > 400  model.blockedChange2_OK = YES");
//                                        }
//                                    }
////                                }
//
//                            }
//                            if(!model.closeFanChange2_OK &&  average > 100){
//                                model.closeFanChange2_OK = YES;
//                            }
//                            else{
//
//                            }
//                            if(!model.closeFanChange_OK){
//                                NSLog(@"_Fan average > 400  model.closeFanChange_OK = YES");
//                                model.closeFanChange_OK = YES;
//                            }
//                            [model.dataArr_Fan addObjectsFromArray:dataArr];
//                            [model.fanTimeArr addObjectsFromArray:timeArr];
//                        }else{
//                            if(mean  > 3500 || mean  < -3500){
//                                [model.dataArr_Fan addObjectsFromArray:dataArr];
//                                [model.fanTimeArr addObjectsFromArray:timeArr];
//                                if(!model.blockedStable1_OK_Fan){
//                                    model.blockedStable1_OK_Fan = YES;
//                                    NSLog(@"_Fan average < 70  model.blockedStable1_OK = YES");
//                                }
//                                else if(!model.blockedStable2_OK_Fan){
//                                    model.blockedStable2_OK_Fan = YES;
//                                    NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES");
//                                }
//                                else if(!model.blockedStable3_OK_Fan){
//
//                                    model.blockedStable3_OK_Fan = YES;
//                                }
//                                //判断正反锁闭力 是否生成受阻锁闭力报告
//                                if(!model.reportEdFan && model.blockedStable2_OK_Fan){
//                                    model.reportEdFan = YES;
//                                    model.reportBlockFan = YES;
//                                    model.dataModel.station = DEVICETOOL.stationStr;
//                                    model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
//                                    model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
//                                    model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
//                                    long long currentTime = [[NSDate date] timeIntervalSince1970] ;
//                                    model.dataModel.timeLong = currentTime;
//                                    model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld",currentTime];
//                                      model.dataModel.reportType = 6;
//                                    if(mean < 0){
//                                        model.dataModel.close_fan = model.startValue_Fan ;
//                                        model.dataModel.keep_fan = model.startValue_Fan  + mean;
//                                         NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
//
//                                    }else{
//                                        NSLog(@"_Fan average < 70  model.blockedStable2_OK = YES 定扳反受阻空转生成");
//
//                                        model.dataModel.close_fan = model.startValue_Fan + mean;
//                                        model.dataModel.keep_fan = model.startValue_Fan;
//                                    }
//                                  }
//                                 if(model.reportEdFan && model.reportEdDing && !model.reportEd){
//                                     model.reportEd = YES;
//                                     NSLog(@"_Fan 锁闭力生成受阻锁闭力曲线报告 暂不清除model");
//                                     [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
//                                     [self device:id addReport:model.dataModel withModel:model];
//                                 }
//                                 return;
//                            }else{
//                                if(model.closeFanChange2_OK){
//                                    //波动结束
//                                    NSDate *now = [NSDate date];
//                                    NSTimeInterval nowInt = [now timeIntervalSince1970 ];
//                                    model.endTime = nowInt;
//
//                                    if(model.blockedChange2_OK_Fan || model.blockedStable3_OK_Fan){
//                                        NSLog(@"_Fan 受阻空转后恢复平稳值 清空掉model");
//                                        [self setCheckNilWith:id];
//                                        return;
//                                    }
//
//                                    if(!model.blockedStable3_OK_Fan){
//
//                                        if(! model.closeFanAfter1_OK){
//                                            model.closeFanAfter1_OK = YES;
//                                        }else if(! model.closeFanAfter2_OK){
//                                             model.closeFanAfter2_OK  = YES;
//                                        }else if(! model.closeFanAfter3_OK){
//                                             model.closeFanAfter3_OK  = YES;
//                                        }
//                                        if(model.dataArr_Fan.count < 50){
//                                            if(model.closeFanChange_OK){
//                                                NSLog(@"_Fan 短波动 舍弃掉");
//                                                [self setCheckNilWith:id];
//                                            }
//                                            return;
//                                        }
//                                                            long allMin = 100000;
//                                                            long allMax = -100000;
//                                                            long allSun = 0;
//                                                            for (NSNumber *number in model.dataArr_Fan) {
//                                                                long num = number.longValue ;
//                                                                allSun += num;
//                                                                if(num < allMin){
//                                                                    allMin = num;
//                                                                }
//                                                                if(num > allMax){
//                                                                    allMax = num;
//                                                                }
//                                                            }
//
//                                                            if(allMax - allMin > 3500 || allMax - allMin < -3500){
//                                                                NSLog(@"_Fan 检测到allMax - allMin > 2500 || allMax - allMin < -2500 舍弃掉");
//                                                                [self setCheckNilWith:id];
//                                                                return;
//                                                            }
//
//                                                             if(!model.reportEdFan && model.closeFanAfter2_OK){
//
//                                                                model.reportEdFan = YES;
//                                                                model.dataModel.station = DEVICETOOL.stationStr;
//                                                                model.dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
//                                                                model.dataModel.idStr = [NSString stringWithFormat:@"%lld%@",DEVICETOOL.startTime,typeStr];
//                                                                model.dataModel.deviceType = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,typeStr];
//                                                                long long currentTime = [[NSDate date] timeIntervalSince1970] ;
//                                                                model.dataModel.timeLong = currentTime;
//                                                                model.dataModel.timeLongStr = [NSString stringWithFormat:@"%lld",currentTime];
//
//                                                                if(mean < 0){
//                                                                    model.dataModel.close_fan = model.startValue_Fan ;
//                                                                    model.dataModel.keep_fan = model.startValue_Fan + mean;
//                                                                     NSLog(@"_Fan 正常反扳定锁闭力生成");
//                                                                     if(model.dataModel.reportType != 8){
//                                                                         model.dataModel.reportType = 7;
//                                                                     }
//                                                                }else{
//                                                                    NSLog(@" _Fan 正常定扳反锁闭生成");
//                                                                    if(model.dataModel.reportType != 6){
//                                                                        model.dataModel.reportType = 5;
//                                                                    }
//                                                                    model.dataModel.close_fan = model.startValue_Fan + mean;
//                                                                    model.dataModel.keep_fan = model.startValue_Fan;
//                                                                }
//                                                              }
//                                                             if(model.reportEdFan && model.reportEdDing && !model.reportEd){
//                                                                 model.reportEd = YES;
//                                                                 [[LPDBManager defaultManager] saveModels: @[model.dataModel]];
//                                                                 [self device:id addReport:model.dataModel withModel:model];
//                                                                 NSLog(@"_Fan 正常锁闭力曲线报告 ");
//                                                                 if(!model.reportBlockDing){
//                                                                     NSLog(@"_Fan 正常锁闭力曲线报告 且清除model");
//                                                                     [self setCheckNilWith:id];
//                                                                 }
//                                                                 return;
//                                                             }
//
//                                    }else{
//                                        NSLog(@"_Fan 受阻曲线结束 且清除model");
//                                        [self setCheckNilWith:id];
//                                        return;
//                                    }
//                                }else{
////                                    if(model.closeFanChange_OK){
////                                        NSLog(@"_Fan小波动 舍弃掉");
////                                        [self setCheckNilWith:id];
////                                    }
////                                    return;
//                                }
//                            }
//                            if(!model.closeFanChange_OK){
//                                NSLog(@"_Fan 检测 重置初始值 !model.step1_OK model.startValue = %ld",mean);
//                                model.startValue_Fan = mean + model.startValue_Fan;
//                            }
//                        }
//                    }
//            }
//        });
//};
@end

