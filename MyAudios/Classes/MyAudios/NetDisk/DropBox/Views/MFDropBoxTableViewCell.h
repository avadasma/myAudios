//
//  MFDropBoxTableViewCell.h
//  MyAudios
//
//  Created by chang on 2017/7/18.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface MFDropBoxTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;// 缩略图
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;// 名称
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;// 下载按钮
@property (weak, nonatomic) IBOutlet UILabel *notifyLbl;// 标志是否已下载
@property (weak, nonatomic) IBOutlet UIImageView *splitView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidth;// 图片宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;// 图片高度

@property (nonatomic, copy) void (^downloadBtnClickedBlock)();
@property(assign,nonatomic)CGFloat progress;// 下载进度
@property(strong,nonatomic) UIBezierPath *sectorPath;// 下载绘制曲线

// 根据model赋值cell
-(void)setupCellWithModel:(DBFILESMetadata *)entry;

- (void)drawRect:(CGRect)rect;

@end
