//
//  CHShareCellInfo.h
//  Spring3G
//
//  Created by chang on 2016/10/17.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHWebShareModel.h"

typedef enum
{
    kWeiXin = 1,// 微信好友
    kWeiXinGroups = 2,// 微信朋友圈
    kQQ = 3,// QQ
    kQQZone = 4,// QQ空间
    kWeibo = 5,// 微博
    kCopyLinks = 6,// 分享链接
}shareType;



@interface CHShareCellInfo : NSObject

@property (nonatomic, retain)CHWebShareModel *shareModel;
@property (nonatomic, assign) shareType shareType;

+ (CHShareCellInfo *)info:(CHWebShareModel *)shareModel shareType:(shareType)shareType;

@end
