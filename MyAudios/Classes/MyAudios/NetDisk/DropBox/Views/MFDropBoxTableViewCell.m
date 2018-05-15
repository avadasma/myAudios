//
//  MFDropBoxTableViewCell.m
//  MyAudios
//
//  Created by chang on 2017/7/18.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFDropBoxTableViewCell.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFFileManager.h"
#import "SVProgressHUD.h"

@implementation MFDropBoxTableViewCell

@synthesize sectorPath;


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)setupCellWithModel:(DBFILESMetadata *)entry {
    
    self.nameLabel.text = entry.name;
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.minimumScaleFactor = 0.6;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:entry.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:entry.name];
    BOOL isZipType = [MFFileTypeJudgmentUtil isZipType:entry.name];
    
    if (isImageType) {
        self.imgView.image = [UIImage imageNamed:@"cellThumbnailImage"];
        self.imgWidth.constant = 24.0;
        self.imgHeight.constant = 24.0;
        
    }else if (isAudioType) {
        self.imgView.image = [UIImage imageNamed:@"cellThumbnailAudio"];
        self.imgWidth.constant = 26.0;
        self.imgHeight.constant = 26.0;
        
    }else if (isZipType) {
        self.imgView.image = [UIImage imageNamed:@"cellThumbnailZipFile"];
        self.imgWidth.constant = 26.0;
        self.imgHeight.constant = 26.0;
    }else {
        self.imgView.image = [UIImage imageNamed:@"cellThumbnailFolder"];
        self.imgWidth.constant = 28.0;
        self.imgHeight.constant = 25.0;
    }
    
    [self showOrHideSubviews:entry];
}

// 判断是否已下载
-(void)showOrHideDownloadBtn:(NSString *)name {

    if (![MFFileManager judgeFileExistWithPath:name]) {
        self.notifyLbl.hidden = YES;
        self.downloadBtn.hidden = NO;
    }else{
        self.notifyLbl.hidden = NO;
        self.downloadBtn.hidden = YES;
    }
}


#pragma mark - 显示或者隐藏下载按钮
-(void)showOrHideSubviews:(DBFILESMetadata *)entry {
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:entry.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:entry.name];
    if ([MFFileTypeJudgmentUtil isFileType:entry.name]&&!isAudioType&&!isImageType) {
        // self.backgroundColor = COLOR(181.0, 181.0, 181.0, 1);
    }
    if (![MFFileTypeJudgmentUtil isFileType:entry.name]) {
        
        self.downloadBtn.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }else{
        if (!isAudioType&&!isImageType) {
            self.downloadBtn.hidden = YES;
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            self.downloadBtn.hidden = NO;
            self.accessoryType = UITableViewCellAccessoryNone;
            // 判断是否已下载
            [self showOrHideDownloadBtn:entry.name];
        }
    }
}



#pragma mark - 下载
- (IBAction)downLoadData:(id)sender {
    if (self.downloadBtnClickedBlock) {
        self.downloadBtnClickedBlock();
    }
}

#pragma mark - 设置下载进度
- (void)drawRect:(CGRect)rect {
    // 定义扇形中心
    CGPoint origin = self.downloadBtn.center;
    // 定义扇形半径
    CGFloat radius = 15.0f;
    // 设定扇形起点位置
    CGFloat startAngle = - M_PI_2;
    //    根据进度计算扇形结束位置
    CGFloat endAngle = startAngle + self.progress * M_PI * 2;
    // 根据起始点、原点、半径绘制弧线
    sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    // 从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
    [sectorPath addLineToPoint:origin];
    // 设置扇形的填充颜色
    [[UIColor darkGrayColor] set];
    // 设置扇形的填充模式
    [sectorPath fill];
}

//重写progress的set方法，可以在赋值的同时给label赋值
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    // 赋值结束之后要刷新UI，不然看不到扇形的变化
    [self setNeedsDisplay];
}

@end
