//
//  COShareView.m
//  Spring3G
//
//  Created by xu_hui on 14-5-7.
//  Copyright (c) 2014年 SpringAirlines. All rights reserved.
//

#import "COShareView.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "Notify.h"
#import "AppDelegate.h"

@implementation UIButtonCustom
@synthesize index;

@end

@implementation ShareModel
@synthesize nameItem;
@synthesize imageItem;
@synthesize contentItem;

- (id)initWith:(NSString *)_nameItem :(NSString *)_imageItem :(NSString *)_contentItem{
    
    if (self = [super init]) {
        nameItem = [_nameItem copy];
        imageItem = [_imageItem copy];
        contentItem = [_contentItem copy];
    }
    return self;
}

@end

@interface COShareView ()

@property (nonatomic,strong) UIView *shareItemBG;
@property (nonatomic)ShareWay  shareWay;
@property (nonatomic,strong) NSString   *shareContent;      //分享内容  默认所有分享内容都一样
@property (nonatomic,strong) NSArray    *arrayItems;        //所有分享  数组

@end

@implementation COShareView

+(void)showShareViewContent:(NSString*)content{
    
    COShareView *temp = [[COShareView alloc] initWithContent:content];
    [temp addToRootView];
}

+(void)showShareViewModelItems:(NSMutableArray*)modelItems{
    
    COShareView *temp = [[COShareView alloc] initWithModelItems:modelItems];
    [temp addToRootView];
}

- (id)initWithContent:(NSString*)content{

    UIView *rootView = [self rootViewController].view;
    self = [super initWithFrame:rootView.bounds];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.shareWay = ShareDefaultContentSame;
    self.shareContent = content;
    [self initData];
    [self initView];
    return self;
}
    
- (id)initWithModelItems:(NSMutableArray*)modelItems{

    UIView *rootView = [self rootViewController].view;
    self = [super initWithFrame:rootView.bounds];
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
    self.shareWay = ShareCustomContentDiff;
    self.arrayItems = [NSMutableArray arrayWithArray:modelItems];
    [self initData];
    [self initView];
    return self;
}

- (void)addToRootView{
    UIView *rootView = [self rootViewController].view;
    [rootView addSubview:self];
}

- (UIViewController*)rootViewController{
    return [[UIApplication sharedApplication].delegate window].rootViewController;
}

- (void)initData{
    
    NSString *sinaWeibo     = NSLocalizedStringWithInternational(@"MFAboutViewController_01005",@"新浪微博");
    NSString *tencentWechat = NSLocalizedStringWithInternational(@"MFAboutViewController_01019",@"微信");
    NSString *wechatTimeLine = NSLocalizedStringWithInternational(@"MFAboutViewController_01002",@"微信朋友圈");
    NSString *appleSMS      = NSLocalizedStringWithInternational(@"MFAboutViewController_01007",@"短信");
    NSString *appleEmail    = NSLocalizedStringWithInternational(@"MFAboutViewController_01008",@"邮件");
    
    if (self.shareWay==ShareDefaultContentSame) {
        NSMutableArray *arrayData = [NSMutableArray array];
        
        NSMutableArray *arrayItems = [[NSMutableArray alloc]init];
        NSMutableArray *arrayImageItems = [[NSMutableArray alloc]init];
        BOOL weiboAppInstalled = [WeiboSDK isWeiboAppInstalled];
        BOOL wxAppInstalled = [WXApi isWXAppInstalled];
        if (weiboAppInstalled) {
            [arrayItems addObject:sinaWeibo];
            [arrayImageItems addObject:@"xinlang72.png"];
        }
        if (wxAppInstalled){
            [arrayItems addObject:tencentWechat];
            [arrayImageItems addObject:@"weixin72.png"];
            
            [arrayItems addObject:wechatTimeLine];
            [arrayImageItems addObject:@"wechat_c.png"];
        }
        [arrayItems addObject:appleSMS];
        [arrayImageItems addObject:@"sms72.png"];
        
        [arrayItems addObject:appleEmail];
        [arrayImageItems addObject:@"mail72.png"];
        
        for (NSInteger i=0;i<arrayItems.count;i++) {
            
            NSString *nameItem = [arrayItems objectAtIndex:i];
            NSString *imageItem = [arrayImageItems objectAtIndex:i];
            
            ShareModel *shareModel = [[ShareModel alloc] initWith:nameItem :imageItem :self.shareContent];
            [arrayData addObject:shareModel];
        }
        self.arrayItems = [NSArray arrayWithArray:arrayData];
    }
}

