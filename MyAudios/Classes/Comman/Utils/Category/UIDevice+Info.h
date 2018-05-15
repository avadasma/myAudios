//
//  UIDevice+Info.h
//  MyAudios
//
//  Created by chang on 2018/3/19.
//  Copyright © 2018年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Info)


#pragma mark - 获取当前的唯一标识符UUID
- (NSString *)getCurrentDeviceUUID;

@end
