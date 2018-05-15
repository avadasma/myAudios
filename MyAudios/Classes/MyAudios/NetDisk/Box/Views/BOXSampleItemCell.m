//
//  ItemCell.m
//  BoxContentSDKSampleApp
//
//  Created on 1/7/15.
//  Copyright (c) 2015 Box. All rights reserved.
//

#import "BOXSampleItemCell.h"
#import "BOXSampleThumbnailsHelper.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFFileManager.h"

@interface BOXSampleItemCell()

@property (nonatomic, readwrite, strong) BOXFileThumbnailRequest *request;

@end

@implementation BOXSampleItemCell
@synthesize sectorPath;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    
    self =  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 下载按钮设置
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(268.0, 7.5, 49, 29)];
         [_downloadBtn setBackgroundImage:[UIImage imageNamed:@"dowmloadButton"] forState:UIControlStateNormal];
        // 添加下载事件
        [_downloadBtn addTarget:self action:@selector(downLoadData:) forControlEvents:UIControlEventTouchUpInside];
        
        // 提示文本设置
        _notifyLbl = [[UILabel alloc] initWithFrame:CGRectMake(273.0, 12, 42, 21)];
        _notifyLbl.text = @"已下载";
        _notifyLbl.font = [UIFont systemFontOfSize:13.0];
        _notifyLbl.textColor = [UIColor colorWithRed:170.0/255.0 green:170.0/255.0 blue:170.0/255.0 alpha:1.0];
        
        // 缩略图
        _thumbnailImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 9.0, 26.0, 26.0)];
        
        // 名称
        _nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(56, 8, 225, 27.5)];
        _nameLbl.numberOfLines = 0;
        
        [self addSubview:_downloadBtn];
        [self addSubview:_notifyLbl];
        [self addSubview:_thumbnailImgView];
        [self addSubview:_nameLbl];
       
    }
    return self;
    
    
}



-(void)layoutSubviews{
    [super layoutSubviews];
    
    float cellWidth = self.frame.size.width;
    float cellHeight = self.frame.size.height;
    
    self.downloadBtn.frame = CGRectMake(cellWidth-49-3, (cellHeight-29)/2.0, 49, 29);
    self.notifyLbl.frame = CGRectMake(cellWidth-42-5, (cellHeight-21)/2.0, 49, 29);
    self.nameLbl.frame = CGRectMake(56, (cellHeight-cellHeight+16)/2.0, cellWidth-106.0, cellHeight-16);
    self.thumbnailImgView.frame = CGRectMake(15, (cellHeight-26)/2.0, 26, 26);
    
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.request cancel];
    self.request = nil;
}

- (void)setItem:(BOXItem *)item
{
    if (item == nil) {
        return;
    }
    
    _item = item;
    self.nameLbl.text = item.name;
    
    [self updateThumbnail];
}

- (void)updateThumbnail
{
    UIImage *icon = nil;
    
    if ([self.item isKindOfClass:[BOXFolder class]]) {
        if (((BOXFolder *) self.item).hasCollaborations == BOXAPIBooleanYES) {
            if (((BOXFolder *) self.item).isExternallyOwned == BOXAPIBooleanYES) {
                // icon = [UIImage imageNamed:@"icon-folder-external"];
                icon = [UIImage imageNamed:@"cellThumbnailFolder"];
            } else {
                // icon = [UIImage imageNamed:@"icon-folder-shared"];
                icon = [UIImage imageNamed:@"cellThumbnailFolder"];
            }
        } else {
            // icon = [UIImage imageNamed:@"icon-folder"];
            icon = [UIImage imageNamed:@"cellThumbnailFolder"];
        }
    } else {
        BOXSampleThumbnailsHelper *thumbnailsHelper = [BOXSampleThumbnailsHelper sharedInstance];
        
        // Try to retrieve the thumbnail from our in memory cache
        UIImage *image = [thumbnailsHelper thumbnailForItemWithID:self.item.modelID userID:self.client.user.modelID];
        
        if (image) {
            icon = image;
        }
        // No cached version was found, we need to query it from our API
        else {
            icon = [UIImage imageNamed:@"icon-file-generic"];
            
            if ([thumbnailsHelper shouldDownloadThumbnailForItemWithName:self.item.name]) {
                self.request = [self.client fileThumbnailRequestWithID:self.item.modelID size:BOXThumbnailSize64];
                __weak BOXSampleItemCell *weakSelf = self;
            
                [self.request performRequestWithProgress:nil completion:^(UIImage *image, NSError *error) {
                    if (error == nil) {   
                        [thumbnailsHelper storeThumbnailForItemWithID:self.item.modelID userID:self.client.user.modelID thumbnail:image];
                        
                        // weakSelf.imageView.image = image;
                        weakSelf.thumbnailImgView.image = image;
                        CATransition *transition = [CATransition animation];
                        transition.duration = 0.3f;
                        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                        transition.type = kCATransitionFade;
                        [weakSelf.imageView.layer addAnimation:transition forKey:nil];
                    }
                }];
            }
        }
    }
    self.thumbnailImgView.image = icon;
    
    // 以下逻辑 added by chang
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:self.item.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:self.item.name];
    if (isImageType) {
        self.thumbnailImgView.image = [UIImage imageNamed:@"cellThumbnailImage"];
    }
    if (isAudioType) {
        self.thumbnailImgView.image = [UIImage imageNamed:@"cellThumbnailAudio"];
    }
    [self showOrHideSubviews:self.item];
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
-(void)showOrHideSubviews:(BOXItem *)entry {
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:entry.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:entry.name];
    
    if ([entry isKindOfClass:[BOXFolder class]]) {// 文件夹
        self.downloadBtn.hidden = YES;
        self.notifyLbl.hidden = YES;
    }else{
        if (isAudioType||isImageType) {
            self.downloadBtn.hidden = NO;
            self.accessoryType = UITableViewCellAccessoryNone;
            // 判断是否已下载
            [self showOrHideDownloadBtn:entry.name];
        }else{
            self.downloadBtn.hidden = YES;
            self.notifyLbl.hidden = YES;
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
