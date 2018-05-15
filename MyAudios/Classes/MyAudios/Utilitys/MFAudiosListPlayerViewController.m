//
//  MFAudiosListPlayerViewController.m
//  MyAudios
//
//  Created by chang on 2017/8/15.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFAudiosListPlayerViewController.h"
#import "MFStringUtil.h"
#import "MFTimerDownManager.h"
#import "MFStringUtil.h"
#import "MFUserDefaultsCache.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import "MusicPlayTools.h"
#import "MFFileTypeJudgmentUtil.h"

#define CUSTOMTITLEVIEWWIDTH mainScreenWidth - 95

@interface MFAudiosListPlayerViewController ()<UIAlertViewDelegate,MusicPlayToolsDelegate>{

    dispatch_source_t timer;
}

@property (weak, nonatomic) IBOutlet UIView *container;// 播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;// 播放/暂停按钮
@property (weak, nonatomic) IBOutlet UIButton *previousBtn;// 上一首
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;// 下一首

@property (weak, nonatomic) IBOutlet UISlider *sliderProgress;// 播放进度
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLbl;// 已播放时间
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLnl;// 剩余时间

@property (nonatomic,strong) NSMutableArray * downloadedAudiosArr;// 本地已下载的音频
@property (weak, nonatomic) IBOutlet UIButton *timerBtn;// 倒计时按钮
@property (weak, nonatomic) IBOutlet UILabel *remainingTimeLbl;// 倒计时剩余时间
@property (strong,nonatomic) NSString * currentTimerIndex;// 记录当前选中的倒计时 0 30分钟、1 60分钟、2 90分钟、3 播完当前音频再关闭、4 关闭倒计时

@property(nonatomic,assign) NSInteger currentTotalTime;// 当前倒计时总时间
// @property (nonatomic, assign,readonly) AVPlayerItemStatus playerState;/*用枚举定义了播放器状态*/
@property (nonatomic,assign) float ratevalue; /*!*倍速*/

@property(nonatomic,strong)id playbackObserver; /**<检测播放的背景*/

@end

@implementation MFAudiosListPlayerViewController

#pragma mark - UIView Custom Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化播放列表
    [self readDownloadedAudiosFiles];
    
    // 初始化倍速
    self.ratevalue = 1.0;
    // 初始化倒计时选中
    self.currentTimerIndex = @"4";
    
    // 处理中断事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    // 设置 MusicPlayTools 代理
    [[MusicPlayTools shareMusicPlay] setDelegate:self];
    
    [[MusicPlayTools shareMusicPlay] configNowPlayingCenter:self.title];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([MusicPlayTools shareMusicPlay].player.rate==1) {// 如果正在播放，不再重新开始播放
        NSString * fileName = [[MusicPlayTools shareMusicPlay] model].name;
        NSArray *strArr = [fileName componentsSeparatedByString:@"/"];
        if (strArr.count>1) {
            fileName = [strArr lastObject];
        }
        if (![self.fileName isEqualToString:fileName]) {
            // 开始播放
            [self localMusicPrePlay:self.fileName];
        }
    }else{
        // 开始播放
        [self localMusicPrePlay:self.fileName];
    }
    
    
    // 设置按钮显示播放
    [self setBackGroundImage:1];
    
    
    // 添加播放器通知
    [self addNotification];
    

}

