//
//  MFStringUtil.m
//  MyAudios
//
//  Created by chang on 2017/8/12.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFStringUtil.h"

@implementation MFStringUtil

#pragma mark - 判断是否为空
+ (BOOL)isEmpty:(NSString *)str {
    if ([str isKindOfClass:[NSNumber class]]) {
        str = [NSString stringWithFormat:@"%@",str];
    }
    
    return str == nil || [[MFStringUtil trim:str] length] == 0 || [[str lowercaseString] isEqualToString:@"null"];
}
#pragma mark - 去掉所有空格 @author xuHui 2011-07-13 此方法主要用于封装系统的方法
+ (NSString *)trim:(NSString *)str {
    if(str==nil){
        return @"";
    }else{
        @try {
            
            NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
            
            NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
            
            NSArray *parts = [str componentsSeparatedByCharactersInSet:whitespaces];
            
            NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
            
            NSString *newStr = [filteredArray componentsJoinedByString:@""];
            return newStr;
        }
        @catch (NSException *exception) {
            NSLog(@"%@",[exception reason]);
            return str;
        }
        @finally {
            
        }
    }
}


#pragma mark - 传入 秒  得到 xx:xx:xx
+ (NSString *)getHHMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

#pragma mark - 传入 秒  得到  xx分钟xx秒
+ (NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%ld",seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
    
    NSLog(@"format_time : %@",format_time);
    
    return format_time;
}

#pragma marl - 以下 added by chang
// 获取指定宽度width的字符串在UITextView上的高度
+ (float) heightForString:(NSString *)str andWidth:(float)width{
    UITextView * textView = [[UITextView alloc] init];
    textView.font = [UIFont systemFontOfSize:17.0];
    textView.text = str;
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    // 边界处理
    float cellHeight = sizeToFit.height;
    if (cellHeight<56) {
        cellHeight = 56;
    }
    if (cellHeight>96){
        cellHeight = 96;
    }
    return cellHeight;
}

@end
