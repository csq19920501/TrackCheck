//
//  Device.m
//  TrackCheck
//
//  Created by ethome on 2021/1/8.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "Device.h"

@implementation Device
-(instancetype)init{
    self = [super init];
    if(self){
        long long currentTime = [[NSDate date] timeIntervalSince1970] ;
        _timeStr = [NSString stringWithFormat:@"%lld",currentTime];
        _reportArr = [NSMutableArray array];
        _colorArr = [NSMutableArray array];
        _fanColorArr = [NSMutableArray array];
        _close_transArr = [NSMutableArray array];
        _percent = @"0";
        _vol = @"0";
    }
    return self;
}
@end
