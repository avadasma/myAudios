//
//  CHWebShareModel.h
//  Spring3G
//
//  Created by chang on 2016/10/17.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHWebShareModel : NSObject

@property (nonatomic,strong,readonly) NSString *nameItem;// eg. 微信好友
@property (nonatomic,strong,readonly) NSString *imageItem;// eg. weixinfriend.png
@property (nonatomic,strong,readonly) NSString *contentItem;// eg.

// 分享的内容
@property (nonatomic,strong,readonly) NSString *shareTitle;// eg. 星期五
@property (nonatomic,strong,readonly) NSString *shareDescription;// eg. 买买买22:00
@property (nonatomic,strong,readonly) NSString *shareWebpageUrl;// eg. http://cms.ch.com/2016/superFriday10/share.html?(null)
@property (nonatomic,strong,readonly) UIImage *shareIcon;// eg.


 - (id)initWith:(NSString *)_nameItem :(NSString *)_imageItem :(NSString *)_shareTitleItem :(NSString *)_shareDescriptionTtem :(NSString *)_shareWebpageUrlItem :(UIImage *)_shareIconItem;

@end
