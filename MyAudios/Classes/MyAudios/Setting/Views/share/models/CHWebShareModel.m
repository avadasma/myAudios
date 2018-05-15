//
//  CHWebShareModel.m
//  Spring3G
//
//  Created by chang on 2016/10/17.
//  Copyright © 2016年 SpringAirlines. All rights reserved.
//

#import "CHWebShareModel.h"

@implementation CHWebShareModel

@synthesize nameItem;
@synthesize imageItem;
@synthesize contentItem;



- (id)initWith:(NSString *)_nameItem :(NSString *)_imageItem :(NSString *)_shareTitleItem :(NSString *)_shareDescriptionItem :(NSString *)_shareWebPageUrlItem :(UIImage *)_shareIconItem{
    
    if (self = [super init]) {
        nameItem = [_nameItem copy];
        imageItem = [_imageItem copy];
        _shareTitle = [_shareTitleItem copy];
        _shareDescription = [_shareDescriptionItem copy];
        _shareWebpageUrl = [_shareWebPageUrlItem copy];
        _shareIcon = [_shareIconItem copy];
    }
    return self;
}

@end
