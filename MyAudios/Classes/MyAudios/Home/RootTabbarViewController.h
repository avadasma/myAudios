//
//  RootTabbarViewController.h
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFMyAccountViewController;

@interface RootTabbarViewController : UITabBarController

@property (nonatomic, strong) MFMyAccountViewController * myAccountViewController;
@property (nonatomic,assign) BOOL isFirstLauch;


@end