#pragma mark UI绘制
- (void)initView{
    
    /* 适配 */
    CGSize buttonSize = CGSizeMake(60,60);
    CGSize lableSize = CGSizeMake(60,20);
    
    CGFloat gapHeight = 10;
    if (self.arrayItems==nil||self.arrayItems.count==0) {
        return;
    }
    
    UIView *bg = [[UIView alloc] init];
    self.shareItemBG = bg;
    [self addSubview:bg];
    
    UIView *segView = [[UIView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.width, 2)];
    [bg addSubview:segView];
    
    UIView *btnBG = [[UIView alloc] init];
    btnBG.backgroundColor = [UIColor whiteColor];
    btnBG.clipsToBounds = YES;
    [bg addSubview:btnBG];
    
    NSString *choice = NSLocalizedStringWithInternational(@"MFAboutViewController_01000",@"沐风影音");
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, self.frame.size.width-20, lableSize.height)];
    title.text = choice;
    title.font = [UIFont systemFontOfSize:18.0];
    title.textAlignment = NSTextAlignmentCenter;
    [btnBG addSubview:title];
    
    //button初始化
    CGRect currentRect = CGRectZero;
    BOOL isFirst = YES;
    for (NSInteger i=0 ;i<[self.arrayItems count] ;i++) {
        
        if (isFirst) {
            isFirst = NO;
            currentRect = CGRectMake(15,title.frame.origin.y+title.frame.size.height+15,
                                     buttonSize.width, buttonSize.height);
        }else{
            if (currentRect.size.width+currentRect.origin.x+buttonSize.width+gapHeight+15>mainScreenWidth) {
                currentRect.origin.x = 15;
                currentRect.origin.y += currentRect.size.height + lableSize.height + gapHeight;
            }else{
                currentRect.origin.x += currentRect.size.width + gapHeight;
            }
        }
        
        ShareModel *shareModel = [self.arrayItems objectAtIndex:i];
        NSString *imagePath = shareModel.imageItem;
        NSString *title = shareModel.nameItem;
        
        UIButtonCustom *button = [UIButtonCustom buttonWithType:UIButtonTypeCustom];
        button.frame = currentRect;
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
        button.index = i;
        [button addTarget:self action:@selector(choiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btnBG addSubview:button];
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x,
                                                                   button.frame.origin.y+buttonSize.height+2,
                                                                   lableSize.width, lableSize.height)];
        lable.font = [UIFont systemFontOfSize:12.0];
        lable.text = title;
        lable.textAlignment = NSTextAlignmentCenter;
        [btnBG addSubview:lable];
        
        if(IS_IOS10){
            lable.font = [UIFont systemFontOfSize:11.0];
        }
        
    }
    bg.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width,
                          currentRect.origin.y+currentRect.size.height+lableSize.height+20);
    btnBG.frame = CGRectMake(0, 2, self.frame.size.width, bg.frame.size.height);
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         bg.frame = CGRectMake(0,
                                               self.frame.size.height-bg.frame.size.height-2,
                                               self.frame.size.width,
                                               bg.frame.size.height+2);
                     }completion:^(BOOL finished) {
                         
                     }];
    
}

#pragma mark button 事件
- (void)choiceBtn:(UIButtonCustom*)button{
    
    [self shareEnter:button.index];
}

#pragma mark 分享入口
- (void)shareEnter:(NSInteger)index{
    
    /*
     *  目前只有四种分享方式,新浪微博,微信,短信,邮件
     *  如有以后有更多的分享方式直接在switch 中添加新的分享即可
     *
     */
    
    if (self.arrayItems==nil||self.arrayItems.count==0) {
        return;
    }
    
    NSString *sinaWeibo     = NSLocalizedStringWithInternational(@"MFAboutViewController_01005",@"新浪微博");
    NSString *tencentWechat = NSLocalizedStringWithInternational(@"MFAboutViewController_01019",@"微信");
    NSString *wechatTimeLine = NSLocalizedStringWithInternational(@"MFAboutViewController_01002",@"微信朋友圈");
    NSString *appleSMS      = NSLocalizedStringWithInternational(@"MFAboutViewController_01007",@"短信");
    NSString *appleEmail    = NSLocalizedStringWithInternational(@"MFAboutViewController_01008",@"邮件");
    NSString *shareFailed   = NSLocalizedStringWithInternational(@"MFAboutViewController_01009",@"分享失败");
    
    //注意国际化问题
    ShareModel  *shareModel = [self.arrayItems objectAtIndex:index];
    NSString    *title      = shareModel.nameItem;
    NSString    *content    = shareModel.contentItem;
    
    if ([sinaWeibo isEqual:title]) {
        [self shareSinaWeibo:content];
    }
    else if ([tencentWechat isEqual:title]){
        [self shareTencenttWeixin:content scene:WXSceneSession];
    }
    else if ([wechatTimeLine isEqual:title]) {
        [self shareTencenttWeixin:content scene:WXSceneTimeline];
    }
    else if ([appleSMS isEqual:title]){
        [self shareAppleSMS:content];
    }
    else if ([appleEmail isEqual:title]){
        [self shareAppleMail:content];
    }
    else{
        [Notify showAlertDialog:self messageString:shareFailed];
    }
    
}

