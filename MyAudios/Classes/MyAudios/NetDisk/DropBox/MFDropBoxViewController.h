//
//  MFDropBoxViewController.h
//  MyAdios
//
//  Created by chang on 2017/7/16.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyNavigationViewController.h"

@interface MFDropBoxViewController : MyNavigationViewController

@property(nonatomic,strong)NSMutableArray *dataArray;// 数据源数组
@property(nonatomic,strong)NSString *searchPath;// 查找路径

@end
