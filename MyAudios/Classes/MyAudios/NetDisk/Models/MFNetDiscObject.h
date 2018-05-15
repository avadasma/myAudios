//
//  MFNetDiscObject.h
//  MyAdios
//
//  Created by chang on 2017/7/16.
//  Copyright © 2017年 chang. All rights reserved.
//
//  网盘对象

#import <Foundation/Foundation.h>

@interface MFNetDiscObject : NSObject

@property(nonatomic,strong)NSString *netDiscName;// 网盘名称
@property(nonatomic,strong)NSString *iconName;// 网盘icon
@property(nonatomic)BOOL isLogined;// 是否已登录

@end
