//
//  MusicInfoModel.h
//  MyAudios
//
//  Created by chang on 2018/1/18.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicInfoModel : NSObject

@property (nonatomic, strong) NSString *mp3Url;// 音乐地址
@property (nonatomic, strong) NSString *ID;//  歌曲ID (实际名称是id(小写的))
@property (nonatomic, strong) NSString *name;// 歌名
@property (nonatomic, strong) NSString *picUrl;// 图片地址
@property (nonatomic, strong) NSString *blurPicUrl;// 模糊图片地址
@property (nonatomic, strong) NSString *album;// 专辑
@property (nonatomic, strong) NSString *singer;// 歌手
@property (nonatomic, strong) NSString *duration;// 时长
@property (nonatomic, strong) NSString *artists_name;// 作曲
@property (nonatomic, strong) NSArray *timeLyric;// 歌词 (实际名称是lyric);

@end
