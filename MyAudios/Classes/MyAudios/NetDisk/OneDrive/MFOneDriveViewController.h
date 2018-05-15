//
//  MFOneDriveViewController.h
//  MyAudios
//
//  Created by chang on 2017/12/11.
//  Copyright © 2017年 chang. All rights reserved.
//
// 参考：
// https://github.com/OneDrive/onedrive-sdk-ios
// https://github.com/OneDrive/onedrive-sdk-ios/blob/master/docs/items.md
// https://docs.microsoft.com/zh-cn/onedrive/developer/rest-api/resources/permission
// https://github.com/OneDrive/onedrive-sdk-ios/blob/master/docs/auth.md



#import <UIKit/UIKit.h>

@interface MFOneDriveViewController : MyNavigationViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;// 登录按钮

@end
