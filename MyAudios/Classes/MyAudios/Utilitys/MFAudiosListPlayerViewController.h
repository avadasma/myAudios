//
//  MFAudiosListPlayerViewController.h
//  MyAudios
//
//  Created by chang on 2017/8/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MyNavigationViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MFAudiosListPlayerViewController : MyNavigationViewController

@property(nonatomic,strong) NSString * folderName;// 父文件夹名称
@property(nonatomic,strong) NSString * fileName;// 文件名称
@property(nonatomic,strong) NSString * parentfolderName;// 父文件名称

@end
