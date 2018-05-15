//
//  MFStringUtil.h
//  MyAudios
//
//  Created by chang on 2017/8/12.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFStringUtil : NSObject


#pragma mark - 判断是否为空
+ (BOOL)isEmpty:(NSString *)str;

#pragma mark - 传入 秒  得到 xx:xx:xx
+ (NSString *)getHHMMSSFromSS:(NSString *)totalTime;

#pragma mark - 传入 秒  得到  xx分钟xx秒
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;

// 获取指定宽度width的字符串在UITextView上的高度
+ (float) heightForString:(NSString *)str andWidth:(float)width;
@end
