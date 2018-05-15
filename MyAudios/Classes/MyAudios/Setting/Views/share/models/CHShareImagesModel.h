//
//  CHShareImagesModel.h
//  Spring3G
//
//  Created by xuyunli on 16/12/14.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHShareImagesModel : NSObject
@property (nonatomic,strong,readonly) UIImage *shareIcon;// 分享的图片
@property (nonatomic, weak)id shareType;
@property (nonatomic,strong,readonly) NSString *nameItem;// eg. 微信好友
@property (nonatomic,strong,readonly) NSString *imageItem;// eg. weixinfriend.png

- (id)initWith:(NSString *)nameItem :(NSString *)imageItem WithShareImage :(UIImage *)shareIconItem withType:(id)shareType;
@end
