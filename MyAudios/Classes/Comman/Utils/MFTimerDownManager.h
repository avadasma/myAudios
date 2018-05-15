//
//  MFTimerDownManager.h
//  MyAudios
//
//  Created by chang on 2017/8/15.
//  Copyright © 2017年 chang. All rights reserved.
//
//  倒计时管理类
//  使用方法，参考:http://www.cocoachina.com/ios/20161011/17722.html

#import <Foundation/Foundation.h>

// 单例
#define kMFTimerDownManager [MFTimerDownManager manager]
// 倒计时通知
#define kCountDownNotification @"CountDownNotification"

@interface MFTimerDownManager : NSObject

// 时间差（单位：秒）
@property(nonatomic,assign) NSInteger timeInterval;

// 使用单例
+ (instancetype)manager;
// 开始倒计时
- (void)start;
// 刷新倒计时
- (void)reload;

@end



























