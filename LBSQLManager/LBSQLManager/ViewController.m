//
//  ViewController.m
//  LBSQLManager
//
//  Created by 李斌 on 16/3/6.
//  Copyright © 2016年 xiaoyungo. All rights reserved.
//

#import "ViewController.h"
#import "LBUserModel.h"
#import "LBSQLManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   //创建model
    LBUserModel *userModel = [[LBUserModel alloc] init];
    userModel.userName = @"xiaom";
    userModel.usid = @"001";
    userModel.iconURL = @"www.baidu.com";
    userModel.expirationDate = [NSDate date];
    userModel.accessToken = @"iiiiiiililil";
    
    //存入到数据库
    //创建数据库表（创建后里面并没有数据）一定要先创建表否则会导致崩溃
    [[LBSQLManager sharedInstace] creatTable:userModel];
    // 调用更新或插入数据
    [[LBSQLManager sharedInstace] insertAndUpdateModelToDatabase:userModel];
    //从数据库中获取model
    [[LBSQLManager sharedInstace] selectModelArrayInDatabase:NSStringFromClass([LBUserModel class])];
    //删除
    [[LBSQLManager sharedInstace] deleteModelInDatabase:userModel];
    
}

@end
