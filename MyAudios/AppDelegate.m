//
//  AppDelegate.m
//  MyAudios
//
//  Created by chang on 2017/7/17.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabbarViewController.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "CustomNavigationController.h"
#import "MFDropBoxViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "MFStringUtil.h"
#import "Notify.h"
#import <EvernoteSDK/EvernoteSDK.h>
#import "PhotoViewController.h"
#import <MSAL/MSAL.h>
#import <OneDriveSDK/OneDriveSDK.h> // OneDrive
#import <Bugly/Bugly.h>
#import "UIDevice+Info.h"

#define advertisingUUID [[UIDevice currentDevice] getCurrentDeviceUUID]

@import BoxContentSDK;

@interface AppDelegate ()<WeiboSDKDelegate, WXApiDelegate>
{
}

@property (strong, nonatomic) RootTabbarViewController * rootTabbarViewController;
@property (nonatomic, strong) CustomNavigationController *navController;
@property (nonatomic) UIBackgroundTaskIdentifier myTaskId;

@end

@implementation AppDelegate
@synthesize navigationController;
@synthesize rootTabbarViewController;
@synthesize navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // 判断当前应用是第一次安装运行，还是升级安装运行
    // 根据软件的版本号判断
    // 获得当前的版本号
    float version = [[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"] floatValue];
    // 如果是升级安装,获取上一次的版本号（偏好设置中）
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float oldVersion = [userDefaults floatForKey:@"version"];
    if (version > oldVersion) {
        // 判断，如果当前版本号，大于之前的版本号，显示新特性界面
        // MFNewFeatureController *vc = [MFNewFeatureController new];
        // self.window.rootViewController = vc;
        // 把当前的版本存储到偏好设置中
        [userDefaults setFloat:version forKey:@"version"];
        [userDefaults synchronize];
        
    }else{
        //否则直接进入app
        //        rootTabbarViewController = [[RootTabbarViewController alloc] init];
        //        rootTabbarViewController.isFirstLauch=NO;
        //        navController=[[CustomNavigationController alloc] initWithRootViewController:rootTabbarViewController];
        //        [self.window setRootViewController:navController];
    }
    
    rootTabbarViewController = [[RootTabbarViewController alloc] init];
    rootTabbarViewController.isFirstLauch=NO;
    navController=[[CustomNavigationController alloc] initWithRootViewController:rootTabbarViewController];
    [navController setNavigationBarHidden:YES];
  
    [self.window setRootViewController:navController];
    
//    // AppDelegate 进行全局设置
//    if (@available(iOS 11.0, *)){
//        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
//    }
    
    // 第三方配置
    [self integratThirdParty:launchOptions];
    // 整合bugly
    [self integratedBugly];
    
    // 程序启动时设置音频会话
    // 一般在方法：application: didFinishLaunchingWithOptions:设置
    // 获取音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // 设置类型是播放。
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    // 激活音频会话。静音状态下播放
    // [session setActive:YES error:nil];
    // 别的程序正在播放，打开本app时，不要打断它的播放
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
        [session setActive:NO error:nil];
    }
    // Remote Control控制音乐的播放,声明接收Remote Control事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // 处理电话打进时中断音乐播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionNotificationHandler:) name:AVAudioSessionInterruptionNotification object:nil];
    // 在App启动后开启远程控制事件, 接收来自锁屏界面和上拉菜单的控制
    [application beginReceivingRemoteControlEvents];
    // 处理远程控制事件
    [self remoteControlEventHandler];
    
    return YES;
}

