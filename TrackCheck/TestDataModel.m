//
//  TestDataModel.m
//  TrackCheck
//
//  Created by ethome on 2021/1/14.
//  Copyright © 2021 ethome. All rights reserved.
//

#import "TestDataModel.h"

@implementation TestDataModel

+ (NSString *)primaryKey
{
    return @"idStr";
}
-(instancetype)init{
    self = [super init];
    if(self){
        self.dataArr = [NSMutableArray array];
        self.reportArr = [NSMutableArray array];
        self.colorArr = [NSMutableArray array];
        self.fanColorArr = [NSMutableArray array];
        self.close_transArr = [NSMutableArray array];
    }
    return self;
}
//+ (NSArray <NSString *> *)indexedProperties
//{
//    return @[@"height,birthDay"];
//}
@end
