//
//  MFFileManager.h
//  MyAudios
//
//  Created by chang on 2017/8/5.
//  Copyright © 2017年 chang. All rights reserved.
//
//  本地文件管理类

#import <Foundation/Foundation.h>

@interface MFFileManager : NSObject

#pragma mark - 根据文件名判断本地是否包含文件
+(BOOL)judgeFileExistWithPath:(NSString *)name;

#pragma mark - 根据文件名创建文件路径
+(BOOL)creatNewFolder:(NSString *)folderName;
#pragma mark - 根据文件名删除文件夹
+(BOOL)deleteFolder:(NSString *)folderName;
#pragma mark - 根据文件路径移动文件
+(BOOL)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath;

#pragma mark - 根据文件名获取文件路径
+(NSString *)readFilePath:(NSString *)name;

#pragma mark - 读取下载路径下文件名
+(NSMutableArray *)readDownloadedFiles:(NSString *)folderName;

#pragma mark - 根据文件名删除本地文件
+(BOOL)deleteFileWithPath:(NSString *)name;


@end
