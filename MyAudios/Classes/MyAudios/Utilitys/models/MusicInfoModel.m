//
//  MusicInfoModel.m
//  MyAudios
//
//  Created by chang on 2018/1/18.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "MusicInfoModel.h"

@implementation MusicInfoModel

// 重写的kvc部分方法.
-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.ID = value;
    }
    if ([key isEqualToString:@"lyric"]) {
        self.timeLyric = [value componentsSeparatedByString:@"\n"];
    }
}

@end
