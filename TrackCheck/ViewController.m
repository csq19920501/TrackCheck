//
//  ViewController.m
//  TrackCheck
//
//  Created by ethome on 2021/1/6.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "ViewController.h"
#import "RMMapper.h"
#import "iOS-Echarts.h"
#import "PYEchartsView.h"
#import "PYZoomEchartsView.h"
#import "WKEchartsView.h"
#import "PYDemoOptions.h"
#import "CSQScoketService.h"
#import "Device.h"
#import "SetAddressViewController.h"
#import "SceneDelegate.h"
#import "TestDataModel.h"
#import "ReportModel.h"
#import "TYAlertController.h"
#import "HistoryDataViewController.h"
#import "ReportCell.h"
#import "CSQVisualMap.h"
#import "DLCustomAlertController.h"
#import "DLDateAnimation.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView1;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView2;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView3;
@property (weak, nonatomic) IBOutlet PYZoomEchartsView *kEchartView4;
@property (weak, nonatomic) IBOutlet UIView *chartViewBackV;

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *threeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarItem;
@property (weak, nonatomic) IBOutlet UIButton *changeBut;
@property (weak, nonatomic) IBOutlet UIButton *startBut;
@property (weak, nonatomic) IBOutlet UIButton *endBut;
@property (nonatomic,strong)NSMutableArray *seleJJJArr;
@property (nonatomic ,strong)NSTimer *timer;
@property (nonatomic ,assign)long long startTime;
@property (weak, nonatomic) IBOutlet UILabel *testTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveBut;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *X3But;
//@property (weak, nonatomic) IBOutlet UITableView *reoprtTableV;
//@property (weak, nonatomic) IBOutlet UITableView *reportTableV1;

@property (strong,nonatomic) UIImagePickerController* pickController;

