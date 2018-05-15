//
//  MFFolderTableViewCell.h
//  MyAudios
//
//  Created by chang on 2018/1/30.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MFFolder;

@interface MFFolderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgVIew;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;

// 根据 MFFolder 配置 cell 内容
- (void)configureForFolder:(MFFolder *)folder;

@end
