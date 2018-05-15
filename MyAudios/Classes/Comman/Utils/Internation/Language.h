//
//  Language.h
//  Spring3G
//
//  Created by juuman on 14-1-23.
//  Copyright (c) 2014年 SpringAirlines. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject{
}
@property (nonatomic,strong)NSString *LanguageName;//语言名
@property (nonatomic,strong)NSString *forSISName;//系统识别码
@property (nonatomic,strong)NSString *forURLName;//url传输码

#pragma mark -  初始化
- (id)initWithLanguageName:(NSString *)name forSISName:(NSString *)sis forURLName:(NSString *)url;

@end
