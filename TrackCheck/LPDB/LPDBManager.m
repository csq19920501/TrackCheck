//
//  LPDBManager.m
//  DBTest
//
//  Created by pennyli on 7/21/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import "LPDBManager.h"
#import "LPDBModel+SQL.h"
#import "LPDBManager+Private.h"
#import "NSString-SQLitePersistence.h"
#import "NSObject-ClassName.h"

@interface LPDBManager()

@end

@implementation LPDBManager
static LPDBManager *manager ;
+ (NSString *)DocPath
{
    NSString* strPath =  [[NSBundle mainBundle] bundlePath];
    NSString *documentsDirectory;
    if ([strPath hasPrefix:@"/var/mobile/Applications"]) {
        NSRange range = [strPath rangeOfString:@"/" options:NSBackwardsSearch];
        strPath = [strPath substringToIndex:range.location];
        documentsDirectory = [strPath stringByAppendingFormat:@"/Documents"];
    }else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];//NSDocumentDirectory  NSApplicationSupportDirectory
    }
    return documentsDirectory;	
    
}

+ (NSString *)dbPath;
{
    NSString* path = [NSString stringWithFormat:@"%@/lpdb.db", [self DocPath]];
    NSLog(@"%@", path);
    return path;
}
//+ (NSString *)dbPath2;
//{
//    NSString* path = [NSString stringWithFormat:@"%@/2/lpdb.db", [self DocPath]];
//    NSLog(@"%@", path);
//    return path;
//}
+ (LPDBManager *)defaultManager
{
    @synchronized(self){
           if(manager == nil)
            manager = [[LPDBManager alloc] initWithDBPath: [[self class] dbPath]];
        }

     return manager;
  
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (manager == nil) {
//            manager = [[LPDBManager alloc] initWithDBPath: [[self class] dbPath]];
//        }
//    });
//    return manager;
}
+ (void)clean{
    manager = nil;
}
- (instancetype)initWithDBPath:(NSString *)path
{
    if (self = [super init]) {
        _path = path;
        _queue = [FMDatabaseQueue databaseQueueWithPath: _path];
    }
    return self;
}

- (void)clearTable:(Class)modelClass;
{
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [modelClass clearTable: db];
        }];
    }
}

- (void)saveModels:(NSArray<__kindof LPDBModel *> *)models;
{
//    NSLog(@"???model11");
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (LPDBModel * model in models) {
//            NSLog(@"???model22");
            [model save: db];
        }
    }];
}

- (void)deleteModels:(NSArray<LPDBModel *> *)models
{
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (LPDBModel * model in models) {
            [model remove: db];
        }
    }];
}

- (BOOL)existModel:(LPDBModel *)model
{
    __block BOOL exist = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        exist = [model exist: db];
    }];
    return exist;
}

- (NSArray <LPDBModel *> *)findModels:(Class)modelClass where:(NSString *)sql,...
{
//    NSLog(@"????????????");
//    if(!sql.length){
//        return nil;
//    }
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        NSString *query = nil;
        if (sql.length) {
            va_list args;
            va_start(args, sql);
            query = [NSString stringWithFormat: @"select * from %@ where %@", [modelClass className], [[NSString alloc] initWithFormat: sql arguments: args]];
            va_end(args);
        } else{
            
            query = [NSString stringWithFormat: @"select * from %@", [modelClass className]];
        }
            
        __block NSArray *result = nil;
        [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            result = [modelClass findModels: query db: db];
        }];
        return result;
    }
    return nil;
}
//???????????????????????????


- (__kindof LPDBModel *)model:(Class)modelClass forPrimaryKey:(id)value
{
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        NSString *where = nil;
        if ([value respondsToSelector: @selector(sqlColumnRepresentationOfSelf)]) {
            NSString *sqlValue = [value sqlColumnRepresentationOfSelf];
            where = [NSString stringWithFormat: @"%@='%@'", [modelClass primaryKey], sqlValue];
        } else {
            NSData *sqlValue = [value sqlBlobRepresentationOfSelf];
            where = [NSString stringWithFormat: @"%@=%@", [modelClass primaryKey], sqlValue];
        }
//        NSLog(@"??????????????????");
        return [[self findModels: modelClass where: where] lastObject];
    }
    return nil;
}

/**
 ??????????????????
 */
- (NSUInteger)countOfModel:(Class)modelClass where:(NSString *)sql,...
{
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        NSString *query = nil;
        if (sql.length) {
            va_list args;
            va_start(args, sql);
            query = [NSString stringWithFormat: @"select count(*) from %@ where %@", [modelClass className], [[NSString alloc] initWithFormat: sql arguments: args]];
            va_end(args);
        } else {
            query = [NSString stringWithFormat: @"select count(*) from %@", [modelClass className]];
        }
        __block NSUInteger len = 0;
        [self.queue inDatabase:^(FMDatabase *db) {
            len = [modelClass countOfModels: query db: db];
        }];
        return len;
    }
    return 0;
}

/**
 ????????????
 */
- (BOOL)batchUpdateOfModel:(Class)modelClass withParams:(NSDictionary <NSString *, id> *)paramDict where:(NSString *)sql,...
{
    
    if (paramDict.count == 0) {
        return NO;
    }
    
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        NSArray *allKey = [paramDict allKeys];
        NSMutableString *setStr = [NSMutableString string];
        NSMutableArray *values = [NSMutableArray array];
        [allKey enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < allKey.count - 1) {
                [setStr appendFormat: @"%@=?,", key];
            } else
                [setStr appendFormat: @"%@=?", key];
            [values addObject: paramDict[key]];
        }];
    
        NSString *updateStr = [NSString stringWithFormat: @"update %@ set %@", [modelClass className], setStr];
        if (sql.length) {
            va_list args;
            va_start(args, sql);
            updateStr = [NSString stringWithFormat: @"update %@ set %@ where %@", [modelClass className], setStr, [[NSString alloc] initWithFormat: sql arguments: args]];
            va_end(args);
        }
        
        __block BOOL success = NO;
        [self.queue inDatabase:^(FMDatabase *db) {
            success = [modelClass updateModels: updateStr withValues: values db: db];
        }];
        
        return success;
    }
    return NO;
}

/**
 ????????????
 */
- (BOOL)batchDeleteOfModels:(Class)modelClass where:(NSString *)sql,...
{
    if ([modelClass isSubclassOfClass: [LPDBModel class]]) {
        NSString *deleteStr = [NSString stringWithFormat: @"delete from %@", [modelClass className]];
        if (sql.length) {
            va_list args;
            va_start(args, sql);
            deleteStr = [NSString stringWithFormat: @"delete from %@ where %@", [modelClass className], [[NSString alloc] initWithFormat: sql arguments: args]];
            va_end(args);
        }
        __block BOOL success = NO;
        [self.queue inDatabase:^(FMDatabase *db) {
            success = [modelClass deleteModels: deleteStr db: db];
        }];
        return success;
    }
    return YES;
}
@end

