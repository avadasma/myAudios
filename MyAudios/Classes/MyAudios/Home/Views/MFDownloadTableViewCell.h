//
//  MFDownloadTableViewCell.h
//  MyAudios
//
//  Created by chang on 2017/7/31.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MFDownloadTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

-(void)setupCellWithModel:(NSString *)name;
#pragma mark - 根据字符串长度判断cell高度
// 获取指定宽度width的字符串在UITextView上的高度
- (float) heightForString:(NSString *)str andWidth:(float)width;

// 设置选中
- (void)setIfSelected:(BOOL)ifSelected;

@end
