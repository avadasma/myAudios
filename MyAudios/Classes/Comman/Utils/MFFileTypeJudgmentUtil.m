//
//  MFFileTypeJudgmentUtil.m
//  MyAudios
//
//  Created by chang on 2017/8/5.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFFileTypeJudgmentUtil.h"

@implementation MFFileTypeJudgmentUtil


#pragma mark - 根据文件名判断文件类型
// 判断是否是img格式
+ (BOOL)isImageType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.jpeg|\\.jpg|\\.JPEG|\\.JPG|\\.png" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

// 判断是否是img格式
+ (BOOL)isAudioType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.mp3|\\.mp4|\\.aac|\\.AIFF|\\.CAF|\\.WAVE" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

// 判断是否是Zip格式
+ (BOOL)isZipType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\.zip" options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

// 判断是否是文件
+ (BOOL)isFileType:(NSString *)itemName {
    NSRange range = [itemName rangeOfString:@"\\." options:NSRegularExpressionSearch];
    return range.location != NSNotFound;
}

// 判断是否是文件夹
+ (BOOL)isFolderType:(NSString *)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    // fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    BOOL isDir = NO;
    NSString *path = [documentDir stringByAppendingPathComponent:fileName];
    [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
    return isDir;
}


@end
