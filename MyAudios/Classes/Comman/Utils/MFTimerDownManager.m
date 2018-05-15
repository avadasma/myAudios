//
//  MFTimerDownManager.m
//  MyAudios
//
//  Created by chang on 2017/8/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFTimerDownManager.h"

@interface MFTimerDownManager ()

@property(nonatomic,strong) NSTimer *timer;

@end


@implementation MFTimerDownManager

// 使用单例
+ (instancetype)manager {

    static MFTimerDownManager *mangaer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mangaer = [[MFTimerDownManager alloc] init];
    });
    return mangaer;
}
// 开始倒计时
- (void)start {

    [self timer];
}
// 刷新倒计时
- (void)reload {
    self.timeInterval = 0;
}

-(NSTimer *)timer {
    if (_timer==nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction) userInfo:nil  repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    
    return _timer;
}


-(void)timerAction {
    
    // 时间差+1
    self.timeInterval ++;
    // 发出通知 可以按照时间差传递出去，或者直接通知类属性
    [[NSNotificationCenter defaultCenter] postNotificationName:kCountDownNotification object:nil userInfo:@{@"TimeInterval":@(self.timeInterval)}];

}

@end


















