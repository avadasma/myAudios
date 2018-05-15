//
//  MFUserDefaultsCache.m
//  MyAudios
//
//  Created by chang on 2017/10/31.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFUserDefaultsCache.h"

@implementation MFUserDefaultsCache

// 标记已经播放完毕
+ (void)savePlayEndSetting:(NSString *)fileName{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // 标记是否已经播放完毕
    [defaults setBool:YES forKey:fileName];
    
    // rgb 181 181 181
    [defaults synchronize];
    
}

// 清空播放完毕设置
+ (void)clearPlayEndSetting:(NSString *)fileName{

    if (fileName) {
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // 标记是否已经播放完毕
        [defaults removeObjectForKey:fileName];
        // rgb 181 181 181
        [defaults synchronize];
    }
}


@end
