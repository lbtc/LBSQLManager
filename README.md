# LBSQLManager
利用ORM技术管理数据库，只要两句代码即可以将模型储存到数据库中，一句代码实现对数据的增，删，改，查操作

 用反射机制，做数据库的对象关系映射（ORM）  
 
 1.用类名做表名  
 
 2.属性做字段名  
 
 3.对象的值做存表里面的值  
 
 4.取值时是对象  
 
 
 使用说明：  
 
 注：使用时请确保模型的第一个属性的唯一性
 

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
 

