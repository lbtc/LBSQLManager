//
//  LBSQLManager.m
//
//  Created by xiaoyungo on 3/17/15.
//  Copyright (c) 2015 libin. All rights reserved.
//

#import "LBSQLManager.h"
#import <objc/runtime.h>
#import "FMDatabaseQueue.h"

// 通过实体获取类名
#define KCLASS_NAME(model) [NSString stringWithUTF8String:object_getClassName(model)]

// 通过实体获取属性数组
#define KMODEL_PROPERTYS [self getAllProperties:model]

// 通过实体获取属性数组数目
#define KMODEL_PROPERTYS_COUNT [[self getAllProperties:model] count]

/*
 *   用反射机制，做数据库的对象关系映射（ORM）
 *
 *   // CoreData做的事
 *   // 1.用类名做表名
 *   // 2.属性做字段名
 *   // 3.对象的值做存表里面的值
 *   // 4.取值时是对象
 */

static LBSQLManager * manager = nil;
@implementation LBSQLManager

{
    FMDatabaseQueue *_dbQueue; // 数据库操作队列
}


// GCD单例
+ (LBSQLManager *)sharedInstace
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LBSQLManager alloc]init];
    });
    return manager;
    
 
}

// 获取沙盒路径
- (NSString *)databaseFilePath
{
#warning 你可以在这里修改数据库所在路径
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath objectAtIndex:0];
    NSLog(@"%@",filePath);
    NSString *dbFilePath = [documentPath stringByAppendingPathComponent:@"db.sqlite"];
    return dbFilePath;
    
}

// 创建数据库
- (void)creatDatabase
{
    _dbQueue = [[FMDatabaseQueue alloc]initWithPath:[self databaseFilePath]];

}

// 创建数据表
- (void)creatTable:(id)model
{

    if (!_dbQueue) {

        [self creatDatabase];
    }
    
    [_dbQueue inDatabase:^(FMDatabase *db) {

        if (![db open]) {
            NSLog(@"数据库打开失败");
            return;
        }
        

        [db setShouldCacheStatements:YES];
        

        if (![db tableExists:KCLASS_NAME(model)]) {

            NSString *creatTableStrOne = [NSString stringWithFormat:@"create table %@(id integer primary key",KCLASS_NAME(model)];
            

            NSMutableString *creatTableStrTwo = [NSMutableString string];
            for (NSString *popertyName in KMODEL_PROPERTYS) {
                [creatTableStrTwo appendFormat:@",%@ text",popertyName];
            }

            NSString *creatTableStr = [NSString stringWithFormat:@"%@%@)",creatTableStrOne,creatTableStrTwo];
            
            if ([db executeUpdate:creatTableStr]) {
                NSLog(@"创建完成");
            }
        }

        [db close];
    }];
}

/**
 *  数据库插入或更新实体
 *
 *  @param model 实体
 */
