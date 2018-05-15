//
//  MFDownloadTableViewCell.m
//  MyAudios
//
//  Created by chang on 2017/7/31.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFDownloadTableViewCell.h"
#import "MFFileTypeJudgmentUtil.h"
#import "MFDownloadedViewController.h"

@interface MFDownloadTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;


@end

@implementation MFDownloadTableViewCell



- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.multipleSelectionBackgroundView = [UIView new];
        self.tintColor = [UIColor redColor];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img=(UIImageView *)v;
                    if (self.selected) {
                        img.image=[UIImage imageNamed:@"xuanzhong_icon"];
                    }else
                    {
                        img.image=[UIImage imageNamed:@"weixuanzhong_icon"];
                    }
                }
            }
        }
    }
}

// 设置选中
- (void)setIfSelected:(BOOL)ifSelected {
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img=(UIImageView *)v;
                    if (self.selected) {
                        img.image=[UIImage imageNamed:@"xuanzhong_icon"];
                    }else
                    {
                        img.image=[UIImage imageNamed:@"weixuanzhong_icon"];
                    }
                }
            }
        }
    }
}


// 适配第一次图片为空的情况
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    for (UIControl *control in self.subviews){
        if ([control isMemberOfClass:NSClassFromString(@"UITableViewCellEditControl")]){
            for (UIView *v in control.subviews)
            {
                if ([v isKindOfClass: [UIImageView class]]) {
                    UIImageView *img=(UIImageView *)v;
                    if (!self.selected) {
                        img.image=[UIImage imageNamed:@"weixuanzhong_icon"];
                    }
                }
            }
        }
    }
    
}



-(void)setupCellWithModel:(NSString *)name {
    
    self.nameLabel.text = name;
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.minimumScaleFactor = 0.6;
    self.nameLabel.adjustsFontSizeToFitWidth = YES;
    
    BOOL isImageType = [MFFileTypeJudgmentUtil isImageType:name];
    BOOL isAudioType = [MFFileTypeJudgmentUtil isAudioType:name];
    BOOL isZipType = [MFFileTypeJudgmentUtil isZipType:name];
    
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
    
}


// 判断是否是文件
- (BOOL)isFileType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\." options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}




#pragma mark - 根据字符串长度判断cell高度
// 获取指定宽度width的字符串在UITextView上的高度
- (float) heightForString:(NSString *)str andWidth:(float)width{
    UITextView * textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17.0];
    textView.text = str;
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(mainScreenWidth-84, MAXFLOAT)];
    // 边界处理
    float cellHeight = sizeToFit.height;
    if (cellHeight<56) {
        cellHeight = 56;
    }else if (cellHeight>96){
        cellHeight = 96;
    }else{}
    
    return cellHeight+5;
}


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self setIfSelected:selected];
}



@end
