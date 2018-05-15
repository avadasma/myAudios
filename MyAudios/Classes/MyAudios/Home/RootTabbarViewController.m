//
//  RootTabbarViewController.m
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "RootTabbarViewController.h"
#import "MFNetDiscViewController.h"
#import "MFDownloadedViewController.h"
#import "MFSettingViewController.h"
#import "CustomNavigationController.h"

@interface RootTabbarViewController ()<UITabBarControllerDelegate>

@end

@implementation RootTabbarViewController

#pragma mark - UIView LifeCycle Methods

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setTintColerForIOS6];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - UITabBarControllerDelegate Methods

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{

    return YES;
}

#pragma mark - Custom Methods

-(void)addSubViews {
    if(self.viewControllers.count>0){
        self.viewControllers =nil;
    }
    
    // 云服务
    MFNetDiscViewController * discViewController = [[MFNetDiscViewController alloc] initWithNibName:@"MFNetDiscViewController" bundle:nil];
    UITabBarItem * itemListening = [self WithTitle:@"云服务" FinishedUnselectedImage:[UIImage imageNamed:@"tabbar_find_n"] selectedImage:[UIImage imageNamed:@"tabbar_find_h"] tag:0];
    discViewController.tabBarItem = itemListening;
    CustomNavigationController * navNetDisc = [[CustomNavigationController alloc]initWithRootViewController:discViewController];
    
    // 下载听
    MFDownloadedViewController * downloadedVC =[[MFDownloadedViewController alloc] initWithNibName:@"MFDownloadedViewController" bundle:nil];
    UITabBarItem *itemArtical = [self WithTitle:@"下载听" FinishedUnselectedImage:[UIImage imageNamed:@"tabbar_download_n"] selectedImage:[UIImage imageNamed:@"tabbar_download_h"] tag:1];
    downloadedVC.tabBarItem = itemArtical;
    CustomNavigationController * navDownloaded = [[CustomNavigationController alloc]initWithRootViewController:downloadedVC];
    
    // 设置
    MFSettingViewController * settingVC = [[MFSettingViewController alloc] initWithNibName:@"MFSettingViewController" bundle:nil];
    UITabBarItem * itemSetting = [self WithTitle:@"我的" FinishedUnselectedImage:[UIImage imageNamed:@"tabbar_me_n"] selectedImage:[UIImage imageNamed:@"tabbar_me_h"] tag:2];
    settingVC.tabBarItem = itemSetting;
    CustomNavigationController * navMyAccount = [[CustomNavigationController alloc]initWithRootViewController:settingVC];
    self.viewControllers = [NSArray arrayWithObjects:navNetDisc,navDownloaded,navMyAccount ,nil];
    
    self.selectedIndex=0;
    self.delegate=self;
}

-(UITabBarItem*)WithTitle:(NSString*)title FinishedUnselectedImage:(UIImage *)unselectedImage selectedImage:(UIImage *)selectedImage  tag:(NSInteger)tag{
    if(IS_IOS7){
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        unselectedImage = [unselectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:@"" image:unselectedImage selectedImage:selectedImage];
    // 设置图片间距
    item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    
    return item;
}


-(void)setTintColerForIOS6{
    if (!IS_IOS7) {
        
        self.tabBarItem =[[UITabBarItem alloc] initWithTitle:nil image:[UIImage new] selectedImage:[UIImage new]];
        
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
        [[UITabBarItem appearance] setTitleTextAttributes:
         @{ NSShadowAttributeName: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
            NSForegroundColorAttributeName: COLOR(32.0f, 123.0f, 86.0f, 1.0)}  forState:UIControlStateSelected];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage new]];
        
        
    }else{
        self.tabBar.translucent=NO;
        [self.tabBar setTintColor:COLOR(32.0f, 123.0f, 86.0f, 1.0)];
        
    }
    
}



@end
