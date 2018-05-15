//
//  MFFileTypeJudgmentUtil.h
//  MyAudios
//
//  Created by chang on 2017/8/5.
//  Copyright © 2017年 chang. All rights reserved.
//
//  根据文件后缀判断文件类型

#import <Foundation/Foundation.h>

@interface MFFileTypeJudgmentUtil : NSObject

// 判断是否是img格式
+ (BOOL)isImageType:(NSString *)itemName;
// 判断是否是img格式
+ (BOOL)isAudioType:(NSString *)itemName;
// 判断是否是Zip格式
+ (BOOL)isZipType:(NSString *)itemName;
// 判断是否是文件
+ (BOOL)isFileType:(NSString *)itemName;
// 判断是否是文件夹
+ (BOOL)isFolderType:(NSString *)fileName;
@end
