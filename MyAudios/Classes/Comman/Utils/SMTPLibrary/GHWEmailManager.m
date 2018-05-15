//
//  EmailManager.m
//  mail
//
//  Created by 朱斌 on 13/07/2017.
//  Copyright © 2017 朱斌. All rights reserved.
//

#import "GHWEmailManager.h"
#import "SKPSMTPMessage.h"
#import "GHWCrashHandler.h"

@interface GHWEmailManager ()<SKPSMTPMessageDelegate>

@property (nonatomic, copy) NSString *fromEmail;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *toEmail;
@property (nonatomic, copy) NSString *relayHost;

@end

@implementation GHWEmailManager

+ (GHWEmailManager*)shareInstance
{
    static dispatch_once_t onceToken;
    static GHWEmailManager * emailManager;
    dispatch_once(&onceToken, ^{
        emailManager = [[GHWEmailManager alloc] init];
    });
    return emailManager;
}

- (void)configWithFromEmail:(NSString *)fromEmail andPasswod:(NSString *)password andToEmail:(NSString *)toEmail andRelayHose:(NSString *)relayHost
{
    self.fromEmail = fromEmail;
    self.password = password;
    self.toEmail = toEmail;
    self.relayHost = relayHost;
}





-(void)sendEmail:(NSString*)content
{
    // qq邮箱示例
//    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
//    myMessage.delegate = self;
//    myMessage.fromEmail = @"564448895@qq.com";//self.fromEmail;//发送者邮箱
//    myMessage.pass = @"bfeiasrnumlwbdhd";//self.password;//发送者邮箱的密码  qq邮箱授权码： bfeiasrnumlwbdhd
//    myMessage.login = @"564448895@qq.com";//self.fromEmail;//发送者邮箱的用户名
//    myMessage.toEmail = @"564448895@qq.com";//@"changyou_dev@163.com";//self.toEmail;//收件邮箱
//    //myMessage.bccEmail = @"******@qq.com";//抄送
//    myMessage.relayHost = @"smtp.qq.com";//self.relayHost;


    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
    myMessage.fromEmail = @"ichangyou@126.com"; //发送邮箱
    myMessage.toEmail = @"changyou0730@126.com"; //收件邮箱
    // myMessage.bccEmail = @"564448895@qq.com";//抄送

    myMessage.relayHost = @"smtp.126.com";//发送地址host 网易企业邮箱
    myMessage.requiresAuth = YES;
    myMessage.login = @"changyou";//发送邮箱的用户名
    myMessage.pass = @"developer123";//发送邮箱的密码 授权码 developer123

    myMessage.wantsSecure = YES;
    myMessage.delegate = self;



//    SKPSMTPMessage *myMessage = [[SKPSMTPMessage alloc] init];
//    myMessage.delegate = self;
//    myMessage.fromEmail = @"ichangyou@126.com";//self.fromEmail;//发送者邮箱
//    myMessage.pass = @"developer123";//126授权码
//    myMessage.login = @"ichangyou@126.com";//self.fromEmail;//发送者邮箱的用户名
//    myMessage.toEmail = @"ichangyou@126.com";//@"changyou_dev@163.com";//self.toEmail;//收件邮箱
//    //myMessage.bccEmail = @"******@qq.com";//抄送
//    myMessage.relayHost = @"smtp.126.com";//self.relayHost;
    //myMessage.requiresAuth = YES;
    //myMessage.wantsSecure = YES;//为gmail邮箱设置 smtp.gmail.com
    // myMessage.subject = @"iOS崩溃日志";//邮件主题
    myMessage.subject = @"对沐风影音的反馈：";//邮件主题
    /* >>>>>>>>>>>>>>>>>>>> *   设置邮件内容   * <<<<<<<<<<<<<<<<<<<< */
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain; charset=UTF-8",kSKPSMTPPartContentTypeKey, content,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];

    myMessage.parts = [NSArray arrayWithObjects:plainPart,nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [myMessage send];
    });
    
    
    
    
}

#pragma mark - SKPSMTPMessageDelegate
- (void)messageSent:(SKPSMTPMessage *)message
{
    NSLog(@"发送邮件成功");
    [[GHWCrashHandler sharedInstance] configDismissed];

}
- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSLog(@"message - %@\nerror - %@", message, error);
}

@end
