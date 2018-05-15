//
//  CHShareImagesModel.m
//  Spring3G
//
//  Created by xuyunli on 16/12/14.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import "CHShareImagesModel.h"

@implementation CHShareImagesModel

- (id)initWith:(NSString *)nameItem :(NSString *)imageItem WithShareImage :(UIImage *)shareIconItem withType:(id)shareType{
    
        if (self = [super init]) {
        _nameItem = [nameItem copy];
        _imageItem = [imageItem copy];
        _shareIcon = [shareIconItem copy];
        _shareType = shareType;
        }
        return self;
}
@end