// 重写方法，成为第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype)
    {
        case UIEventSubtypeRemoteControlPlay:
            //play
            break;
        case UIEventSubtypeRemoteControlPause:
            //pause
            break;
        case UIEventSubtypeRemoteControlStop:
            //stop
            break;
        default:
            break;
    }
}
// 在需要处理远程控制事件的具体控制器或其它类中实现
- (void)remoteControlEventHandler
{
    /*
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        [[MusicPlayTools shareMusicPlay] musicPlay];
        [[MusicPlayViewController shareMusicPlay] configNowPlayingInfoCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了暂停
        [[MusicPlayTools shareMusicPlay] musicPause];
        [[MusicPlayViewController shareMusicPlay] configNowPlayingInfoCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了上一首
        [[MusicPlayViewController shareMusicPlay] lastSongAction];
        [[MusicPlayViewController shareMusicPlay] configNowPlayingInfoCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了下一首
        [[MusicPlayViewController shareMusicPlay] nextSongButtonAction:nil];
        [[MusicPlayViewController shareMusicPlay] configNowPlayingInfoCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        // 进行播放/暂停的相关操作 (耳机的播放/暂停按钮)
        [[MusicPlayViewController shareMusicPlay] playPauseButtonAction:nil];
        [[MusicPlayViewController shareMusicPlay] configNowPlayingInfoCenter];
        return MPRemoteCommandHandlerStatusSuccess;
    }];*/
}

-(void)interruptionNotificationHandler:(id)sender {
    
}


#pragma mark - 集成第三方
-(void)integratThirdParty:(NSDictionary *)launchOptions {
    
    // 集成DropBox
    [self integratedDropBox:launchOptions];
    // 集成微信、微博
    [self integrateThirdParty];
    // 集成印象笔记
    [self setupEverNote];
    // 集成Box
    [BOXContentClient setClientID:boxAppKey clientSecret:boxAppSecret];
    
    // 集成 GoogleDrive
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [GIDSignIn sharedInstance].delegate = self;
    
    // 集成 OneDrop
    [self integratedOneDrop:launchOptions];
    
}



- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.sina.weibo"]) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.xin"]){
        
        return [WXApi handleOpenURL:url delegate:self];
    }else if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isEqualToString:@"com.tencent.mqq"]){
        
        //[WTShareManager didReceiveTencentUrl:url];
        //return [TencentOAuth HandleOpenURL:url];
    }
    
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            
            //            MFDropBoxViewController *dropBoxViewController = [[MFDropBoxViewController alloc] init];
            //            dropBoxViewController.searchPath = @"";
            //            self.navigationController.hidesBottomBarWhenPushed = YES;
            //            [self.navigationController pushViewController:dropBoxViewController animated:YES];
            
            
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GIDSignIn sharedInstance] handleURL:url
                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    });
    
    [MSALPublicClientApplication handleMSALResponse:url];
    
    return YES;
}



#pragma mark 微信分享
-(void)integrateThirdParty {
    [WXApi registerApp:wxAppId];
    [WeiboSDK registerApp:weiboAppKey];
}

#pragma mark - 集成DropBox
-(void)integratedDropBox:(NSDictionary *)launchOptions {
    
    [DBClientsManager setupWithAppKey:dropboxAppKey];
    
}
#pragma mark - 集成 OneDrop
-(void)integratedOneDrop:(NSDictionary *)launchOptions {
    
   // [ODClient setMicrosoftAccountAppId:kClientID scopes:@[@"onedrive.readwrite"] ];
   // 要使用下面这个设置，上面的不能缓存已登录状态
   [ODClient setMicrosoftAccountAppId:kClientID scopes:@[@"wl.signin,wl.offline_access,onedrive.readwrite"] ];
}

#pragma mark Bugly 接入
- (void)integratedBugly{
    BuglyConfig *config = [[BuglyConfig alloc] init];
    config.blockMonitorEnable = YES; //是否开启主线程卡顿监控上报功能
    config.channel = AppChannel;
    config.version = appVersionNo;
    config.deviceIdentifier = advertisingUUID;
    config.debugMode = NO;
    [Bugly startWithAppId:buglyAppID config:config];
}

#pragma mark - 集成印象笔记
-(void)setupEverNote {

   [ENSession setSharedSessionConsumerKey:everNoteAppId consumerSecret:everNoteAppSecret optionalHost:ENSessionHostSandbox];

}


#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}


