//
//  MFOneDriveTableViewCell.h
//  MyAudios
//
//  Created by chang on 2018/1/3.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OneDriveSDK/OneDriveSDK.h>

@interface MFOneDriveTableViewCell : UITableViewCell

@property (nonatomic, strong) ODItem * _Nullable item;
@property (nonatomic, strong) ODClient * _Nullable client;

@property (nonatomic, copy) void (^ _Nullable downloadBtnClickedBlock)();
@property(assign,nonatomic)CGFloat progress;// 下载进度
@property(strong,nonatomic) UIBezierPath * _Nullable sectorPath;// 下载绘制曲线

@property(nonnull,strong) IBOutlet UIButton *downloadBtn;// 下载按钮
@property(nonnull,strong) IBOutlet UILabel *notifyLbl;
@property(nonnull,strong) IBOutlet UIImageView *thumbnailImgView;// 缩略图
@property(nonnull,strong) IBOutlet UILabel *nameLbl;// 名称

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * _Nullable imgWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * _Nullable imgHeight;

@property(strong,nonatomic) ODURLSessionDownloadTask * _Nullable task;

- (void)drawRect:(CGRect)rect;


@end
