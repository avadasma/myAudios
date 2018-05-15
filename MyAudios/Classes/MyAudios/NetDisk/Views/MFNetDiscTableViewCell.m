//
//  MFNetDiscTableViewCell.m
//  MyAdios
//
//  Created by chang on 2017/7/16.
//  Copyright © 2017年 chang. All rights reserved.
//

#import "MFNetDiscTableViewCell.h"
#import "MFNetDiscObject.h"

@interface MFNetDiscTableViewCell ()

@property(nonatomic,weak)IBOutlet UIImageView *imagView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *loginInfoLabel;

@end

@implementation MFNetDiscTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

#pragma mark - 设置cell显示信息
-(void)setupCell:(MFNetDiscObject *)netDisc {
    
    if (self) {
        self.nameLabel.text = netDisc.netDiscName;
        self.imagView.image = [UIImage imageNamed:netDisc.iconName];
        self.loginInfoLabel.text = netDisc.isLogined?@"已登录"
        :@"登录";
        
        [self.imagView.layer setMasksToBounds:YES];
        [self.imagView.layer setCornerRadius:3.0];
    }
}


@end
