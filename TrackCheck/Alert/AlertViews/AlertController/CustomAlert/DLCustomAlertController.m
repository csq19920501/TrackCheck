//
//  DLCustomAlertController.m
//  整理
//
//  Created by 周冰烽 on 2020/7/20.
//  Copyright © 2020 周冰烽. All rights reserved.
//

#import "DLCustomAlertController.h"

@interface DLCustomAlertController ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic,copy)NSString *selectItem;
@property(nonatomic, weak) UILabel * titleLabel;

@end

@implementation DLCustomAlertController

#pragma mark -
#pragma mark - clickEvent

- (void)clickCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickConfirm {
    NSArray *arr = [NSArray arrayWithObjects:self.selectItem, nil];
    !_selectValues ?: _selectValues(arr);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - UI

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    if(_pickerDatas.count > 0){
        NSArray *detailArr = self.pickerDatas[0];
        if(detailArr.count > 0){
            self.selectItem = detailArr[0];
        }
    }
    
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor screenColor];
    self.view.layer.cornerRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOpacity = 0.3f;
    self.view.layer.shadowOffset = CGSizeMake(3.0, -2.0);
    CALayer *lineLayer = [[CALayer alloc] init];
    lineLayer.backgroundColor = [UIColor lineColor].CGColor;
    lineLayer.frame = CGRectMake(0, 60, self.view.width - (ANIMATION_X * 2), 1);
    [self.view.layer addSublayer:lineLayer];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor normalTextColor];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont systemFontOfSize:25.0f];
    [self.view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(12);
    }];
    self.titleLabel = titleLabel;
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor dl_redColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.centerY.equalTo(titleLabel);
    }];
    [cancelBtn addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [[UIButton alloc] init];
    [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor themeColor] forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:22.0f];
    [self.view addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.centerY.equalTo(titleLabel);
    }];
    [confirmBtn addTarget:self action:@selector(clickConfirm) forControlEvents:UIControlEventTouchUpInside];
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.showsSelectionIndicator = YES;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [self.view addSubview:pickerView];
    [pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(45);
    }];
    if(self.selectRow != 0){
        [pickerView selectRow:self.selectRow inComponent:0 animated:NO];
    }
}

#pragma mark -
#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.pickerDatas.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *detailArr = self.pickerDatas[component];
    return detailArr.count;
}

#pragma mark -
#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    if(IS_PAD){
      return 60;
    }
    return 44;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setBackgroundColor:[UIColor clearColor]];
    }
    NSString *title;
    NSArray *detailArr = self.pickerDatas[component];
    title = detailArr[row];
    customLabel.text = title;
    customLabel.textColor = [UIColor blackColor];
    customLabel.font = [UIFont systemFontOfSize:28.0f];
    return customLabel;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSArray *detailArr = self.pickerDatas[component];
    self.selectItem = detailArr[row];
    
    [pickerView reloadAllComponents];
}

@end