@property (nonatomic,assign)NSInteger textCount;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _textCount = 0;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceChange) name:DEVICECHANGE object:nil];
    _seleJJJArr = [NSMutableArray array];

    if(![[DeviceTool shareInstance].roadSwitchNo containsString:@"道岔"]){
        self.leftBarItem.title = [NSString stringWithFormat:@"%@%@道岔",[DeviceTool shareInstance].stationStr,[DeviceTool shareInstance].roadSwitchNo];
    }else{
        self.leftBarItem.title = [NSString stringWithFormat:@"%@%@",[DeviceTool shareInstance].stationStr,[DeviceTool shareInstance].roadSwitchNo];
    }
    
    DEVICETOOL.testStatus = TestNotStart;
    
    NSArray *butArr2 = @[_changeBut,_startBut,_endBut,_saveBut];
    for (UIButton *but in butArr2) {
        but.layer.masksToBounds = YES;
        but.layer.cornerRadius = 16;
    }
    UIButton *camearBut = (UIButton*)[self.view viewWithTag:107];
    camearBut.layer.masksToBounds = YES;
    camearBut.layer.cornerRadius = 16;
    
    _endBut.enabled = NO;
    _endBut.alpha = 0.35;
    _saveBut.enabled = NO;
    _saveBut.alpha = 0.35;
    
    NSArray *butArr = @[_firstButton,_secondButton,_threeButton];
    for (UIButton *but in butArr) {
        but.layer.masksToBounds = YES;
        but.layer.borderColor = BLUECOLOR.CGColor;
        but.layer.borderWidth = 2;
        but.layer.cornerRadius = 10;
    }
    
     [self initView];
    
    if(DEVICETOOL.isX3){
        self.X3But.title = @"X3";
    }else{
        self.X3But.title = @"X1";
    }
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.backBarButtonItem = backItem;
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAppDidBackGround) name:UIApplicationDidEnterBackgroundNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (IBAction)相机:(id)sender {
//    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.pickController = [[UIImagePickerController alloc]init];
        self.pickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.pickController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//@[@"public.image"]; 
        self.pickController.delegate = self;         //代理设置
        self.pickController.allowsEditing = NO;      //是否提供编辑交互界面 比如说拍完照之后的编辑页面(缩放,剪裁等)
        //使用内置编辑控件时，图像选择器控制器会强制执行某些选项。对于照片，强制执行方形裁剪以及最大像素尺寸。对于视频，选择器强制执行最大电影长度和分辨率。如果要让用户指定自定义裁剪，则必须提供自己的编辑UI。
//        self.pickController.showsCameraControls = YES;//是否显示相机控制按钮
//        self.pickController.cameraOverlayView = self.cameraOverLayView; //自定义相机控制页面
     //如果不需要自定义控制页面可以省略上面两行
     //设置闪光灯模式
       self.pickController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
       [self presentViewController:_pickController animated:YES completion:nil];
        /*
         typedef NS_ENUM(NSInteger, UIImagePickerControllerCameraFlashMode) {
         UIImagePickerControllerCameraFlashModeOff  = -1,
         UIImagePickerControllerCameraFlashModeAuto = 0,
         UIImagePickerControllerCameraFlashModeOn   = 1
         }
         */
    }else{
        [HUD showAlertWithText:@"请查看相机权限"];
        return;
    }
}
//结束采集之后 之后怎么处理都在这里写 通过Infokey取出相应的信息  Infokey可在进入文件中查看
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info{

    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        
            __block NSString * mediaType = [info objectForKey:UIImagePickerControllerMediaType];
            NSLog(@"info = %@",info);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                      dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
            
        
        
        NSMutableArray *typeArr = [NSMutableArray array];
        for (Device *device in DEVICETOOL.deviceArr) {
            if(device.selected){
                [typeArr addObject:device.typeStr];
            }
        }
        __block NSString *saveDeviceType = @"";
        DLCustomAlertController *customAlertC = [[DLCustomAlertController alloc] init];
        customAlertC.title = @"选择关联设备";
        customAlertC.pickerDatas = @[typeArr];//arr;
        DLDateAnimation * animation = [[DLDateAnimation alloc] init];
        customAlertC.selectValues = ^(NSArray * _Nonnull dateArray){
            if(dateArray.count > 0){
                saveDeviceType = dateArray[0] ;
                if ([mediaType isEqualToString:@"public.image"]) {//照片
                //        UIImage* editedImage =(UIImage *)[info objectForKey:
                //                    UIImagePickerControllerEditedImage]; //取出编辑过的照片
                        UIImage* originalImage =(UIImage *)[info objectForKey:
                                    UIImagePickerControllerOriginalImage];//取出原生照片
                        UIImage* imageToSave = nil;
                //        if(editedImage){
                //            imageToSave = editedImage;
                //        } else {
                            imageToSave = originalImage;
                //        }
                    //将新图像（原始图像或已编辑）保存到相机胶卷
                        UIImageWriteToSavedPhotosAlbum(imageToSave,nil,nil,nil);
                        NSString *filename = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@.jpg",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo,saveDeviceType,timeStr]];
                        NSData *data = UIImagePNGRepresentation(imageToSave);
                        [data writeToFile:filename atomically:YES];
                    }
                    else if ([mediaType isEqualToString:@"public.movie"]) {//视频 UIImagePickerControllerMediaURL}
                        NSString * mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
                        NSData * data = [NSData dataWithContentsOfFile:mediaURL];
                        
                        NSString *filename = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@_%@_%@.mov",DEVICETOOL.stationStr,DEVICETOOL.roadSwitchNo,saveDeviceType,timeStr]];
                        [data writeToFile:filename atomically:YES];
                    }
                 [HUD showAlertWithText:@"保存成功，可在系统文件app内查看"];
            }
        };
        [weakSelf presentViewController:customAlertC animation:animation completion:nil];
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)appBecomeActive{
 
//    AppDelegate *delete =  (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [delete preSocke];
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)handleAppDidBackGround{
    if (DEVICETOOL.testStatus == TestStarted){
        [_startBut setTitle:@"开始" forState:UIControlStateNormal];
        [[CSQScoketService shareInstance]stopSample];
        DEVICETOOL.testStatus = TestStoped;
        NSLog(@"scene 监听到退到后台自动暂停");
    }
}
- (IBAction)X3click:(id)sender {
    return;
    if([_X3But.title isEqualToString:@"X1"]){
        [_X3But setTitle:@"X3"];
        DEVICETOOL.isX3 = YES;
    }else{
        [_X3But setTitle:@"X1"];
        DEVICETOOL.isX3 = NO;
    }
}
-(void)initView{
    NSArray *butArr = @[_firstButton,_secondButton,_threeButton];
    for (UIButton *but in butArr) {
        but.hidden = YES;
        but.selected = NO;
    }
    if(DEVICETOOL.seleLook == ONE){
        [_seleJJJArr removeAllObjects];
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if(device.selected && [device.id intValue] <=3 ){
                [_seleJJJArr addObject:device];
            }
        }
//        NSArray *arr = [_seleJJJArr sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
//                NSLog(@"%@~%@",obj1,obj2); // 3~4 2~1 3~1 3~2
//            Device* device1 = (Device*)obj1;
//            Device* device2 = (Device*)obj2;
//            NSNumber* dev1Id = [NSNumber numberWithInteger:device1.id.integerValue];
//            NSNumber* dev2Id = [NSNumber numberWithInteger:device2.id.integerValue];
//                return [dev1Id compare:dev2Id]; // 升序
//            }];
//        _seleJJJArr = [NSMutableArray arrayWithArray:arr];
        
        for (int i = 0 ; i < _seleJJJArr.count; i++) {
            Device *device = _seleJJJArr[i];
            UIButton * but ;
            if(i == 0){
                but = _firstButton;
            }else if(i == 1){
                but = _secondButton;
            }else if(i == 2){
                but = _threeButton;
            }
            but.hidden = NO;
            [but setTitle:device.typeStr forState:UIControlStateNormal];
            
            if(device.looked){
                but.selected = YES;
            }else{
                but.selected = NO;
            }
        }
        _kEchartView1.hidden = !_firstButton.selected;
        _kEchartView2.hidden = !_secondButton.selected;
        _kEchartView3.hidden = !_threeButton.selected;
        
        if(!_kEchartView1.hidden ){
            [_kEchartView1 setOption:[self irregularLine2Option:0 withSample:@"lttb"]];
            [_kEchartView1 loadEcharts];
        }
        if(!_kEchartView2.hidden ){
            [_kEchartView2 setOption:[self irregularLine2Option:1 withSample:@"lttb"]];
                   [_kEchartView2 loadEcharts];
               }
        if(!_kEchartView3.hidden){
            [_kEchartView3 setOption:[self irregularLine2Option:2 withSample:@"lttb"]];
            [_kEchartView3 loadEcharts];
        }
         _chartViewBackV.hidden = YES;
        self.title = @"阻力转换测试";
    }else{
        _firstButton.hidden = YES;
        _secondButton.hidden = YES;
        _threeButton.hidden = YES;
        _chartViewBackV.hidden  = NO;
        [_kEchartView4 setOption:[self getOptionWith:@"lttb"]];
        [_kEchartView4 loadEcharts];
//        [_kEchartView4 refreshEchartsWithOption:[self getOption]];
        self.title = [NSString stringWithFormat:@"%@-%@",DEVICETOOL.closeLinkDevice,@"锁闭力测试"];;
        
        [_seleJJJArr removeAllObjects];
        for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
            Device *device = DEVICETOOL.deviceArr[i];
            if(device.selected  ){
                if([device.id isEqualToString:@"11"] || [device.id isEqualToString:@"12"] || [device.id isEqualToString:[DEVICETOOL getLinkDevice]]){
                    [_seleJJJArr addObject:device];
                }
            }
        }
        for (int i = 0 ; i < _seleJJJArr.count; i++) {
            Device *device = _seleJJJArr[i];
            UIButton * but ;
            if(i == 0){
                but = _firstButton;
            }else if(i == 1){
                but = _secondButton;
            }else if(i == 2){
                but = _threeButton;
            }
            but.hidden = NO;
           
            if([device.id isEqualToString:@"11"]){
                 [but setTitle:@"定位" forState:UIControlStateNormal];
            }else if([device.id isEqualToString:@"11"]){
                 [but setTitle:@"反位" forState:UIControlStateNormal];
            }else{
                 [but setTitle:device.typeStr forState:UIControlStateNormal];
            }
            
            if(device.looked){
                but.selected = YES;
            }else{
                but.selected = NO;
            }
        }
        
    }
}
-(void)viewDidLayoutSubviews{
  // 先执行这个，才执行子页面的layoutSubviews
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeView) userInfo:nil repeats:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportClick:) name:@"reportClick" object:nil];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}
- (void)reportClick:(NSNotification *)sender{
    NSDictionary *userInfo = sender.userInfo;
    
}
- (IBAction)clickLeft:(id)sender {
    
    if(DEVICETOOL.testStatus == TestStarted){
        [HUD showAlertWithText: @"测试中，不能修改测试地址"];
    }else{
            __weak typeof(self) weakSelf = self;
            TYAlertView *alertView = [TYAlertView alertViewWithTitle:@"提示" message:@"是否确定修改测试地址"];
            
            TYAlertController * alertController = [TYAlertController alertControllerWithAlertView:alertView preferredStyle:TYAlertControllerStyleAlert];
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"取消" style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alertController dismissViewControllerAnimated:YES];

                });
            }]];
            
            // 弱引用alertView 否则 会循环引用
            __typeof (alertView) __weak weakAlertView = alertView;
            
            [alertView addAction:[TYAlertAction actionWithTitle:@"确定" style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
                
                UITextField *textField = [weakAlertView.textFieldArray firstObject];
                
                [textField resignFirstResponder];
                [alertController dismissViewControllerAnimated:YES];
                
                      for (int i =0; i < DEVICETOOL.deviceArr.count; i++) {
                           Device *device = DEVICETOOL.deviceArr[i];
                           device.selected = NO;
                       }
                       [DEVICETOOL removeAllData];
                       [weakSelf.seleJJJArr removeAllObjects];
                       
                       [self viewWillDisappear:YES];//不会自动调用此方法
                
                       if([self.navigationController.childViewControllers[0] isKindOfClass:[SetAddressViewController class]]){
                           [self.navigationController popToRootViewControllerAnimated:YES];
                       }else{
                           UIWindow*  window;
                           if (@available(iOS 13.0, *)) {
                             window = [UIApplication sharedApplication].windows[0];
                               
                               NSArray *array =[[[UIApplication sharedApplication] connectedScenes] allObjects];
                               UIWindowScene* windowScene = (UIWindowScene*)array[0];
                               SceneDelegate * delegate = (SceneDelegate *)windowScene.delegate;
                               window = delegate.window;

                           } else {
                             window = [UIApplication sharedApplication].delegate.window;
                           }
                           SetAddressViewController *VC= [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SetAddressViewController"];
                           UKNavigationViewController *nav = [[UKNavigationViewController alloc]initWithRootViewController:VC];
                           [window setRootViewController:nav];
                       }
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (IBAction)signmentChange:(id)sender {
    UISegmentedControl   *control = sender;
    NSLog(@"control.selectedSegmentIndex = %ld",(long)control.selectedSegmentIndex);
    if(control.selectedSegmentIndex == 0){
        _chartViewBackV.hidden = YES;
        for (int i = 0 ; i < _seleJJJArr.count; i++) {
            UIButton * but ;
            if(i == 0){
                but = _firstButton;
            }else if(i == 1){
                but = _secondButton;
            }else if(i == 2){
                but = _threeButton;
            }
            but.hidden = NO;
        }
    }else{
        _firstButton.hidden = YES;
        _secondButton.hidden = YES;
        _threeButton.hidden = YES;
        _chartViewBackV.hidden  = NO;
        [_kEchartView4 refreshEchartsWithOption:[self getOptionWith:@"lttb"]];
    }
}
- (IBAction)startTest:(id)sender {
    if(DEVICETOOL.testStatus == TestNotStart || DEVICETOOL.testStatus == TestEnd){
        _startTime = [[NSDate date] timeIntervalSince1970];
        DEVICETOOL.startTime = _startTime;
        _textCount = 0;
        
//        _startBut.enabled = NO;
//        _startBut.alpha = 0.35;
        _changeBut.enabled = NO;
        _changeBut.alpha = 0.35;
        
        _saveBut.enabled = NO;
        _saveBut.alpha = 0.35;
        
        _endBut.enabled = YES;
        _endBut.alpha = 1;
        
        _testTimeLabel.text = @"00:00";
        
        DEVICETOOL.testStatus = TestStarted;
        [DEVICETOOL removeAllData];
        if(DEVICETOOL.isDebug){
            if(DEVICETOOL.seleLook == ONE){
                [[CSQScoketService shareInstance]test1234_];
            }else{
                [[CSQScoketService shareInstance]test1234];
            }
        }
        [_startBut setTitle:@"暂停" forState:UIControlStateNormal];
        
        [[CSQScoketService shareInstance]startSample];
    }else if (DEVICETOOL.testStatus == TestStarted){
        [_startBut setTitle:@"开始" forState:UIControlStateNormal];
        [[CSQScoketService shareInstance]stopSample];
        DEVICETOOL.testStatus = TestStoped;
        [self changeEchartNOSample];
    }else if (DEVICETOOL.testStatus == TestStoped){
        [_startBut setTitle:@"暂停" forState:UIControlStateNormal];
        DEVICETOOL.testStatus = TestStarted;
        [[CSQScoketService shareInstance]startSample];
    }

}
- (IBAction)endTest:(id)sender {
    DEVICETOOL.testStatus = TestEnd;
    
     [[CSQScoketService shareInstance]stopTest1234];
    
    _startBut.enabled = YES;
    _startBut.alpha = 1;
    _changeBut.enabled = YES;
    _changeBut.alpha = 1;
    
    _endBut.enabled = NO;
    _endBut.alpha = 0.35;
    
    _saveBut.enabled = YES;
    _saveBut.alpha = 1;
    //保存数据
    
    [_startBut setTitle:@"开始" forState:UIControlStateNormal];
    [[CSQScoketService shareInstance]stopSample];
    [self changeEchartNOSample];
}
-(void)changeEchartNOSample{
    if(self.chartViewBackV.hidden){
            if(!self.kEchartView1.hidden ){

                    [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0 withSample:@""]];
            }
            if(!self.kEchartView2.hidden ){

                    [_kEchartView2 refreshEchartsWithOption:[self irregularLine2Option:1 withSample:@""]];
                
            }
            if(!self.kEchartView3.hidden){
                    [_kEchartView3 refreshEchartsWithOption:[self irregularLine2Option:2 withSample:@""]];
            }
    }else{
            [_kEchartView4 refreshEchartsWithOption:[self getOptionWith:@""]];
    }
}
- (IBAction)changeTest:(id)sender {
    if(_saveBut.enabled){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未保存当前测试数据，若继续切换测试设备则放弃保存" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [DEVICETOOL removeAllData];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:otherAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [DEVICETOOL removeAllData];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)saveClick:(id)sender {
    _saveBut.enabled = NO;
    _saveBut.alpha = 0.35;
    
    if(DEVICETOOL.seleLook == ONE){
        NSMutableArray * saveArray = [NSMutableArray array];
        for (Device *device in DEVICETOOL.deviceArr) {
            if(device.selected ){
                        TestDataModel *dataModel = [[TestDataModel alloc]init];
                        dataModel.station = DEVICETOOL.stationStr;
                        dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
                        dataModel.idStr = [NSString stringWithFormat:@"%lld%@",_startTime,device.typeStr];
                        
                        NSMutableArray *dataArray ;
                        switch ([device.id intValue]) {
                            case 1:
                                dataArray = DEVICETOOL.deviceDataArr1;
                                break;
                                case 2:
                                dataArray = DEVICETOOL.deviceDataArr2;
                                break;
                                case 3:
                                dataArray = DEVICETOOL.deviceDataArr3;
                                break;
                                
                            default:
                                break;
                        }
                        dataModel.dataArr = dataArray;
                        dataModel.deviceType = device.typeStr;
                        dataModel.colorArr = device.colorArr;
//                        dataModel.fanColorArr = device.fanColorArr;
                        long long currentTime = [[NSDate date] timeIntervalSince1970];
                        dataModel.timeLong = currentTime;
                   
                        NSArray *dictArray = [ReportModel mj_keyValuesArrayWithObjectArray:device.reportArr];
                        dataModel.reportArr = [NSMutableArray arrayWithArray:dictArray];
                        [[LPDBManager defaultManager] saveModels: device.reportArr];
                        [saveArray addObject:dataModel];
                        
            }
        }
        [[LPDBManager defaultManager] saveModels: saveArray];
    }else{
        if(DEVICETOOL.deviceDataArr4.count >0 || DEVICETOOL.deviceDataArr5.count >0){
            Device *testDevice;  //锁闭力
            Device *deviceChange; //对应的转换阻力
            NSMutableArray *saveDataArr3;
                              for(Device *dev in DEVICETOOL.deviceArr){
                                   if([dev.id intValue] == 11 ){
                                       testDevice = dev; break;
                                   }
                               }
            if([DEVICETOOL.closeLinkDevice isEqualToString:@"J1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J4"]){
                saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr1];
                 for(Device *dev in DEVICETOOL.deviceArr){
                       if([dev.id intValue] == 1 ){
                           deviceChange = dev; break;
                       }
                   }
            }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J5"]){
                saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr2];
                for(Device *dev in DEVICETOOL.deviceArr){
                    if([dev.id intValue] == 2 ){
                        deviceChange = dev; break;
                    }
                }
            }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J6"]){
                saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr3];
                for(Device *dev in DEVICETOOL.deviceArr){
                    if([dev.id intValue] == 3 ){
                        deviceChange = dev; break;
                    }
                }
            }
            
            NSMutableArray *dataArray = [NSMutableArray arrayWithArray:@[DEVICETOOL.deviceDataArr4,DEVICETOOL.deviceDataArr5,saveDataArr3]];
            
            TestDataModel *dataModel = [[TestDataModel alloc]init];
            dataModel.station = DEVICETOOL.stationStr;
            dataModel.roadSwitch = DEVICETOOL.roadSwitchNo;
            dataModel.idStr = [NSString stringWithFormat:@"%lld%@",_startTime,@"锁闭力"];
                    
            dataModel.dataArr = dataArray;
            dataModel.deviceType = [NSString stringWithFormat:@"%@-锁闭力",DEVICETOOL.closeLinkDevice];
            long long currentTime = [[NSDate date] timeIntervalSince1970] ;
            dataModel.colorArr = testDevice.colorArr;
            dataModel.fanColorArr = testDevice.fanColorArr;
            dataModel.close_transArr = deviceChange.colorArr;
            dataModel.timeLong = currentTime;
            
            Device*device ;
            for (Device*dev in DEVICETOOL.deviceArr) {
                if([dev.id intValue] == 11){
                    device = dev;
                    break;
                }
            }
            if(device){
                NSArray *dictArray = [ReportModel mj_keyValuesArrayWithObjectArray:device.reportArr];
                dataModel.reportArr = [NSMutableArray arrayWithArray:dictArray];
                [[LPDBManager defaultManager] saveModels: device.reportArr];
            }
            [[LPDBManager defaultManager] saveModels: @[dataModel]];
        }
    }
    BOOL findStr = NO;
    for (NSString *str in DEVICETOOL.savedStationArr) {
        if([str isEqualToString:DEVICETOOL.stationStr]){
            findStr = YES;
            break;
        }
    }
    if(!findStr){
        [DEVICETOOL.savedStationArr addObject:DEVICETOOL.stationStr];
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:[NSArray arrayWithArray:DEVICETOOL.savedStationArr] forKey:@"savedStationArr"];
    [HUD showAlertWithText:@"保存成功"];
}

