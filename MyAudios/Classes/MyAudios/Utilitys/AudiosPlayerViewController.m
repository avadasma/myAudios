//
//  AudiosPlayerViewController.m
//  MyAudios
//
//  Created by chang on 2017/8/1.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "AudiosPlayerViewController.h"
#import "MFStringUtil.h"
#import "MFDownloadedViewController.h"
#import "MusicInfoModel.h"
#import "MusicPlayTools.h"

#define CUSTOMTITLEVIEWWIDTH mainScreenWidth - 166

@interface AudiosPlayerViewController ()<MusicPlayToolsDelegate>

@property (weak, nonatomic) IBOutlet UIView *container;//播放器容器
@property (weak, nonatomic) IBOutlet UIButton *playOrPause;//播放/暂停按钮
@property (weak, nonatomic) IBOutlet UISlider *mySlider;// 播放进度条
@property (weak, nonatomic) IBOutlet UILabel *playedTimeLbl;// 已播放时间
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLbl;// 剩余时间


@end

@implementation AudiosPlayerViewController

#pragma mark - UIView Custom Methods
- (void)viewDidLoad {
    [super viewDidLoad];
  
    // 右上方播放列表按钮
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"播放列表" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked:)];
    self.navigationItem.rightBarButtonItem= rightItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    // 处理中断事件的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    // 设置 MusicPlayTools 代理
    [[MusicPlayTools shareMusicPlay] setDelegate:self];
    [[MusicPlayTools shareMusicPlay] configNowPlayingCenter:self.title];
}

-(void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    // 播放
    [self localMusicPrePlay:self.fileName];
    [self setBackGroundImage:1];
    
    // 该页面titleView变窄些，因为右边有播放列表按钮
    CGRect frame = self.cutomTitleLbl.frame;
    frame.size.width = CUSTOMTITLEVIEWWIDTH;
    self.cutomTitleLbl.frame = frame;
}

-(void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    
    [self.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - MusicPlayToolsDelegate Methods
// 外界实现这个方法的同时, 也将参数的值拿走了, 这样我们起到了"通过代理方法向外界传递值"的功能.
-(void)getCurTiem:(NSString *)curTime Totle:(NSString *)totleTime Progress:(CGFloat)progress {
    // 更新播放进度条
    self.mySlider.value = progress;
    NSLog(@"total==== %@",totleTime);
    NSLog(@"current==== %@",curTime);
    self.playedTimeLbl.text = curTime;
    self.totalTimeLbl.text = totleTime;
}

// 播放结束之后, 如何操作由外部决定.
-(void)endOfPlayAction {
    NSLog(@"播放完毕...");
}


#pragma mark - 私有方法

- (IBAction)mySliderValueChanged:(id)sender {
    
    UISlider * slider = (UISlider *)sender;
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

#pragma mark- 前往播放列表
-(void)rightButtonClicked:(id)sender {

    if (self.navigationController.topViewController == self) {
        MFDownloadedViewController *listPlayerVC = [[MFDownloadedViewController alloc] init];
        listPlayerVC.isPlayList = YES;
        [self.navigationController pushViewController:listPlayerVC animated:YES];
    }
}


// 处理中断事件
-(void)handleInterreption:(NSNotification *)sender
{
    if(self.player.rate==0){ // 暂停
        [[MusicPlayTools shareMusicPlay] musicPlay];
    }else if(self.player.rate==1){// 正在播放
        [[MusicPlayTools shareMusicPlay] musicPause];
    }
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
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateNormal];
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"playBtn"] forState:UIControlStateHighlighted];
    }else if (rate==1){
        [self.playOrPause setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateNormal];
        [self.playOrPause  setBackgroundImage:[UIImage imageNamed:@"pauseBtn"] forState:UIControlStateHighlighted];
    }
}


@end
