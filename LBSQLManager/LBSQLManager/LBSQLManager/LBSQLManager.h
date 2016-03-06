//
//  LBSQLManager.h
//
//  Created by xiaoyungo on 3/17/15.
//  Copyright (c) 2015 libin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface LBSQLManager : NSObject

/**
 单例方法
 */
+ (LBSQLManager *)sharedInstace;


/**
 创建表
 */
- (void)creatTable:(id)model;

/**
 *  数据库增加或更新
 *
 *  @param model 元素
 */

-(void)insertAndUpdateModelToDatabase:(id)model;

/**
 *  数据库删除元素
 *
 *  @param model 元素
 */
-(void)deleteModelInDatabase:(id)model;

/**
 *  数据库通过表名查询所有对应表的所有值
 */
- (NSArray *)selectModelArrayInDatabase:(NSString *)className;
@end