- (IBAction)butClick:(id)sender {
    

    return;
    NSLog(@"butClick");
    UIButton *but = sender;
    but.selected = !but.selected;
    if(but == _firstButton){
        [self.kEchartView1 setHidden:!self.firstButton.selected];
        if(!self.kEchartView1.hidden ){
            [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0  withSample:@"lttb"]];
        }
    }else if(but == _secondButton){
        [self.kEchartView2 setHidden:!_secondButton.selected];
        if(!self.kEchartView2.hidden ){
        [_kEchartView2 refreshEchartsWithOption:[self irregularLine2Option:1  withSample:@"lttb"]];
           }
    }else if(but == _threeButton){
        [self.kEchartView3 setHidden:!_threeButton.selected];
        if(!self.kEchartView3.hidden){
               [_kEchartView3 refreshEchartsWithOption:[self irregularLine2Option:2 withSample:@"lttb"]];
           }
    }


}
-(void)changeView{
    if(DEVICETOOL.testStatus == TestStarted){
        
        if(self.chartViewBackV.hidden){
                if(!self.kEchartView1.hidden ){

                        [_kEchartView1 refreshEchartsWithOption:[self irregularLine2Option:0 withSample:@""]];
                }
                if(!self.kEchartView2.hidden ){

                        [_kEchartView2 refreshEchartsWithOption:[self irregularLine2Option:1 withSample:@""]];
                    
                }
                if(!self.kEchartView3.hidden){

                        [_kEchartView3 refreshEchartsWithOption:[self irregularLine2Option:2 withSample:@""]];
                    
                }
        }else{
                [_kEchartView4 refreshEchartsWithOption:[self getOptionWith:@""]];
        }
        
        long long currentTime = [[NSDate date] timeIntervalSince1970];
        NSInteger timeinterval = currentTime - _startTime;
        timeinterval = timeinterval -_textCount;
        NSInteger ss = timeinterval%60;
        NSInteger hh = timeinterval/60;
        if(hh >=DEVICETOOL.testMaxCount/60){
            ss = 0;
            hh = DEVICETOOL.testMaxCount/60;
        }
        NSString *ssStr = ss < 10 ? [NSString stringWithFormat:@"0%ld",(long)ss]:[NSString stringWithFormat:@"%ld",(long)ss];
        _testTimeLabel.text = [NSString stringWithFormat:@"0%ld:%@",(long)hh,ssStr];
        if(timeinterval >= DEVICETOOL.testMaxCount){
            [self endTest:_endBut];
            [self saveClick:_saveBut];
        }
    }else if(DEVICETOOL.testStatus == TestStoped){
        _textCount++;
    }
    
    for (int i = 0 ; i < _seleJJJArr.count; i++) {
        Device *device = _seleJJJArr[i];
        UIButton * but ;
        if(i == 0){
            but = _firstButton;
        }else if(i == 1){
            but = _secondButton;
        }else if(i == 2){
            but = _threeButton;
        }
        if([device.id isEqualToString:@"11"]){
             [but setTitle:[NSString stringWithFormat:@"%@ %@ %@",@"定位",device.percent,device.vol] forState:UIControlStateNormal];
        }else if([device.id isEqualToString:@"12"]){
            [but setTitle:[NSString stringWithFormat:@"%@ %@ %@",@"反位",device.percent,device.vol] forState:UIControlStateNormal];
        }else{
             [but setTitle:[NSString stringWithFormat:@"%@ %@ %@",device.typeStr,device.percent,device.vol] forState:UIControlStateNormal];
        }
        
    }
}

