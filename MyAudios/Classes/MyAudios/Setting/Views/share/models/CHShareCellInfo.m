//
//  CHShareCellInfo.m
//  Spring3G
//
//  Created by chang on 2016/10/17.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import "CHShareCellInfo.h"

@implementation CHShareCellInfo

@synthesize shareModel = _shareModel;
@synthesize shareType = _shareType;


+ (CHShareCellInfo *)info:(CHWebShareModel *)shareModel shareType:(shareType)shareType
{
    CHShareCellInfo *info = [[CHShareCellInfo alloc] init];
    info.shareModel = shareModel;
    info.shareType = shareType;
    return info;
}

@end