-(void)insertAndUpdateModelToDatabase:(id)model
{

    if (!_dbQueue) {

        [self creatDatabase];
    }
    
    [_dbQueue inDatabase:^(FMDatabase *db) {

        if (![db open]) {
            NSLog(@"数据库打开失败");
            return;
        }

        [db setShouldCacheStatements:YES];
        

        if(![db tableExists:KCLASS_NAME(model)])
        {
            [self creatTable:model];
        }
        
        //查询有没有相同的元素，如果有，做修改操作，如果没有，做插入操作
        //查询数据表之前，必须保证第一个字段是唯一标示
        
        NSString *selectStr = [NSString stringWithFormat:@"select *from %@ where %@ = ?",KCLASS_NAME(model),[KMODEL_PROPERTYS objectAtIndex:0]];

        FMResultSet * resultSet = [db executeQuery:selectStr,[model valueForKey:[KMODEL_PROPERTYS objectAtIndex:0]]];
        
        if ([resultSet next]) {
          
            NSString *updateStrOne = [NSString stringWithFormat:@"update %@ set ",KCLASS_NAME(model)];

            NSMutableString *updateStrTwo = [NSMutableString string];
            for (int i = 0;i< KMODEL_PROPERTYS_COUNT;i++) {
                
                [updateStrTwo appendFormat:@"%@ = ?",[KMODEL_PROPERTYS objectAtIndex:i]];

                if (i != KMODEL_PROPERTYS_COUNT -1) {
                    [updateStrTwo appendFormat:@","];
                }
            }

            NSString *updateStrThree = [NSString stringWithFormat:@"where %@ = %@",[KMODEL_PROPERTYS objectAtIndex:0], [model valueForKey:[KMODEL_PROPERTYS objectAtIndex:0]]];
            

            NSString *updateStr = [NSString stringWithFormat:@"%@%@%@",updateStrOne,updateStrTwo,updateStrThree];

            NSMutableArray *propertyValue = [NSMutableArray array];
            for (NSString *property in KMODEL_PROPERTYS) {
                [propertyValue addObject:[model valueForKey:property]];
            }

            if([db executeUpdate:updateStr withArgumentsInArray:propertyValue])
            {
                NSLog(@"调用更新成功");
            };
        }
        else
        {
            
            NSString *insertStrOne = [NSString stringWithFormat:@"insert into %@ (",KCLASS_NAME(model)];

            NSMutableString *insertStrTwo =[NSMutableString string];
            for (int i =0; i<KMODEL_PROPERTYS_COUNT; i++) {
                [insertStrTwo appendFormat:@"%@",[KMODEL_PROPERTYS objectAtIndex:i]];
                if (i!=KMODEL_PROPERTYS_COUNT -1) {
                    [insertStrTwo appendFormat:@","];
                }
            }

            NSString *insertStrThree =[NSString stringWithFormat:@") values ("];

            NSMutableString *insertStrFour =[NSMutableString string];
            for (int i =0; i<KMODEL_PROPERTYS_COUNT; i++) {
                [insertStrFour appendFormat:@"?"];
                if (i!=KMODEL_PROPERTYS_COUNT -1) {
                    [insertStrFour appendFormat:@","];
                }
            }

            NSString *insertStr = [NSString stringWithFormat:@"%@%@%@%@)",insertStrOne,insertStrTwo,insertStrThree,insertStrFour];

            NSMutableArray *propertyValue = [NSMutableArray array];
            for (NSString *property in KMODEL_PROPERTYS) {
                [propertyValue addObject:[model valueForKey:property]];
            }

            if([db executeUpdate:insertStr withArgumentsInArray:propertyValue])
            {
                NSLog(@"插入成功");
            }
            

            [db close];

        }
        
    }];

}

/**
 *  数据库对应实体
 *
 *  @param model 实体
 */
- (void)deleteModelInDatabase:(id)model
{

    if (!_dbQueue) {

        [self creatDatabase];
    }

    [_dbQueue inDatabase:^(FMDatabase *db) {

        if (![db open]) {
            NSLog(@"数据库打开失败");
            return;
        }

        [db setShouldCacheStatements:YES];
        

        if(![db tableExists:KCLASS_NAME(model)])
        {
            [self creatTable:model];
        }


        NSString *deleteStr = [NSString stringWithFormat:@"delete from %@ where %@ = ?",KCLASS_NAME(model),[KMODEL_PROPERTYS objectAtIndex:0]];
        
        if([db executeUpdate:deleteStr,[model valueForKey:[KMODEL_PROPERTYS objectAtIndex:0]]])
        {
            NSLog(@"删除成功");
        }

        [db close];
        
    }];
}

/**
 *  数据库查询所有实体
 *
 *  @param 所有实体
 */
- (NSArray *)selectModelArrayInDatabase:(NSString *)tableName
{

    if (!_dbQueue) {

        [self creatDatabase];
    }
    __block NSMutableArray *modelArray = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        if (![db open]) {
            NSLog(@"数据库打开失败");
        }
        
        [db setShouldCacheStatements:YES];
        
     
        NSString * selectStr = [NSString stringWithFormat:@"select *from %@",tableName];
        FMResultSet *resultSet = [db executeQuery:selectStr];
        while([resultSet next]) {

            id model = [[NSClassFromString(tableName) alloc]init];
            for (int i =0; i< KMODEL_PROPERTYS_COUNT; i++) {
            
                [model setValue:[resultSet stringForColumn:[KMODEL_PROPERTYS objectAtIndex:i]] forKey:[KMODEL_PROPERTYS objectAtIndex:i]];
            }
            [modelArray addObject:model];
        }

    }];
    return modelArray;
}

/**
 *  传递一个model实体
 *
 *  @param model 实体
 *
 *  @return 实体的属性
 */
- (NSArray *)getAllProperties:(id)model
{
    u_int count;
    
    objc_property_t *properties  = class_copyPropertyList([model class], &count);
    

    NSMutableArray *propertiesArray = [NSMutableArray array];
    
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    
    free(properties);
    return propertiesArray;
}
@end