#pragma mark 新浪微博分享
- (void)shareSinaWeibo:(NSString*)content{
    
    if ([WeiboSDK isWeiboAppInstalled]) {
        WBMessageObject *message = [[WBMessageObject alloc] init];
        message.text = content;
        WBSendMessageToWeiboRequest *request = [[WBSendMessageToWeiboRequest alloc] init];
        request.message = message;
        [WeiboSDK sendRequest:request];
    } else {
        NSString *unstallSina = NSLocalizedStringWithInternational(@"MFAboutViewController_01010",@"您还未安装新浪微博");
        [Notify showAlertDialog:self messageString:unstallSina];
    }
    
}

#pragma mark 微信分享
- (void)shareTencenttWeixin:(NSString*)content scene:(int)scene{
    
    if ([WXApi isWXAppInstalled]) {
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.bText = YES;
        req.text = content;
        req.scene = scene;
        [WXApi sendReq:req];
    } else {
        [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01011",@"您还未安装微信客户端！")];
    }
}

#pragma mark 邮件分享
- (void)shareAppleMail:(NSString*)content{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            [self displayMailComposerSheet:content];
        } else {
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01012",@"设备不支持邮件功能或者邮件未配置")];
        }
    }
}

- (void)displayMailComposerSheet:(NSString*)content{
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    NSString *bodyMess=content;
    [controller setSubject:@""];
    [controller setMessageBody:bodyMess isHTML:NO];

    UIViewController *rootVC = [self rootViewController];
    [rootVC presentViewController:controller animated:YES completion:^{}];
}
#pragma mark 邮件分享回调
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01013",@"用户取消发送")];
            break;
        case MFMailComposeResultSaved:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01014",@"已保存")];
            break;
        case MFMailComposeResultSent:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01015",@"已发送")];
            break;
        case MFMailComposeResultFailed:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01016",@"发送失败")];
            break;
        default:
            break;
    }
    
    UIViewController *rootVC = [self rootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:^{}];
    
}


#pragma mark 短信分享

- (void)shareAppleSMS:(NSString*)content{
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            [self displaySMSComposerSheet:content];
        } else {
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01017",@"设备不支持短信功能")];
        }
    }
}

- (void)displaySMSComposerSheet:(NSString*)content{
    
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    UINavigationItem* navigationItem = [[[picker viewControllers]lastObject]navigationItem];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setFrame:CGRectMake(0, 0, 40, 20)];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [button addTarget:self action:@selector(msgBackFun) forControlEvents:UIControlEventTouchUpInside];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    NSString *smsBody = content;
    picker.body = smsBody;
    
    UIViewController *rootVC = [self rootViewController];
    [rootVC presentViewController:picker animated:YES completion:^{}];
    
}
-(void)msgBackFun{
    UIViewController *rootVC = [self rootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark 短信分享回调
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01013",@"用户取消发送")];
            break;
        case MessageComposeResultSent:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01015",@"已发送")];
            break;
        case MessageComposeResultFailed:
            [Notify showAlertDialog:self messageString:NSLocalizedStringWithInternational(@"MFAboutViewController_01016",@"发送失败")];
            break;
        default:
            break;
    }
    
    UIViewController *rootVC = [self rootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark 点击事件代理
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch.view isEqual:self]) {
        [self dismissAnimation];
    }
}

- (void)dismissAnimation {
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.shareItemBG.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width,0);
                         self.shareItemBG.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self removeFromSuperview];
                         }
                     }];
}

@end
