//
//  MacroDefine.h
//
//  Created by changyou on 17-07-12.
//  Copyright (c) 2015年 SpringAirlines. All rights reserved.
//

#define isIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height==2436 : NO)
// #define IS_IPHONE_X  (CGSizeEqualToSize(CGSizeMake(375, 812),[[UIScreen mainScreen] bounds].size)?YES:NO)

#define IS_IPHONE_6_PLUS  (fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)414) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen] bounds].size.width - (double)375) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_4 ([[UIScreen mainScreen] bounds].size.height)<568

#define IS_IOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IOS9 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
#define IS_IOS10 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)
#define IS_IOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)

#define kSystemVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#define mainScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define mainScreenHeight ([[UIScreen mainScreen] bounds].size.height)

#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight ([[UIScreen mainScreen] bounds].size.height)


#define screenWidthRadio (mainScreenWidth/320.0)
#define screenHeightRadio (mainScreenHeight/568.0)

// 适配屏幕常用宏 chang
#define ScalingSmallestScreenHeight (mainScreenHeight<568?568:mainScreenHeight)
#define ScalingWidth(a) ((mainScreenWidth*a)/320.0)
#define ScalingHeight(b) ((ScalingSmallestScreenHeight*b)/568)

//基于iPhone6尺寸的宏
#define baseSize_iphone6_widthRadio (mainScreenWidth/375.0)
#define baseSize_iphone6_heightRadio (mainScreenHeight/667.0)

#define ScalingIphone6Width(a) ((mainScreenWidth*a)/375.0)
#define ScalingIphone6Height(b) ((mainScreenHeight*b)/667.0)

// 设置颜色宏 参数格式为：0xFFFFFF
#define kColorWithRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
                 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]

// 获得RGB颜色
#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]

#pragma mark --------基础控件默认尺寸 开始------------------------
//iPhoneX适配
#define kNavigationHeight       (isIPhoneX?88:64) //状态栏+顶部导航栏高度
#define kTopDangerAreaHeight    44 //iPhoneX顶部危险区高度
#define kBottomDangerAreaHeight (isIPhoneX?34:0) //iPhoneX底部危险区高度
#define kContentViewHeight      (kScreenHeight-kNavigationHeight-kBottomDangerAreaHeight)//屏幕高度-顶部导航高度-底部危险区高度，中间内容视图的高度

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)


#define kNavigationBarHeight    44   //导航栏
#define kToolBarHeight          44   //UIToolBar
#define kLableHeight            21   //UILabel
#define kTableViewCellHeight    44   //UITableViewCell
#define kButtonHeight           30   //UIButton
#define kSegmentedControlHeight 29   //UISegmentedControl
#define kSliderHeight           31   //UISlider
#define kSwitchWidth            51   //UISwitch Width
#define kSwitchHeight           31   //UISwitch Height
#define kLargeWhiteActivityIndicatorHeight  37  //Large White Activity Indicator
#define kActivityIndicatorHeight  20  //Activity Indicator
#define kProgressViewHeight       2   //UIProgressView
#define kPageControlHeight        37  //UIPageControl
#define kStepperWidth             94  //UIStepper Width
#define kStepperHeight            29  //UIStepper Height
#define kPickerViewHeight         162 //UIPickerView

/*****宏定义 *****/
// 导航栏高度
#define  MFNavBarHeight  isIPhoneX ? 88 : 64
// 底部Tabbar 高度
#define  MFTabBarHeight  isIPhoneX ? 83 : 44
// 状态栏高度
#define  MFStatusBarHeight  isIPhoneX ? 44 : 20


#pragma mark --------常量设置 开始-------------------------
#define advertisingUUID [[UIDevice currentDevice] getCurrentDeviceUUID]
#define vendorUUID [[UIDevice currentDevice] getCurrentDeviceUUID]
#define appVersionNo [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define deviceSNPlus [[UIDevice currentDevice] getSecuretCurrentDeviceUUID]


#pragma mark ------常量设置 结束----------------------------

#define COLOR(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// MJRefresh
#define MJRefreshFooterPullToRefresh @"上拉可以加载更多数据"
#define MJRefreshFooterReleaseToRefresh @"松开立即加载更多数据"
#define MJRefreshFooterRefreshing  @"正在帮你加载数据..."
#define MJRefreshFooterNoMore @"没有更多数据了";

#define MJRefreshHeaderRefreshing  @"正在帮你加载数据..."
#define MJRefreshHeaderPullToRefresh @"上拉可以刷新"
#define MJRefreshHeaderReleaseToRefresh @"松开立即刷新"


// app 信息设置
#define  kAppShareUrl            @"appShareUrl"// 我的--关于--应用分享
#define setting_IOS7_Up_Grade    @"https://itunes.apple.com/app/id1367826005"//去评分，iOS7以上使用

//App发版本渠道,发布到苹果商店时，使用MyAudios,不需要修改。发布到越狱渠道时，注意修改此字段,打包前注意修改此字段
#define AppChannel   @"MyAudios"
#define AdTrackingAppChannel   @"AppStore"

//========bugly=========
#define buglyAppKey @"*********************"
#define buglyAppID  @"*******"

// 云盘
// dropbox 信息
#define dropboxAppKey  @"*******"
#define dropboxAppSecret  @"*******"

// box 配置信息
#define boxAppKey  @"*******"
#define boxAppSecret  @"*******"

// 定义 OneDrive 配置
#define kClientID  @"*******"
#define kAuthority  @"https://login.microsoftonline.com/common/v2.0"
#define kGraphURI @"https://graph.microsoft.com/v1.0/me/"
// #define kScopes: [String] = ["https://graph.microsoft.com/user.read"]

// 第三方平台
// 微博共享
#define weiboAppKey  @"*******"
#define weiboAppSecret  @"*******"
#define kRedirectURI    @"http://www.sina.com"

// 微信 joeychang 沐风影音
#define wxAppId @"*******"
#define wxAppSecret @"*******"

// 印象笔记
#define everNoteAppId @"*******"
#define everNoteAppSecret @"*******"

static void *ProgressObserverContext = &ProgressObserverContext;
