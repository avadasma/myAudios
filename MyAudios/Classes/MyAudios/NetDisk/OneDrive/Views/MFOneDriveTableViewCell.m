//
//  MFOneDriveTableViewCell.m
//  MyAudios
//
//  Created by chang on 2018/1/3.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "MFOneDriveTableViewCell.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFFileManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BOXSampleThumbnailsHelper.h"

@interface MFOneDriveTableViewCell()

@property (nonatomic, readwrite, strong) ODChildrenCollectionRequest *childrenRequest;

@end

@implementation MFOneDriveTableViewCell
@synthesize sectorPath;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    
    self =  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 下载按钮设置
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(268.0, 7.5, 49, 29)];
        [_downloadBtn setBackgroundImage:[UIImage imageNamed:@"dowmloadButton"] forState:UIControlStateNormal];
        
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
    //[self.request cancel];
    //self.request = nil;
}

-(void)setTask:(ODURLSessionDownloadTask *)task {
    if (!task) {
        return;
    }
    // 使用KVO观察fractionCompleted的改变
    [task.progress addObserver:self forKeyPath:@"fractionCompleted" options:(NSKeyValueObservingOptionNew) context:ProgressObserverContext];
    // 定时器
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(task:) userInfo:task repeats:YES];
    // 加到当前运行循环
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


/**
 定时器调用的方法
 */
- (void)task:(NSTimer *)timer
{
    
    ODURLSessionDownloadTask *task = timer.userInfo;
    
    if (task.progress.completedUnitCount >= task.progress.totalUnitCount) {
        [timer invalidate];
        return;
    }
    task.progress.completedUnitCount += 1;
}

-(void)removeObserver:(ODURLSessionDownloadTask *)downloadTask
{
    @try
    {
        [downloadTask.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) context:ProgressObserverContext];
    }
    @catch (NSException * __unused exception) {}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if (context == ProgressObserverContext){
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSProgress *progress = object;
            // NSLog(@"progress === %@",progress);
            // double completed = progress.fractionCompleted;
            // 获取观察的新值
            CGFloat value = [change[NSKeyValueChangeNewKey] doubleValue];
            [self setProgress:value];
        });
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)setItem:(ODItem *)item
{
    if (item == nil) {
        return;
    }
    
    _item = item;
    self.nameLbl.text = item.name;
    self.nameLbl.numberOfLines = 0;
    self.nameLbl.minimumScaleFactor = 0.6;
    self.nameLbl.adjustsFontSizeToFitWidth = YES;
    
    [self updateThumbnail];
}

- (void)updateThumbnail
{
    UIImage *icon = nil;
    
    if ([self.item isKindOfClass:[ODItem class]]) {
        
        //  To check if an item is a folder you can address the folder property. If the item is a folder an ODFolder object will be returned, and it contains all of the properties described by the folder facet.
        //  https://github.com/OneDrive/onedrive-sdk-ios/blob/master/docs/overview.md
        self.downloadBtn.hidden = YES;
        self.notifyLbl.hidden = YES;
    } else {
        
    }
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:self.item.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:self.item.name];
    BOOL isZipType = [MFFileTypeJudgmentUtil isZipType:self.item.name];
    
    if (isImageType) {
        icon = [UIImage imageNamed:@"cellThumbnailImage"];
        self.imgWidth.constant = 24.0;
        self.imgHeight.constant = 24.0;
        
    }else if (isAudioType) {
        icon = [UIImage imageNamed:@"cellThumbnailAudio"];
        self.imgWidth.constant = 26.0;
        self.imgHeight.constant = 26.0;
        
    }else if (isZipType) {
        icon = [UIImage imageNamed:@"cellThumbnailZipFile"];
        self.imgWidth.constant = 26.0;
        self.imgHeight.constant = 26.0;
    }else {
        if (self.item.folder) {
            icon = [UIImage imageNamed:@"cellThumbnailFolder"];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            self.accessoryType = UITableViewCellAccessoryNone;
            icon = [UIImage imageNamed:@"cellThumbnailImage"];
        }
        self.imgWidth.constant = 28.0;
        self.imgHeight.constant = 25.0;
    }
    
    self.thumbnailImgView.image = icon;
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
-(void)showOrHideSubviews:(ODItem *)entry {
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:entry.name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:entry.name];

    if (entry.folder) {// 文件夹
        self.downloadBtn.hidden = YES;
        self.notifyLbl.hidden = YES;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.accessoryType = UITableViewCellAccessoryNone;
        if (isAudioType||isImageType) {
            self.downloadBtn.hidden = NO;
            // 判断是否已下载
            [self showOrHideDownloadBtn:entry.name];
        }else{
            self.downloadBtn.hidden = YES;
            self.notifyLbl.hidden = YES;
        }
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


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
