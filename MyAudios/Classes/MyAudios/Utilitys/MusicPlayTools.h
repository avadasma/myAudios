//
//  MusicPlayTools.h
//  MyAudios
//
//  Created by chang on 2018/1/18.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicInfoModel.h"

// !!! 与block回传值作比较.
// 定义协议. 通过代理方法返回当前歌曲的播放进度.
// 如果外界想使用本播放器,必须遵循和实现协议中的两个方法.
@protocol MusicPlayToolsDelegate <NSObject>
// 外界实现这个方法的同时, 也将参数的值拿走了, 这样我们起到了"通过代理方法向外界传递值"的功能.
-(void)getCurTiem:(NSString *)curTime Totle:(NSString *)totleTime Progress:(CGFloat)progress;
// 播放结束之后, 如何操作由外部决定.
-(void)endOfPlayAction;

@end

@interface MusicPlayTools : NSObject
// 本类中的播放器指针.
@property(nonatomic,strong)AVPlayer * player;
// 本类中的,播放中的"歌曲信息模型"
@property(nonatomic,strong)MusicInfoModel * model;
// 代理
@property(nonatomic,weak)id<MusicPlayToolsDelegate> delegate;

// 单例方法
+(instancetype)shareMusicPlay;
// 播放音乐
-(void)musicPlay;
// 暂停音乐
-(void)musicPause;
// 准备播放
-(void)musicPrePlay;
// 准备播放播放本地音乐
-(void)localMusicPrePlay;
// 跳转
-(void)seekToTimeWithValue:(CGFloat)value;
// 返回一个歌词数组
-(NSMutableArray *)getMusicLyricArray;
// 根据当前播放时间,返回 对应歌词 在 数组 中的位置.
-(NSInteger)getIndexWithCurTime;
// 获取当前的播放时间
-(NSInteger)getCurTime;
// Now Playing Center 配置
- (void)configNowPlayingCenter:(NSString *)title;

@end
