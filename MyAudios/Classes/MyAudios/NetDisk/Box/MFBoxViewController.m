//
//  MFBoxViewController.m
//  MyAudios
//
//  Created by chang on 2017/11/14.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFBoxViewController.h"
#import "BOXSampleFolderViewController.h"
#import "Notify.h"

@import BoxContentSDK;

@interface MFBoxViewController ()

@end

@implementation MFBoxViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cutomTitleLbl.text = @"Box";

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 登录事件
- (IBAction)loginBoxBtnClicked:(id)sender {
    
    [[BOXContentClient defaultClient] authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
        if (error == nil) {
    
            // 延迟 1s 执行跳转,否则可能不跳转
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                BOXContentClient *client = [BOXContentClient clientForUser:user];
                BOXSampleFolderViewController *folderListingController = [[BOXSampleFolderViewController alloc] initWithClient:client folderID:BOXAPIFolderIDRoot];
                [self.navigationController pushViewController:folderListingController animated:YES];
            });
            
        }else{
            if (error.code!=998) {// 用户取消
               [Notify showAlert:self titleString:@"错误提示" messageString:@"登录失败，请重试..." actionStr:@"确定"];
            }
        }
    }];
    
}

@end