-(void)startScoketService{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 异步执行任务创建方法
    dispatch_async(queue, ^{
        
    });
}
//-(PYOption *)refreshEcharts:(NSInteger)no{
//    if(no>=_seleJJJArr.count){
//        return nil;
//    }
//    NSMutableArray *saveDataArr ;
//    Device *device = _seleJJJArr[no];
//    if([device.id intValue] == 1){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr1;
//    }else if([device.id intValue] == 2){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr2;
//    }else if([device.id intValue] == 3){
//        saveDataArr = [DeviceTool shareInstance].deviceDataArr3;
//    }
//    long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
//    NSNumber *time = [NSNumber numberWithLongLong:currentTime];
//    NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
//    if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
//        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
//    }
//     return [PYOption initPYOptionWithBlock:^(PYOption *option) {
//            option.addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
//            series.dataEqual(saveDataArr);
//            }]);
//        }];
//}
- (PYOption *)irregularLine2Option:(NSInteger)no withSample:(NSString*)sample{
    BOOL setMax = YES;
    if(no>=_seleJJJArr.count){
        return nil;
    }
    
    
    
    
    NSMutableArray *saveDataArr ;
    Device *device = _seleJJJArr[no];
    
    Device *device2 ;
    int count = 0;
    for(Device *dev in DEVICETOOL.deviceArr){
        if(dev.selected){
            count++;
        }
        if([dev.id intValue] == [device.id intValue] ){
            device2 = dev;
        }
    }
    int maxCount = 0;
    NSNumber *xHeight = @80;
    NSNumber *xHeight2 = @80;
    BOOL dataZoonBool = YES;
    if(count==1){
        maxCount = 40;
    }else if(count==2){
        maxCount = 30;
        dataZoonBool = YES;
        xHeight = @60;
        xHeight2 = @80;
    }else if(count==3){
        maxCount = 20;
        dataZoonBool = NO;
        xHeight = @30;
        xHeight2 = @30;
    }
    
    if([device.id intValue] == 1){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr1];
    }else if([device.id intValue] == 2){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr2];
    }else if([device.id intValue] == 3){
        saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr3];
    }
    NSDictionary *visualMapD = @{@"show":@(NO),@"dimension":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":blueColor},@{@"gt":@(1614835095000),@"color":blueColor}]};
    if(device.colorArr.count != 0){
        NSMutableArray *pieces = [NSMutableArray array];
        NSNumber* saveCount = @(0);
        for (int a = 0; a<device.colorArr.count; a++) {
            NSArray *piece = device.colorArr[a];
            NSString *colorStr = redColor;
            if(piece.count > 2){
                NSNumber *railType = piece[2];
                if(railType.intValue == 1){
                    colorStr = organiColor;
                }else if (railType.intValue ==2){
                    colorStr = realRedColor;
                }
            }
            
            if(a==0){
                [pieces addObject:@{@"lte":piece[0],@"color":blueColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }else{
                [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":blueColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }
            if(a == device.colorArr.count-1){
                 [pieces addObject:@{@"gt":saveCount,@"color":blueColor}];
            }
        }
        visualMapD =  @{@"show":@(NO),@"dimension":@(0),@"pieces":pieces};
//        NSLog(@"visualMapD = %@",visualMapD);
    }
//    if(saveDataArr.count < 1000){
        for (NSArray *arr in saveDataArr) {
            NSNumber *num = arr[1];
            if(num.intValue >500 || num.intValue < -500){
                setMax = NO;
                break;
            }
        }
//    }
//    else{
//        setMax = NO;
//    }
    PYAxis * yAxis ;
    if(setMax){
      yAxis= [PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
                    axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"])
                    .minEqual(@(-500))
                    .maxEqual(@(500));
      }];
    }else{
        yAxis=[PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
                    axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"]);
        //             .nameEqual(@"KN")
        //            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
        //                axisLabel.formatterEqual(@"(function (value, index) {let y = value/1000;return `${y}`;})");
        //            }]);
        //            .minEqual(@(-8000))
        //            .maxEqual(@(8000));
        }];
    }
    
    
    if(saveDataArr.count == 0 && DEVICETOOL.testStatus == TestStarted){
        long long startTime = _startTime *1000;
        NSNumber *time = [NSNumber numberWithLongLong:startTime];
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
        NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }else if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",device.typeStr,@"曲线图"];
    
    PYOption * option =  [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(NO)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@50).x2Equal(@30).y2Equal(xHeight2).yEqual(xHeight);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .axisPointerEqual([PYAxisPointer initPYAxisPointerWithBlock:^(PYAxisPointer *axisPoint) {
//                axisPoint.showEqual(YES)
//                .typeEqual(PYAxisPointerTypeCross)
//                .lineStyleEqual([PYLineStyle initPYLineStyleWithBlock:^(PYLineStyle *lineStyle) {
//                    lineStyle.typeEqual(PYLineStyleTypeDashed)
//                    .widthEqual(@1);
//                }]);
//            }])
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"道岔检测"]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@4)
            .scaleEqual(YES)
            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *splitLine) {
                splitLine.showEqual(NO);
            }])
            .axisPointerEqual(@{@"label":@{@"formatter":@"(function (params) {let value = params.value;let dateV = new Date(value);let year = dateV.getFullYear();let month = dateV.getMonth() + 1;month = month < 10 ? ('0' + month) : month;let date = dateV.getDate();date = date < 10 ? ('0' + date) : date;let miniS = params.value%1000;let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${year}:${month}:${date} ${hour}:${min}:${ss} ${miniS}`;})"}})
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
            }]);
        }])
        .addYAxis(yAxis)