-(void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    // 销毁监听者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // 关闭定时器
    [self cancelTimer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark- 根据文件名播放
-(void)localMusicPrePlay:(NSString *)fileName {
    MusicInfoModel *musicModel = [[MusicInfoModel alloc] init];
    
    if (![MFStringUtil isEmpty:self.parentfolderName]) {
        self.fileName = [NSString stringWithFormat:@"%@/%@",self.parentfolderName,fileName];
    }
    musicModel.name = self.fileName;
    [[MusicPlayTools shareMusicPlay] setModel:musicModel];
    [[MusicPlayTools shareMusicPlay] localMusicPrePlay];
}



#pragma mark - MusicPlayToolsDelegate Methods
// 外界实现这个方法的同时, 也将参数的值拿走了, 这样我们起到了"通过代理方法向外界传递值"的功能.
-(void)getCurTiem:(NSString *)curTime Totle:(NSString *)totleTime Progress:(CGFloat)progress {
    // 更新播放进度条
    self.sliderProgress.value = progress;
    
    NSLog(@"self.ratevalue ==== %f",self.ratevalue);
    NSLog(@"total==== %@",totleTime);
    NSLog(@"current==== %@",curTime);
    
    self.playedTimeLbl.text = curTime;
    self.remainTimeLnl.text = totleTime;
}

// 播放结束之后, 如何操作由外部决定.
-(void)endOfPlayAction {
    
    if ([@"播完这条" isEqualToString:self.remainingTimeLbl.text]) {
        self.remainingTimeLbl.text = @"定时关闭";
        [[MusicPlayTools shareMusicPlay] musicPause];
        return;
    }
    // 设置进度条显示完全
    [self.sliderProgress setValue:1.0];
    // 标记播放完毕并存储到本地
    [MFUserDefaultsCache savePlayEndSetting:self.fileName];
    // 自动播放下一首
    [self nextBtnClicked:nil];
    
}



#pragma mark - 私有方法
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    switch (event.subtype)    {
        case UIEventSubtypeRemoteControlPlay:
            [[MusicPlayTools shareMusicPlay] musicPlay];
            break;
        case UIEventSubtypeRemoteControlPause:
            [[MusicPlayTools shareMusicPlay] musicPause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self nextBtnClicked:nil];
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [MusicPlayTools shareMusicPlay].player.rate==1 ? [[MusicPlayTools shareMusicPlay] musicPlay] : [[MusicPlayTools shareMusicPlay] musicPause];
            break;
        default:
            break;
            
    }
}


// 播放视频的时候不会停止，即使将视频置为nil也不会停止，通过下面这段代码完美解决
- (void)removeBoundaryTimeObserver {
    if (self.playbackObserver) {
        [[MusicPlayTools shareMusicPlay].player removeTimeObserver:self.playbackObserver];
        self.playbackObserver = nil;
    }
}

#pragma mark - 关闭定时器
-(void)cancelTimer {
    if (timer) {
        dispatch_cancel(timer);
        dispatch_source_cancel(timer);
        timer = nil;
    }
}

#pragma mark - 倒计时刷新
-(void)timerDown:(NSNotification *)notification {

    NSString  *name=[notification name];
    NSString  *object=[notification object];
    NSDictionary  *dict=[notification userInfo];
    NSInteger timeInterval = (NSInteger)[dict objectForKey:@"TimeInterval"];
    NSInteger remainTime = self.currentTotalTime - timeInterval;
    if (remainTime<=0) {
        remainTime = 0;
    }
    NSString * remainTimer =  [MFStringUtil getHHMMSSFromSS:[NSString stringWithFormat:@"%li",remainTime]];
    self.remainTimeLnl.text = remainTimer;
    NSLog(@"名称:%@----对象:%@",name,object);
    NSLog(@"获取的值:%@",[dict objectForKey:@"TimeInterval"]);
    
    // 倒计时结束，暂定播放
    if (remainTime<=0) {
        [[MusicPlayTools shareMusicPlay] musicPause];
        // [self removeBoundaryTimeObserver];
    }
    
}

#pragma mark - 倒计时事件
- (IBAction)timerBtnClicked:(id)sender {
    
    // 初始化
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 创建按钮
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"30分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentTimerIndex = @"0";
        self.currentTotalTime = 30*60;
        [self timeCountBtnAction:self.currentTotalTime];

    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"60分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentTimerIndex = @"1";
        self.currentTotalTime = 60*60;
        [self timeCountBtnAction:self.currentTotalTime];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"90分钟" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentTimerIndex = @"2";
        self.currentTotalTime = 90*60;
        [self timeCountBtnAction:self.currentTotalTime];

    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"播完当前音频再关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 关闭定时器
        [self cancelTimer];
        self.remainingTimeLbl.text = @"播完这条关闭";
        self.currentTimerIndex = @"3";
    }];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"关闭倒计时" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 关闭定时器
        [self cancelTimer];
        self.remainingTimeLbl.text = @"定时关闭";
        self.currentTimerIndex = @"4";
    }];
    // 取消按钮（只能创建一个）
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消按钮block");
    }];
    
    //将按钮添加到UIAlertController对象上
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:cancelAction];
    
    
    if ([@"0" isEqualToString:self.currentTimerIndex] ) {
        [action1 setValue:@true forKey:@"checked"];
    }else if ([@"1" isEqualToString:self.currentTimerIndex]) {
        [action2 setValue:@true forKey:@"checked"];
    }else if ([@"2" isEqualToString:self.currentTimerIndex]) {
        [action3 setValue:@true forKey:@"checked"];
    }else if ([@"3" isEqualToString:self.currentTimerIndex]) {
        [action4 setValue:@true forKey:@"checked"];
    }else {
        [action5 setValue:@true forKey:@"checked"];
    }
    
    //显示弹窗视图控制器
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - 倍速调整事件
- (IBAction)playSpeedBtnClicked:(id)sender {
    
    //初始化
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 创建按钮
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"0.7倍速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.ratevalue = 0.7;
        [MusicPlayTools shareMusicPlay].player.rate = self.ratevalue;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"正常倍速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ratevalue = 1.0;
        [MusicPlayTools shareMusicPlay].player.rate = self.ratevalue;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"1.2倍速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ratevalue = 1.2;
        [MusicPlayTools shareMusicPlay].player.rate = self.ratevalue;
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"1.5倍速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ratevalue = 1.5;
        [MusicPlayTools shareMusicPlay].player.rate = self.ratevalue;
    }];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"2倍速" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ratevalue = 2.0;
        [MusicPlayTools shareMusicPlay].player.rate = self.ratevalue;
    }];
    // 取消按钮（只能创建一个）
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消按钮block");
    }];
    
    //将按钮添加到UIAlertController对象上
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:cancelAction];
    
    // 设置已选中
    float rate = self.ratevalue;
    NSString *rateStr = [NSString stringWithFormat:@"%.1f", rate];
    if ([@"0.7" isEqualToString:rateStr] ) {
        [action1 setValue:@true forKey:@"checked"];
    }else if ([@"1.2" isEqualToString:rateStr]) {
        [action3 setValue:@true forKey:@"checked"];
    }else if ([@"1.5" isEqualToString:rateStr]) {
        [action4 setValue:@true forKey:@"checked"];
    }else if ([@"2.0" isEqualToString:rateStr]) {
        [action5 setValue:@true forKey:@"checked"];
    }else {
        [action2 setValue:@true forKey:@"checked"];
    }
    
    // 显示弹窗视图控制器
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - slider 进度调整
- (IBAction)sliderValueChanged:(id)sender {
    UISlider * slider = (UISlider *)sender;
    
    /* 方法二也可以
    //根据值计算时间
    float time = slider.value * CMTimeGetSeconds(self.player.currentItem.duration);
    //跳转到当前指定时间
    [self.player seekToTime:CMTimeMake(time, 1)];
    */
    AVPlayer * player = [[MusicPlayTools shareMusicPlay] player];
    
    CMTime videoLength = player.currentItem.asset.duration;
    float videoLengthInSeconds = videoLength.value/videoLength.timescale; // Transfers the CMTime duration into seconds
    
    [[MusicPlayTools shareMusicPlay].player seekToTime:CMTimeMakeWithSeconds(videoLengthInSeconds * [slider value], 1)
                              completionHandler:^(BOOL finished)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             // 锁屏时播放中心显示更新
             [[MusicPlayTools shareMusicPlay] configNowPlayingCenter:self.title];
         });
     }];

}