-(void)applicationWillResignActive:(UIApplication *)application
{
    // 开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session=[AVAudioSession sharedInstance];
    // 别的程序正在播放，打开本app时，不要打断它的播放
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
        [session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
    // 后台播放
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    // 这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
    _myTaskId=[AppDelegate backgroundPlayerID:_myTaskId];
    
    
}
// 实现一下backgroundPlayerID:这个方法:
+(UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
{
    // 设置并激活音频会话类别
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 别的程序正在播放，打开本app时，不要打断它的播放
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
        [session setActive:NO error:nil];
    }
    // 允许应用程序接收远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // 设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid && backTaskId != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:self];
    [WeiboSDK handleOpenURL:url delegate:self];
    
    return YES;
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
 
    
    if ([sourceApplication isEqualToString:@"com.sina.weibo"]) {
        
        return [WeiboSDK handleOpenURL:url delegate:self];
        
    }else if ([sourceApplication isEqualToString:@"com.tencent.xin"]){
        
        return [WXApi handleOpenURL:url delegate:self];
        
    }else if ([sourceApplication isEqualToString:@"com.tencent.mqq"]){
        
        //[WTShareManager didReceiveTencentUrl:url];
        //return [TencentOAuth HandleOpenURL:url];
    }
    
     dispatch_async(dispatch_get_main_queue(), ^{
            // 集成 GoogleDrive
            [[GIDSignIn sharedInstance] handleURL:url
                                sourceApplication:sourceApplication
                                       annotation:annotation];
     });
    
    BOOL ifSuccess = [MSALPublicClientApplication handleMSALResponse:url];
    NSLog(@"if MSALPublicClientApplication handleMSALResponse Success == %d",ifSuccess);
    
    return YES;
}

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations on signed in user here.
//    NSString *userId = user.userID;                  // For client-side use only!
//    NSString *idToken = user.authentication.idToken; // Safe to send to the server
//    NSString *fullName = user.profile.name;
//    NSString *givenName = user.profile.givenName;
//    NSString *familyName = user.profile.familyName;
//    NSString *email = user.profile.email;
    // ...
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    // Perform any operations when the user disconnects from app here.
    // ...
}




#pragma mark - 新浪微博登录回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        NSString *title = @"发送结果";
        NSString * message;
        if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            message = @"用户取消发送";
        }else if (response.statusCode == WeiboSDKResponseStatusCodeSuccess){
            message = @"发送成功";
            [[NSNotificationCenter defaultCenter] postNotificationName:@"WeiXinShareRespond" object:nil];
        }else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown){
            message = @"发送失败";
        }
        [Notify showAlertDialog:nil titleString:title messageString:message];

    }else if ([response isKindOfClass:WBAuthorizeResponse.class]) {
        NSString *title = @"发送结果";
        NSString *message = nil;
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            
            WBAuthorizeResponse * weiboResponse = (WBAuthorizeResponse *)response;
            NSString* accessToken = weiboResponse.accessToken;
            if (accessToken){
                self.wbtoken = accessToken;
            }
            NSString* userID = weiboResponse.userID;
            if (userID) {
                self.wbCurrentUserID = userID;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SinaWeiBoShareLoginRespond" object:nil];
            
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancel) {
            message = @"用户取消发送";
        } else if (response.statusCode == WeiboSDKResponseStatusCodeSentFail) {
            message = @"发送失败";
        } else if (response.statusCode == WeiboSDKResponseStatusCodeAuthDeny) {
            message = @"授权失败";
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUserCancelInstall) {
            message =  @"用户取消安装微博客户端";
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnsupport) {
            message = @"不支持的请求";
        } else if (response.statusCode == WeiboSDKResponseStatusCodeUnknown) {
            message = @"未知错误";
        } else {
            message = @"未知错误";
        }
        if (![MFStringUtil isEmpty:message]) {
            [Notify showAlertDialog:self titleString:title messageString:message];
        }
        
    }else{
        
    }
}
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    NSLog(@"============didReceiveWeiboRequest================");
}


#pragma mark - 微信回调
// 是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面。
-(void) onReq:(BaseReq*)reqonReq {
     NSLog(@"============weixin onReq================");
}

// 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面。
-(void) onResp:(BaseResp*)resp {
      NSLog(@"============weixin onResp================");
}

// 如果你的程序要发消息给微信，那么需要调用WXApi的sendReq函数：
-(BOOL) sendReq:(BaseReq*)req {
    NSLog(@"============weixin sendReq================");
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // 别的程序正在播放，打开本app时，不要打断它的播放
    if ([AVAudioSession sharedInstance].otherAudioPlaying) {
        // OSStatus ret = AudioSessionSetActiveWithFlags(NO, kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation);
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
