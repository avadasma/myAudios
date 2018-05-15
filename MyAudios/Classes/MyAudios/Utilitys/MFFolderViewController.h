//
//  MFFolderViewController.h
//  MyAudios
//
//  Created by chang on 2018/1/30.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFFolderViewController : MyNavigationViewController

@property(nonatomic,strong) NSString * parentfolderName;// 父文件夹名称
@property(nonatomic,strong) NSArray *moveItems;// 需要移动的文件数组

@end
