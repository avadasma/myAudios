//
//  CHAudioModel.h
//  MyAudios
//
//  Created by chang on 2017/12/3.
//  Copyright © 2017年 chang. All rights reserved.
//
//  音频model

#import <Foundation/Foundation.h>

@interface CHAudioModel : NSObject

@property(nonatomic,strong) NSString * fileName;// 文件名
@property(nonatomic) BOOL ifSelected;// 是否已选中
@property(nonatomic,strong) NSString * parentfolderName;// 父文件夹名称

@end
