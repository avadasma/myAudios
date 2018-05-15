//
//  COShareView.h
//  Spring3G
//
//  Created by xu_hui on 14-5-7.
//  Copyright (c) 2014年 SpringAirlines. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>

typedef enum{
    
    ShareDefaultContentSame = 0,    //默认
    ShareCustomContentDiff,        //自定义
}ShareWay;

@class ShareModel;
@interface COShareView : UIView<UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

+(void)showShareViewContent:(NSString*)content;
+(void)showShareViewModelItems:(NSMutableArray*)modelItems;

- (id)initWithContent:(NSString*)content; //默认
- (id)initWithModelItems:(NSMutableArray*)modelItems;//自定义
- (void)addToRootView; //必须执行
- (void)dismissAnimation;

@end

#pragma mark 定制buttons
@interface UIButtonCustom : UIButton

@property (nonatomic)NSInteger index;

@end

#pragma mark 分享模型
@interface ShareModel : NSObject

/*
 *  1,注意nameItem内容必须与 - (void)shareEnter:(NSInteger)index 中的比较内容一致
 *  2,nameItem与imageItem 必须一一对应上
 */

- (id)initWith:(NSString *)_nameItem :(NSString *)_imageItem :(NSString *)_contentItem;

@property (nonatomic,strong,readonly) NSString *nameItem;
@property (nonatomic,strong,readonly) NSString *imageItem;
@property (nonatomic,strong,readonly) NSString *contentItem;

@end