//        .visualMapEqual(visualMapD)
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"inside");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
                 dataZoom.showEqual(dataZoonBool).startEqual(@0).typeEqual(@"slider");
             }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolEqual(@"none")
//            .symbolSizeEqual(@(0)).showAllSymbolEqual(YES)
            .smoothEqual(YES)
            .nameEqual(@"道岔检测").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(@"lttb")
            .itemStyleEqual([PYItemStyle initPYItemStyleWithBlock:^(PYItemStyle *itemStyle) {
                itemStyle.normalEqual([PYItemStyleProp initPYItemStylePropWithBlock:^(PYItemStyleProp *itemStyleProp) {
                    itemStyleProp.colorEqual(@"#4B8CF5").borderWidthEqual(@(0.25));
                }]);
            }]);
        }]);
    }];
    
    [DEVICETOOL changeReport:option reportArr:device2.reportArr maxCount:maxCount];
    
//    CSQVisualMap *visual = [[CSQVisualMap alloc]init];
//    visual.pieces = [visualMapD objectForKey:@"pieces"];
//    option.visualMap = visual;
    if(![visualMapD isEqualToDictionary: @{}]){
        option.visualMap =visualMapD;
    }
    return option;
}

- (PYOption *)getOptionWith:(NSString*)sample{
    BOOL setMax = YES;
    NSMutableArray *saveDataArr;
    NSMutableArray *saveDataArr2;
    NSMutableArray *saveDataArr3;
    
    Device *deviceChange;
    Device *deviceCLose1;
    Device *deviceCLose2;
    
   for(Device *dev in DEVICETOOL.deviceArr){
       if([dev.id intValue] == 11 ){
           deviceCLose1 = dev; break;
       }
   }
    for(Device *dev in DEVICETOOL.deviceArr){
        if([dev.id intValue] == 12 ){
            deviceCLose2 = dev; break;
        }
    }
    if([DEVICETOOL.closeLinkDevice isEqualToString:@"J1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X1"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J4"]){
        saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr1];
         for(Device *dev in DEVICETOOL.deviceArr){
               if([dev.id intValue] == 1 ){
                   deviceChange = dev; break;
               }
           }
    }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X2"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J5"]){
        saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr2];
        for(Device *dev in DEVICETOOL.deviceArr){
            if([dev.id intValue] == 2 ){
                deviceChange = dev; break;
            }
        }
    }else if([DEVICETOOL.closeLinkDevice isEqualToString:@"J3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"X3"] || [DEVICETOOL.closeLinkDevice isEqualToString:@"J6"]){
        saveDataArr3 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr3];
        for(Device *dev in DEVICETOOL.deviceArr){
            if([dev.id intValue] == 3 ){
                deviceChange = dev; break;
            }
        }
    }
    
    saveDataArr = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr4];
    saveDataArr2 = [NSMutableArray arrayWithArray:[DeviceTool shareInstance].deviceDataArr5];
   
    //锁闭力测试的s转换阻力
        NSDictionary *visualMapDCHange = @{@"show":@(NO),@"dimension":@(0),@"seriesIndex":@(0),@"pieces":@[@{@"lte":@(1614835094000),@"color":dinColor},@{@"gt":@(1614835095000),@"color":dinColor}]};
        if(deviceChange.colorArr.count != 0){
            NSMutableArray *pieces = [NSMutableArray array];
            NSNumber* saveCount = @(0);
            for (int a = 0; a<deviceChange.colorArr.count; a++) {
                NSArray *piece = deviceChange.colorArr[a];
                
                NSString *colorStr = dinColor;
                if(piece.count > 2){
                    NSNumber *railType = piece[2];
                    if(railType.intValue == 1){
                        colorStr = organiColor;
                    }else if (railType.intValue ==2){
                        colorStr = realRedColor;
                    }
                }
                if(a==0){
                    [pieces addObject:@{@"lte":piece[0],@"color":dinColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                    saveCount = piece[1];
                }else{
                    [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":dinColor}];
                    [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                    saveCount = piece[1];
                }
                if(a == deviceChange.colorArr.count-1){
                     [pieces addObject:@{@"gt":saveCount,@"color":dinColor}];
                }
            }
            visualMapDCHange =  @{@"show":@(NO),@"seriesIndex":@(0),@"dimension":@(0),@"pieces":pieces};
        }
    //定位
    NSDictionary *visualMapDClose1 = @{@"show":@(NO),@"dimension":@(0),@"seriesIndex":@(1),@"pieces":@[@{@"lte":@(1614835094000),@"color":fanColor},@{@"gt":@(1614835095000),@"color":fanColor}]};
    if(deviceCLose1.colorArr.count != 0){
        NSMutableArray *pieces = [NSMutableArray array];
        NSNumber* saveCount = @(0);
        for (int a = 0; a<deviceCLose1.colorArr.count; a++) {
            NSArray *piece = deviceCLose1.colorArr[a];
            NSString *colorStr = fanColor;
            if(piece.count > 2){
                NSNumber *railType = piece[2];
                if(railType.intValue == 1){
                    colorStr = organiColor;
                }else if (railType.intValue ==2){
                    colorStr = realRedColor;
                }
            }
            if(a==0){
                [pieces addObject:@{@"lte":piece[0],@"color":fanColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }else{
                [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":fanColor}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }
            if(a == deviceCLose1.colorArr.count-1){
                 [pieces addObject:@{@"gt":saveCount,@"color":fanColor}];
            }
        }
        visualMapDClose1 =  @{@"show":@(NO),@"seriesIndex":@(1),@"dimension":@(0),@"pieces":pieces};
    }
    //反位
    NSDictionary *visualMapDClose2 = @{@"show":@(NO),@"dimension":@(0),@"seriesIndex":@(2),@"pieces":@[@{@"lte":@(1614835094000),@"color":close_transform_color},@{@"gt":@(1614835095000),@"color":close_transform_color}]};
    if(deviceCLose1.fanColorArr.count != 0){
        NSMutableArray *pieces = [NSMutableArray array];
        NSNumber* saveCount = @(0);
        for (int a = 0; a<deviceCLose1.fanColorArr.count; a++) {
            NSArray *piece = deviceCLose1.fanColorArr[a];
            NSString *colorStr = close_transform_color;
            if(piece.count > 2){
                NSNumber *railType = piece[2];
                if(railType.intValue == 1){
                    colorStr = organiColor;
                }else if (railType.intValue ==2){
                    colorStr = realRedColor;
                }
            }
            if(a==0){
                [pieces addObject:@{@"lte":piece[0],@"color":close_transform_color}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }else{
                [pieces addObject:@{@"gt":saveCount,@"lte":piece[0],@"color":close_transform_color}];
                [pieces addObject:@{@"gt":piece[0],@"lte":piece[1],@"color":colorStr}];
                saveCount = piece[1];
            }
            if(a == deviceCLose1.fanColorArr.count-1){
                 [pieces addObject:@{@"gt":saveCount,@"color":close_transform_color}];
            }
        }
        visualMapDClose2 =  @{@"show":@(NO),@"seriesIndex":@(2),@"dimension":@(0),@"pieces":pieces};
    }
    
//    if(saveDataArr.count < 1000){
//         for (NSArray *arr in saveDataArr) {
//                   NSNumber *num = arr[1];
//                   if(num.intValue >500 || num.intValue < -500){
//                       setMax = NO;
//                       break;
//                   }
//               }
//    }
    
    setMax = NO;
    
    PYAxis * yAxis ;
    if(setMax){
      yAxis= [PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
                    axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"])
                    .minEqual(@(-500))
                    .maxEqual(@(500));
      }];
    }else{
        yAxis=[PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
                    axis.typeEqual(PYAxisTypeValue).scaleEqual(YES).boundaryGapEqual(@[@"2.5%",@"2.5%"]);
        //             .nameEqual(@"KN")
        //            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
        //                axisLabel.formatterEqual(@"(function (value, index) {let y = value/1000;return `${y}`;})");
        //            }]);
        //            .minEqual(@(-8000))
        //            .maxEqual(@(8000));
        }];
    }
    
    if(saveDataArr.count == 0 && DEVICETOOL.testStatus == TestStarted){
        long long startTime = _startTime *1000;
        NSNumber *time = [NSNumber numberWithLongLong:startTime];
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
        NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
        saveDataArr2 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }else if(saveDataArr.count == 0 || DEVICETOOL.testStatus == TestNotStart){
        long long currentTime = [[NSDate date] timeIntervalSince1970] *1000;
           NSNumber *time = [NSNumber numberWithLongLong:currentTime];
           NSNumber *time2 = [NSNumber numberWithLongLong:currentTime+100];
        saveDataArr = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
        saveDataArr2 = [NSMutableArray arrayWithArray:@[@[time,@(0)],@[time2,@(0)]]];
    }
    NSString *titleStr = [NSString stringWithFormat:@"%@%@",@"锁闭力",@"曲线图"];
    
    
    PYOption *option = [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(titleStr)
            .subtextEqual(@"");
        }])
        .animationEqual(YES)
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@60).x2Equal(@40).y2Equal(@80).yEqual(@80);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
//            .formatterEqual(@"(function(params){var date = new Date(params.value[0]);data =  date.getHours() + \':\' + date.getMinutes()+ \':\' + date.getSeconds(); return data + \'<br/>\' + params.value[1] })");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"slider");
        }])
        .addDataZoom([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES).startEqual(@0).typeEqual(@"inside");
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.dataEqual(@[@"定位锁闭力",@"反位锁闭力",[NSString stringWithFormat:@"%@转换力",DEVICETOOL.closeLinkDevice]]);
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeTime)
            .splitNumberEqual(@4)
            .scaleEqual(YES)
            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *splitLine) {
                splitLine.showEqual(NO);
            }])
            .axisPointerEqual(@{@"label":@{@"formatter":@"(function (params) {let value = params.value;let dateV = new Date(value);let year = dateV.getFullYear();let month = dateV.getMonth() + 1;month = month < 10 ? ('0' + month) : month;let date = dateV.getDate();date = date < 10 ? ('0' + date) : date;let miniS = params.value%1000;let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${year}:${month}:${date} ${hour}:${min}:${ss} ${miniS}`;})"}})
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"(function (value, index) {let hour = new Date(value).getHours();let min = new Date(value).getMinutes();let ss = new Date(value).getSeconds();ss = ss.toString();min = min.toString(); if(min.length <2){min = '0'+min};if(ss.length <2){ss = '0'+ss};return `${hour}:${min}:${ss}`;})");
            }]);
        }])
        .addYAxis(yAxis)
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual([NSString stringWithFormat:@"%@转换力",DEVICETOOL.closeLinkDevice]).typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr3).samplingEqual(sample);
        }])
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"定位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr).samplingEqual(sample);
        }])
