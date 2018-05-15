//
//  AudiosPlayerViewController.h
//  MyAudios
//
//  Created by chang on 2017/8/1.
//  Copyright © 2017年 chang. All rights reserved.
//
//  音频播放控制类

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MyNavigationViewController.h"

@interface AudiosPlayerViewController : MyNavigationViewController

@property(nonatomic,strong) AVPlayer * player;// 当前播放器
@property(nonatomic,strong) NSString * fileName;// 文件名称
@property(nonatomic,strong) NSString * parentfolderName;// 父文件名称

@end
