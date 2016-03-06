//
//  LBUserModel.h
//  
//
//  Created by 李斌 on 15/6/16.
//
//

#import <Foundation/Foundation.h>

@interface LBUserModel : NSObject
/**
 用户昵称
 */
@property (nonatomic, copy) NSString *userName;

/**
 用户id号
 */
@property (nonatomic, copy) NSString *usid;

/**
 用户头像的url
 */
@property (nonatomic, copy) NSString *iconURL;

/**
 用户授权后得到的accessToken
 */
@property (nonatomic, copy) NSString *accessToken;

/**
 授权的过期时间
 */
@property (nonatomic, retain) NSDate *expirationDate;


@end