//        .graphicEqual([CSQGraphic initCSQGraphicWithBlock:^(CSQGraphic * _Nonnull graphic) {
//            graphic.typeEqual(@"text")
//            .zEqual(@(1000))
//            .leftEqual(@"left")
//            .topEqual(@"top")
//            .styleEqual(@{@"style":@{@"fill":@"#333",@"text":@"检测结果:\n\n1:定扳反 峰值:6300 均值3500",@"font":@"11px Microsoft YaHei"}});
//        }])  //,@"type":@"text",@"z":@(100),@"right":@"right",@"top":@"top"}
        .addSeries([PYCartesianSeries initPYCartesianSeriesWithBlock:^(PYCartesianSeries *series) {
            series.symbolEqual(@"none")
            .smoothEqual(YES)
            .nameEqual(@"反位锁闭力").typeEqual(PYSeriesTypeLine).dataEqual(saveDataArr2).samplingEqual(sample)
            .itemStyleEqual([PYItemStyle initPYItemStyleWithBlock:^(PYItemStyle *itemStyle) {
                itemStyle.normalEqual([PYItemStyleProp initPYItemStylePropWithBlock:^(PYItemStyleProp *itemStyleProp) {
                    itemStyleProp.colorEqual(close_transform_color).borderWidthEqual(@(0.25));
                }]);
            }]);
        }])
        ;
    }];

    option.visualMap = @[visualMapDClose1,visualMapDClose2,visualMapDCHange];
    [DEVICETOOL changeReport:option reportArr:deviceCLose1.reportArr maxCount:20];
    return option;
}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 20;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell" forIndexPath:indexPath];
////    cell.reportLabel.text = @"aaa";
//    return cell;
//}
- (IBAction)showSaveData:(id)sender {
//    HistoryDataViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryDataViewController"];
//    [self.navigationController pushViewController:VC animated:YES];
}
- (IBAction)closeDeviceBut:(id)sender {
}
@end
