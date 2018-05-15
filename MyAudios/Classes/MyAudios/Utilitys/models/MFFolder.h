//
//  MFFolder.h
//  MyAudios
//
//  Created by chang on 2018/1/30.
//  Copyright © 2018年 chang. All rights reserved.
//
//  文件夹抽象类


#import <Foundation/Foundation.h>

@interface MFFolder : NSObject

@property(nonatomic,strong) NSString *name;// 文件夹名称
@property(nonatomic,strong) NSString *imgName;// 缩略图名称
@property(nonatomic,strong) NSArray * subItems;// 子对象

@end
