//
//  DeviceTool.h
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckModel.h"
#import "Device.h"
typedef enum:NSInteger{
    TestNotStart,
    TestStarted,
    TestStoped,
    TestEnd,
}CSQTestStatus;
typedef enum:NSInteger{
    J,
    X,
}CSQJOrX;
typedef enum:NSInteger{
    ONE,
    TWO,
}CSQSeleLook;
typedef enum:NSInteger{
    NoSet,
    Shen_Ding,
    Shen_Fan,
    Shen_Ding_zuo,
    Shen_Fan_zuo,
}CSQShenSuo;
typedef enum:NSInteger{
    ZhuoYou_NoSet,
    ZhuoYou_You,
    ZhuoYou_Zuo,
}CSQZuoYou;
NS_ASSUME_NONNULL_BEGIN
static NSString *blueColor = @"black";   // 其他曲线     #4B8CF5 红色 #E71D1C  黑色
static NSString *redColor = @"#4B8CF5";   //报告曲线   黑色
//static NSString *realRedColor = @"#E71D1C";   //报告曲线2   红色
static NSString *dinColor = @"#5470C6";   //报告曲线                    转换阻力
static NSString *fanColor = @"#91CC75";   //报告曲线    91CC75  B2A741  锁闭力定位
static NSString *close_transform_color = @"#FFFF00";   //报告曲线       锁闭力反位  FFFF00  FAC858

static NSString *organiColor = @"#FF8C00";   //报警颜色  橙色    FFA500  9C3A17

//static NSString *fan_organiColor = @"#AF6A32";   //报警颜色  橙色
static NSString *realRedColor = @"#E71D1C";   //报警颜色  红色
@interface DeviceTool : NSObject
+(DeviceTool*)shareInstance;
@property(nonatomic,strong)NSMutableArray *deviceArr;
@property(nonatomic,copy)NSString *roadSwitchNo;
@property(nonatomic,strong)NSMutableArray *roadSwitchNoArr;
@property(nonatomic,copy)NSString *stationStr;
@property(nonatomic,copy)NSString *closeLinkDevice;
@property(nonatomic,copy)NSString *nameStr;
@property(nonatomic,copy)NSString *tianqiStr;
@property(nonatomic,copy)NSString *wenduStr;

@property(nonatomic,strong)NSMutableArray *stationStrArr;
@property(nonatomic,assign)long long saveStaionTime;
@property(nonatomic,assign)long long startTime;
@property(nonatomic,strong)NSMutableArray *deviceDataArr1;
@property(nonatomic,strong)NSMutableArray *deviceDataArr2;
@property(nonatomic,strong)NSMutableArray *deviceDataArr3;
@property(nonatomic,strong)NSMutableArray *deviceDataArr4;
@property(nonatomic,strong)NSMutableArray *deviceDataArr5;
@property(nonatomic,strong)NSArray *deviceNameArr;
@property (nonatomic,assign)CSQTestStatus testStatus;
@property (nonatomic,assign)CSQSeleLook seleLook;
@property (nonatomic,assign)CSQJOrX jOrX;
@property (nonatomic,assign)CSQShenSuo shenSuo;
@property (nonatomic,assign)CSQZuoYou zuoyou;
@property(nonatomic,strong)NSMutableArray *savedStationArr;
@property(nonatomic,strong,nullable)CheckModel*checkModel1;
@property(nonatomic,strong,nullable)CheckModel*checkModel2;
@property(nonatomic,strong,nullable)CheckModel*checkModel3;
@property(nonatomic,strong,nullable)CheckModel*checkModel4;
@property(nonatomic,strong,nullable)CheckModel*checkModel5;

@property (nonatomic,assign)BOOL  isDebug;
@property (nonatomic,assign)BOOL  isX3;
@property (nonatomic,assign)BOOL  timeOk;
@property (nonatomic,assign)BOOL  isWIFIConnection;
@property  (nonatomic,assign)NSInteger reportSele1;
@property  (nonatomic,assign)NSInteger reportSele2;
@property  (nonatomic,assign)NSInteger reportSele3;
@property  (nonatomic,assign)NSInteger reportSele4;

@property  (nonatomic,assign)NSInteger testMaxCount;
-(void)syncArr;
-(void)removeAllData;
-(void)getSavedStationArr;

-(void)changeReport:(PYOption *)option reportArr:(NSArray*)device maxCount:(int)maxCount;
-(void)changeReport2:(PYOption *)option reportArr:(NSArray*)device maxCount:(int)maxCount reportSele:(NSInteger)reportSele;

-(NSString *)getLinkDevice;
@end

NS_ASSUME_NONNULL_END
