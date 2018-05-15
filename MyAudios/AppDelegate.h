//
//  AppDelegate.h
//  MyAudios
//
//  Created by chang on 2017/7/17.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *wbtoken;// 微博分享使用token
@property (strong, nonatomic) NSString *wbRefreshToken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

@end

