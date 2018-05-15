//
//  ItemCell.h
//  BoxContentSDKSampleApp
//
//  Created on 1/7/15.
//  Copyright (c) 2015 Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@import BoxContentSDK;

@interface BOXSampleItemCell : UITableViewCell

@property (nonatomic, readwrite, strong) BOXItem *item;
@property (nonatomic, readwrite, strong) BOXContentClient *client;

@property (nonatomic, copy) void (^downloadBtnClickedBlock)();
@property(assign,nonatomic)CGFloat progress;// 下载进度
@property(strong,nonatomic) UIBezierPath *sectorPath;// 下载绘制曲线

@property(nonnull,strong) UIButton *downloadBtn;// 下载按钮
@property(nonnull,strong) UILabel *notifyLbl;
@property(nonnull,strong) UIImageView *thumbnailImgView;// 缩略图
@property(nonnull,strong) UILabel *nameLbl;// 名称

- (void)drawRect:(CGRect)rect;

@end
