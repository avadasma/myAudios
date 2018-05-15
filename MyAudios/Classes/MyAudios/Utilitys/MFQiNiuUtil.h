//
//  MFQiNiuUtil.h
//  MyAudios
//
//  Created by chang on 2018/3/14.
//  Copyright © 2018年 chang. All rights reserved.
//
//  上传七牛云工具类

#import <Foundation/Foundation.h>

#define kQNinterface @"p5h5nrf1s.bkt.clouddn.com"//官网获取外链域名

static NSString *kQiNiuAccessKey = @"o8x2n9b8oOf8PMsV-uiCQZdQLnZ5Fg-8uVCpdhn5";// AccessKey
static NSString *kQiNiuSecretKey = @"F4_rEEzsv22pm1SGwP1Vo6aieC0BaTRgPbfzystI";// SecretKey
static NSString *kQiNiuBucketName = @"myaudios";// BucketName


@interface MFQiNiuUtil : NSObject

+ (NSString *)makeToken:(NSString *)accessKey secretKey:(NSString *)secretKey;

@end
