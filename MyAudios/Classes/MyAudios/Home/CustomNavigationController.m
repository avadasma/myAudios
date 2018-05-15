//
//  CustomNavigationController.m
//  MufengEnglish
//
//  Created by chang on 15/3/15.
//  Copyright (c) 2015年 chang. All rights reserved.
//

#import "CustomNavigationController.h"
#import "MyNavigationViewController.h"


@interface CustomNavigationController ()<UINavigationControllerDelegate>

@property(nonatomic,assign)BOOL animating;
@property (nonatomic,strong) UIButton *lButton;
@property (nonatomic, strong)  UITapGestureRecognizer * tapGesture;

@end

@implementation CustomNavigationController
@synthesize animating;
@synthesize lButton;
@synthesize tapGesture;


- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.delegate = self;
        
    }
    
    if (IS_IOS7) {
        // iOS 7.0 or later
        self.navigationBar.barTintColor = [UIColor colorWithRed:36.0/255.0 green:35.0/255.0 blue:36.0/255.0 alpha:1.0];
        self.navigationBar.translucent = YES;
        self.navigationBar.barStyle = UIBarStyleBlack;
        
    }else {
        // iOS 6.1 or earlier
        self.navigationBar.tintColor = COLOR(255.0f, 255.0f, 255.0f, 1.0);
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (animating == YES) {
        return;
    }
    animating = YES;
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    animating = NO;
}

#pragma mark - 返回上一页
- (IBAction)backPrePage:(id)sender{
    if (self.navigationController.topViewController != self) {
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark- 撤销软键盘
- (IBAction)hiddenKeyboard:(id)sender {
    [self.view endEditing:YES];
}


@end
