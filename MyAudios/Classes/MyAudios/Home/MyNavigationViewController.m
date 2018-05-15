//
//  MyNavigationViewController.m
//  MyNavi
//
//  Created by juuman on 14-1-15.
//  Copyright (c) 2014年 Joeychang.me. All rights reserved.
//

#import "MyNavigationViewController.h"
#import "MFStringUtil.h"

#define CUSTOMTITLEVIEWWIDTH mainScreenWidth - 135

@interface MyNavigationViewController ()
@property (nonatomic, strong)  UITapGestureRecognizer * tapGesture;
@end

@implementation MyNavigationViewController
@synthesize cancalHttpArr;
@synthesize lButton;
@synthesize animating;
@synthesize tapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self customInitTitleView];
        
    }
    return self;
}


-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    if ([self.navigationController.viewControllers count]<=1) {
        
        [self.navigationItem setLeftBarButtonItem:nil];
    }
    [self customTitleView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    cancalHttpArr=[[NSMutableArray alloc]init];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    if (IS_IOS7) {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:36.0/255.0 green:35.0/255.0 blue:36.0/255.0 alpha:1.0]; // 微信颜色
        self.navigationController.navigationBar.translucent = YES;
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        
    }else {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = COLOR(255.0f, 255.0f, 255.0f, 1.0);
    }
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIBarButtonItem *leftButton = nil ;
     lButton = [[UIButton alloc] init];
    lButton.frame=CGRectMake(0, 0, 52, 20);
    [lButton setImage:[UIImage imageNamed:@"navigationBack.png"] forState:UIControlStateNormal];
    [lButton setBackgroundColor:[UIColor clearColor]];
    if (IS_IOS7) {
        [lButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 40)];
    }
    else{
        [lButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 30)];
    }
    
    [lButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [lButton addTarget:self action:@selector(backPrePage:) forControlEvents:UIControlEventTouchUpInside];
    lButton.exclusiveTouch=YES;
    
    leftButton = [[UIBarButtonItem alloc] initWithCustomView:lButton];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    // 用自定义的 UIBarButtonItem 替换 navigationController 的 backBarButtonItem 记住是 backBarButtonItem 而不是 leftBarButtonItem ，如果你不小心替换成了 leftBarButtonItem ，那么会直接导致侧滑手势失效
    // [self.navigationItem setBackBarButtonItem:leftButton];
    // self.navigationController.interactivePopGestureRecognizer.enabled = YES;   //启用侧滑手势
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardResign)];
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma nark - 自定义方法
// 初始化自定义titleView
-(void)customInitTitleView {
    // 初始化自定义 titleView
    _navTitleView = [UIView new];
    _cutomTitleLbl = [[UILabel alloc] init];
    _cutomTitleLbl.textAlignment = NSTextAlignmentCenter;
    _cutomTitleLbl.font = [UIFont boldSystemFontOfSize:17.0];
    _cutomTitleLbl.textColor = [UIColor whiteColor];
    _navTitleView.frame = CGRectMake(0.0, 0.0, CUSTOMTITLEVIEWWIDTH, 44.0);
    // 优化因返回按钮造成的居中偏移
    if (self.navigationController.viewControllers.count>1) {
        _cutomTitleLbl.frame  = CGRectMake(-9.0, 0.0, CUSTOMTITLEVIEWWIDTH, 44.0);
    }else{
        _cutomTitleLbl.frame  = CGRectMake(0.0, 0.0, CUSTOMTITLEVIEWWIDTH, 44.0);
    }
    [_navTitleView addSubview:_cutomTitleLbl];
    
    self.navigationItem.titleView = _navTitleView;
}

#pragma mark - 自定义 titleView
- (void)customTitleView {
    
    // 截取title后文件后缀，如.mp3
    NSString *titleStr = self.navigationItem.title;
    if (![MFStringUtil isEmpty:self.title]) {
        titleStr = self.title;
    }
    if ([titleStr containsString:@"."]) {
        NSArray *strArr = [titleStr componentsSeparatedByString:@"."];
        if (strArr.count>0) {
            titleStr = [strArr objectAtIndex:0];
        }
    }
    if ([titleStr containsString:@"/"]) {
        NSArray *strArr = [titleStr componentsSeparatedByString:@"/"];
        if (strArr.count>0) {
            titleStr = [strArr lastObject];
        }
    }
    _cutomTitleLbl.text = titleStr;
}


- (void)centerViewClicked {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - 添加返回取消URL
-(void)addCancalHttpArrWithURLString:(NSString*) string andParams:(NSDictionary *)paramDict{
    NSDictionary *dic=[[NSDictionary alloc]initWithObjectsAndKeys:string,@"URLString",paramDict,@"Params",nil];
    [cancalHttpArr addObject:dic];
}

#pragma mark - 取消URL
-(void)cancalHttp{

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

#pragma mark- 撤销软键盘
-(void)keyBoardResign {
    [self.view endEditing:YES];
}


#pragma mark - 返回首页
-(IBAction)toRootPage:(id)sender{
    
    [self hiddenKeyboard:nil];
    [self cancalHttp];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}


#pragma mark - 屏幕旋转相关设置

- (BOOL)shouldAutorotate {
    return NO;
}

//返回支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//由模态推出的视图控制器 优先支持的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}



@end
