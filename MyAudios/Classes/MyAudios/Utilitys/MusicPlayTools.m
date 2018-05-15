//
//  MusicPlayTools.m
//  MyAudios
//
//  Created by chang on 2018/1/18.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "MusicPlayTools.h"
#import "MusicLyricModel.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MediaPlayer.h>

static MusicPlayTools * mp = nil;

@interface MusicPlayTools ()

@property(nonatomic,strong)NSTimer * timer;

@end

@implementation MusicPlayTools

// 单例方法
+(instancetype)shareMusicPlay
{
    if (mp == nil) {
        static dispatch_once_t once_token;
        dispatch_once(&once_token, ^{
            mp = [[MusicPlayTools alloc] init];
        });
    }
    return mp;
}

// 这里为什么要重写init方法呢?
// 因为,我们应该得到 "某首歌曲播放结束" 这一事件,之后由外界来决定"播放结束之后采取什么操作".
// AVPlayer并没有通过block或者代理向我们返回这一状态(事件),而是向通知中心注册了一条通知(AVPlayerItemDidPlayToEndTimeNotification),我们也只有这一条途径获取播放结束这一事件.
// 所以,在我们创建好一个播放器时([[AVPlayer alloc] init]),应该立刻为通知中心添加观察者,来观察这一事件的发生.
// 这个动作放到init里,最及时也最合理.
- (instancetype)init
{
    self = [super init];
    if (self) {
        _player = [[AVPlayer alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfPlay:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

// 播放结束后的方法,由代理具体实现行为.
-(void) endOfPlay:(NSNotification *)sender
{
    // 为什么要先暂停一下呢?
    // 看看 musicPlay 方法, 第一个if判断,你能明白为什么吗?
    [self musicPause];
    if ([self.delegate respondsToSelector:@selector(endOfPlayAction)]) {
        [self.delegate endOfPlayAction];
    }
    
}

// 准备播放,我们在外部调用播放器播放时,不会调用"直接播放",而是调用这个"准备播放",当它准备好时,会直接播放.
-(void)musicPrePlay {
    // 通过下面的逻辑,只要AVPlayer有currentItem,那么一定被添加了观察者.
    // 所以上来直接移除之.
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    // 根据传入的URL(MP3歌曲地址),创建一个item对象
    // initWithURL的初始化方法建立异步链接. 什么时候连接建立完成我们不知道.但是它完成连接之后,会修改自身内部的属性status. 所以,我们要观察这个属性,当它的状态变为AVPlayerItemStatusReadyToPlay时,我们便能得知,播放器已经准备好,可以播放了.
    AVPlayerItem * item = [[ AVPlayerItem alloc] initWithURL:[NSURL URLWithString:self.model.mp3Url]];
    
    // 为item的status添加观察者.
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    // 用新创建的item,替换AVPlayer之前的item.新的item是带着观察者的哦.
    [self.player replaceCurrentItemWithPlayerItem:item];
}

// 播放本地音乐
// 准备播放,我们在外部调用播放器播放时,不会调用"直接播放",而是调用这个"准备播放",当它准备好时,会直接播放.
-(void)localMusicPrePlay {
    
    // 通过下面的逻辑,只要AVPlayer有currentItem,那么一定被添加了观察者.
    // 所以上来直接移除之.
    if (self.player.currentItem) {
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    // 根据传入的URL(MP3歌曲地址),创建一个item对象
    // initWithURL的初始化方法建立异步链接. 什么时候连接建立完成我们不知道.但是它完成连接之后,会修改自身内部的属性status. 所以,我们要观察这个属性,当它的状态变为AVPlayerItemStatusReadyToPlay时,我们便能得知,播放器已经准备好,可以播放了.
    AVPlayerItem * item = [self getPlayItem:self.model.name];
    
    // 为item的status添加观察者.
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    // 用新创建的item,替换AVPlayer之前的item.新的item是带着观察者的哦.
    [self.player replaceCurrentItemWithPlayerItem:item];
}


// 观察者的处理方法, 观察的是Item的status状态.
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        switch ([[change valueForKey:@"new"] integerValue]) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"不知道什么错误");
                break;
            case AVPlayerItemStatusReadyToPlay:
                // 只有观察到status变为这种状态,才会真正的播放.
                // 如果想实现倍速播放,必须调用此方法
                [self enableAudioTracks:YES inPlayerItem:self.player.currentItem];
                [self musicPlay];
                break;
            case AVPlayerItemStatusFailed:
                // mini设备不插耳机或者某些耳机会导致准备失败.
                NSLog(@"准备失败");
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status= [[change objectForKey:@"new"] intValue];
        if(status==AVPlayerStatusReadyToPlay){
            NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(self.player.currentItem.duration));
        }
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=self.player.currentItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        NSLog(@"共缓冲：%.2f",totalBuffer);
    }
}

-(void)timerAction:(NSTimer * )sender
{
    // !! 计时器的处理方法中,不断的调用代理方法,将播放进度返回出去.
    // 一定要掌握这种形式.
    [self.delegate getCurTiem:[self valueToString:[self getCurTime]] Totle:[self valueToString:[self getTotleTime]] Progress:[self getProgress]];
    
}

// 播放
-(void)musicPlay
{
    // 如果计时器已经存在了,说明已经在播放中,直接返回.
    // 对于已经存在的计时器,只有musicPause方法才会使之停止和注销.
    if (self.timer != nil) {
        return;
    }
    
    // 播放后,我们开启一个计时器.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    
    [self.player play];
}

// 暂停方法
-(void)musicPause
{
    [self.timer invalidate];
    self.timer = nil;
    [self.player pause];
}

// 跳转方法
-(void)seekToTimeWithValue:(CGFloat)value
{
    // 先暂停
    [self musicPause];
    
    // 跳转
    [self.player seekToTime:CMTimeMake(value * [self getTotleTime], 1) completionHandler:^(BOOL finished) {
        if (finished == YES) {
            [self musicPlay];
        }
    }];
}

// 获取当前的播放时间
-(NSInteger)getCurTime
{
    if (self.player.currentItem) {
        // 用value/scale,就是AVPlayer计算时间的算法. 它就是这么规定的.
        // 下同.
        return self.player.currentTime.value / self.player.currentTime.timescale;
    }
    return 0;
}
// 获取总时长
-(NSInteger)getTotleTime
{
    CMTime totleTime = [self.player.currentItem duration];
    if (totleTime.timescale == 0) {
        return 1;
    }else
    {
        return totleTime.value /totleTime.timescale;
    }
}
// 获取当前播放进度
-(CGFloat)getProgress
{
    return (CGFloat)[self getCurTime]/ (CGFloat)[self getTotleTime];
}

// 将整数秒转换为 00:00:00 格式的字符串
-(NSString *)valueToString:(NSInteger)value
{
    NSInteger hours = (value / 3600);
    NSInteger minutes = (value / 60) % 60;
    NSInteger seconds = value % 60;
    return [NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",hours,minutes,seconds];
}

// 返回一个歌词数组(这里有Bug)
-(NSMutableArray *)getMusicLyricArray
{
    NSMutableArray * array = [NSMutableArray array];
    
    for (NSString * str in self.model.timeLyric) {
        if (str.length == 0) {
            continue;
        }
        MusicLyricModel * model = [[MusicLyricModel alloc] init];
        model.lyricTime = [str substringWithRange:NSMakeRange(1, 9)];
        model.lyricStr = [str substringFromIndex:11];
        [array addObject:model];
    }
    return array;
}

-(NSInteger)getIndexWithCurTime
{
    NSInteger index = 0;
    NSString * curTime = [self valueToString:[self getCurTime]];
    for (NSString * str in self.model.timeLyric) {
        if (str.length == 0) {
            continue;
        }
        if ([curTime isEqualToString:[str substringWithRange:NSMakeRange(1, 5)]]) {
            return index;
        }
        index ++;
    }
    return -1;
}

#pragma mark -  Now Playing Center 配置
- (void)configNowPlayingCenter:(NSString *)title {
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    // 音乐的标题
    // _player.currentSong.title
    [info setObject:title forKey:MPMediaItemPropertyTitle];
    // 音乐的艺术家
    // [info setObject:_player.currentSong.artist forKey:MPMediaItemPropertyArtist];
    // 音乐的播放时间 self.player.playTime.intValue
    NSInteger playedTime = [[MusicPlayTools shareMusicPlay] getCurTime];
    // int playedTime = (int)self.sliderProgress.value * CMTimeGetSeconds(self.player.currentItem.duration);
    [info setObject:@(playedTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    // 音乐的播放速度
    [info setObject:@([MusicPlayTools shareMusicPlay].player.rate) forKey:MPNowPlayingInfoPropertyPlaybackRate];
    // 音乐的总时间 self.player.playDuration.intValue
    int totalTime = (int)CMTimeGetSeconds([MusicPlayTools shareMusicPlay].player.currentItem.duration);
    [info setObject:@(totalTime) forKey:MPMediaItemPropertyPlaybackDuration];
    // 音乐的封面 _player.coverImg
    UIImage *image = [UIImage imageNamed:@"aboutMe"];
    MPMediaItemArtwork * artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:CGSizeMake(40, 40) requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    [info setObject:artwork forKey:MPMediaItemPropertyArtwork];
    // 完成设置
    [[MPNowPlayingInfoCenter defaultCenter]setNowPlayingInfo:info];
}


// 倍速切换方法
- (void)enableAudioTracks:(BOOL)enable inPlayerItem:(AVPlayerItem*)playerItem
{
    for (AVPlayerItemTrack *track in playerItem.tracks)
    {
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeAudio])
        {
            track.enabled = enable;
        }
    }
}

/**
 *  根据视频索引取得AVPlayerItem对象
 *  @return AVPlayerItem对象
 */
-(AVPlayerItem *)getPlayItem:(NSString *)fileName{
    
    // urlStr =[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *filePath = [self readFilePath:fileName];
    NSURL *url=[NSURL fileURLWithPath:filePath];
    AVPlayerItem *playerItem=[AVPlayerItem playerItemWithURL:url];
    return playerItem;
}


#pragma mark - 根据文件名获取路径
-(NSString *)readFilePath:(NSString *)name {
    
    // NSFileManager *fileManager = [NSFileManager defaultManager];
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString * path = [documentDir stringByAppendingPathComponent:name];
    
    return path;
    
}

@end
