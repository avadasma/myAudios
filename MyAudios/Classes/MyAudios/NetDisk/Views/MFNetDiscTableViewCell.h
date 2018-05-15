//
//  MFNetDiscTableViewCell.h
//  MyAdios
//
//  Created by chang on 2017/7/16.
//  Copyright © 2017年 chang. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MFNetDiscObject;
@interface MFNetDiscTableViewCell : UITableViewCell



#pragma mark - 设置cell显示信息
-(void)setupCell:(MFNetDiscObject *)netDisc;


@end
