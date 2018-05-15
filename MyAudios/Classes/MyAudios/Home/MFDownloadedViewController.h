//
//  MFDownloadedViewController.h
//  MyAdios
//
//  Created by chang on 2017/7/15.
//  Copyright © 2017年 chang. All rights reserved.
//
//  分类 - 下载听

#import <UIKit/UIKit.h>
#import "MyNavigationViewController.h"

@interface MFDownloadedViewController : MyNavigationViewController

@property(nonatomic) BOOL isPlayList;// 是否是播放列表
@property(nonatomic,strong) NSString * parentfolderName;// 父文件夹名称
//@property(nonatomic,strong) NSString * folderName;// 当前文件夹名称
@property(nonatomic,strong) NSString * fileName;// 当前文件名称
@property (weak, nonatomic) IBOutlet UITableView *myTableView;


@end
