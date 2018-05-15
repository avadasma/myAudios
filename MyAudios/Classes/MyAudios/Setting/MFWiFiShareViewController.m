//
//  MFWiFiShareViewController.m
//  MyAudios
//
//  Created by chang on 2017/10/23.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFWiFiShareViewController.h"
#import "MFIPHelper.h"
#import <GCDWebUploader.h>

@interface MFWiFiShareViewController ()
{
    GCDWebUploader* _webUploader;
}
@property (weak, nonatomic) IBOutlet UILabel *urlAddressLbl;// 网址链接

@end

@implementation MFWiFiShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"通过 Wi-Fi 传输文件";
    NSString *ipAddress = [MFIPHelper deviceIPAdress];
    if([self isValidIP:ipAddress]){
        [self startHttpServer];
    }else{
        self.urlAddressLbl.text =  @"请确定您的 WiFi 是否已打开";
    }
    
    //设置窗口亮度大小  范围是0.1 -1.0
    // [[UIScreen mainScreen] setBrightness:0.5];
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (_webUploader) {
        [_webUploader stop];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *判断一个字符串是否是一个IP地址
 **/
- (BOOL)isValidIP:(NSString *)ipStr {
    if (nil == ipStr) {
        return NO;
    }
    
    NSArray *ipArray = [ipStr componentsSeparatedByString:@"."];
    if (ipArray.count == 4) {
        for (NSString *ipnumberStr in ipArray) {
            int ipnumber = [ipnumberStr intValue];
            if (!(ipnumber>=0 && ipnumber<=255)) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark - 集成 HttpServer
-(void)startHttpServer {
    
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
    [_webUploader start];
    self.urlAddressLbl.text = [NSString stringWithFormat:@"%@",_webUploader.serverURL];
    NSLog(@"Visit %@ in your web browser", _webUploader.serverURL);

}
@end
