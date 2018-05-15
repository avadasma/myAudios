//
//  Language.m
//  Spring3G
//
//  Created by juuman on 14-1-23.
//  Copyright (c) 2014年 SpringAirlines. All rights reserved.
//

#import "Language.h"

@implementation Language
@synthesize LanguageName;
@synthesize forSISName;
@synthesize forURLName;

#pragma mark -  初始化
- (id)initWithLanguageName:(NSString *)name forSISName:(NSString *)sis forURLName:(NSString *)url
{
    self = [super init];
    if (self) {
        LanguageName=name;
        forSISName=sis;
        forURLName=url;
    }
    return self;
}
@end
