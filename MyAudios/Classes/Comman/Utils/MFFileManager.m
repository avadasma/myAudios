//
//  MFFileManager.m
//  MyAudios
//
//  Created by chang on 2017/8/5.
//  Copyright © 2017年 chang. All rights reserved.
//


#import "MFFileManager.h"
#import "MFStringUtil.h"

@implementation MFFileManager


#pragma mark - 根据文件名判断本地是否包含文件
+(BOOL)judgeFileExistWithPath:(NSString *)name {
    
    if (![name containsString:@"."]) {
        return NO;
    }
    NSString * path = [MFFileManager readFilePath:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:path];
    return isExist;
}


#pragma mark - 根据文件名删除本地文件
+(BOOL)deleteFileWithPath:(NSString *)name {

    NSString * path = [MFFileManager readFilePath:name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    BOOL isExist = [fileManager fileExistsAtPath:path];
    BOOL isSuccess = NO;
    if (isExist) {
        isSuccess = [fileManager removeItemAtPath:path error:&err];
    }
    return isSuccess;
}

#pragma mark - 根据文件路径移动文件
+(BOOL)moveItemAtPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    NSString * path = [MFFileManager readFilePath:fromPath];
    NSString * toPathStr = [MFFileManager readFilePath:toPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    BOOL isExist = [fileManager fileExistsAtPath:path];
    BOOL isSuccess = NO;
    if (isExist) {
        isSuccess = [fileManager moveItemAtPath:path toPath:toPathStr error:&err];
    }
    return isSuccess;
}

#pragma mark - 根据文件名创建文件路径
+(BOOL)creatNewFolder:(NSString *)folderName {
    
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:folderName];
    NSError  *error;
    
    BOOL createSucced = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        createSucced = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    return createSucced;
}

#pragma mark - 根据文件名删除文件夹
+(BOOL)deleteFolder:(NSString *)folderName {
    
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:folderName];
    NSError  *error;
    
    BOOL deleteSucceed = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        
        deleteSucceed =  [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    return deleteSucceed;
}



#pragma mark - 根据文件名获取文件路径
+(NSString *)readFilePath:(NSString *)name {
    
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:name];
    
    return path;
}

#pragma mark - 读取下载路径下文件名
+(NSMutableArray *)readDownloadedFiles:(NSString *)folderName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    if (![MFStringUtil isEmpty:folderName]) {
        documentDir = [documentDir stringByAppendingPathComponent:folderName];
    }
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    // fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    NSMutableArray * resultsArr = [[NSMutableArray alloc] init];
    resultsArr = [NSMutableArray arrayWithArray:fileList];
    
    return resultsArr;
    
    
    /*
     //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
     NSMutableArray *dirArray = [[NSMutableArray alloc] init];
     BOOL isDir = NO;
     //在上面那段程序中获得的fileList中列出文件夹名
     for (NSString *file in fileList) {
     NSString *path = [documentDir stringByAppendingPathComponent:file];
     [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
     if (isDir) {
     [dirArray addObject:file];
     }
     isDir = NO;
     }*/
    
}



@end