#pragma mark - 处理中断事件
-(void)handleInterreption:(NSNotification *)sender
{
    [self playClick:nil];
}


#pragma mark - 根据文件名获取路径
-(NSString *)readFilePath:(NSString *)name {
    
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSString * path = [documentDir stringByAppendingPathComponent:name];

    return path;
    
}

#pragma mark - 通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerDown:) name:kCountDownNotification object:nil];
}


#pragma mark - UI事件
/**
 *  点击播放/暂停按钮
 *
 *  @param sender 播放/暂停按钮
 */
- (IBAction)playClick:(UIButton *)sender {
    
    if([MusicPlayTools shareMusicPlay].player.rate==0){ // 暂停
        [[MusicPlayTools shareMusicPlay] musicPlay];
    }else {// 正在播放
        [[MusicPlayTools shareMusicPlay] musicPause];
    }
    
    [self setBackGroundImage:[MusicPlayTools shareMusicPlay].player.rate];
}

// 设置播放按钮背景图片
-(void)setBackGroundImage:(NSInteger)rate {
    
    if (rate==0) {
        [self.playOrPause setBackgroundImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateHighlighted];
    }else if (rate==1){
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateHighlighted];
    }
}


// 根据文件名，获取当前播放位置
-(NSInteger )getIndexOfCurrentPlayer:(NSString *)fileName {
    
    NSInteger index = 0;
    for (NSInteger i=0; i<self.downloadedAudiosArr.count; i++) {
        
        MusicInfoModel *musicInfo = [self.downloadedAudiosArr objectAtIndex:i];
        NSString * name = musicInfo.name;
        if ([name isEqualToString:fileName]) {
            index = i;
            break;
        }
    }
    
    return index;
}

