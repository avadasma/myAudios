//
//  MFAboutViewController.m
//  MyAudios
//
//  Created by chang on 2017/9/5.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFAboutViewController.h"
#include <CoreFoundation/CFString.h>

@interface MFAboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *appNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *versionLbl;

@end

@implementation MFAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于";
    // 设置版本号
    [self customVersionNo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
// 设置版本号
-(void)customVersionNo {

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    // app版本
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    // NSString *app_build = [infoDictionary objectForKey:@"CFBundleVersion"];
    self.appNameLbl.text = [NSString stringWithFormat:@"%@",app_Name];
    self.versionLbl.text = [NSString stringWithFormat:@"version %@",app_Version];
    
}


@end
