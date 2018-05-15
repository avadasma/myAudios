//
//  MFUserDefaultsCache.h
//  MyAudios
//
//  Created by chang on 2017/10/31.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFUserDefaultsCache : NSObject

// 标记已经播放完毕
+ (void)savePlayEndSetting:(NSString *)fileName;
// 清空播放完毕设置
+ (void)clearPlayEndSetting:(NSString *)fileName;

@end