#pragma mark - 上一首
- (IBAction)previousBtnClicked:(id)sender {
    
    NSInteger currentIndex = [self getIndexOfCurrentPlayer:self.fileName];
    if (currentIndex==0) {
        return;
    }else{
        MusicInfoModel *musicInfo = [self.downloadedAudiosArr objectAtIndex:currentIndex-1];
        self.fileName = musicInfo.name;
        [self changeToPlayer:self.fileName];
    }
}

#pragma mark - 下一首
- (IBAction)nextBtnClicked:(id)sender {
    
    NSInteger currentIndex = [self getIndexOfCurrentPlayer:self.fileName];
    if (currentIndex==self.downloadedAudiosArr.count-1) {
        return;
    }else{
        MusicInfoModel *musicInfo = [self.downloadedAudiosArr objectAtIndex:currentIndex+1];
        self.fileName = musicInfo.name;
        [self changeToPlayer:self.fileName];
       
    }
}

// 切换播放
- (void)changeToPlayer:(NSString *)fileName {
    
    // 更新 title 名称
    if ([fileName containsString:@"."]) {
        NSArray *strArr = [fileName componentsSeparatedByString:@"."];
        if (strArr.count>0) {
            fileName = [strArr objectAtIndex:0];
        }
    }
    self.cutomTitleLbl.text = fileName;
    
    [self localMusicPrePlay:fileName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 锁屏时播放中心显示更新
        [[MusicPlayTools shareMusicPlay] configNowPlayingCenter:self.fileName];
    });
}

#pragma mark - 查询本地缓存的音频文件
-(void)readDownloadedAudiosFiles {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    // fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    if (!self.downloadedAudiosArr) {
        self.downloadedAudiosArr = [[NSMutableArray alloc] init];
    }
    for (NSString *path in fileList) {
        if ([MFFileTypeJudgmentUtil isAudioType:path]) {
            
            MusicInfoModel *musicInfo = [[MusicInfoModel alloc] init];
            musicInfo.name = path;
            [self.downloadedAudiosArr addObject:musicInfo];
        }
    }
    
    
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


#pragma mark -- GCD 实现倒计时
- (void)timeCountBtnAction:(NSInteger)timeCount {
    
    if (timer) {
        dispatch_cancel(timer);
        // 关闭定时器
        dispatch_source_cancel(timer);
    }
     __block typeof(self) weakSelf = self;
    __block NSInteger second = timeCount;
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (second == 0) {
                second = timeCount;
                dispatch_cancel(timer);
                // 关闭定时器
                dispatch_source_cancel(timer);
                strongSelf.remainingTimeLbl.text = @"定时关闭";
                [[MusicPlayTools shareMusicPlay] musicPause];
            } else {
                second--;
                strongSelf.remainingTimeLbl.text = [MFStringUtil getHHMMSSFromSS:[NSString stringWithFormat:@"%li",second]];
            }
        });
    });
    dispatch_resume(timer);
}

@end
