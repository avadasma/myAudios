//
//  MFFolderTableViewCell.m
//  MyAudios
//
//  Created by chang on 2018/1/30.
//  Copyright © 2018年 chang. All rights reserved.
//

#import "MFFolderTableViewCell.h"
#import "MFFolder.h"

@implementation MFFolderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle: style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nibArray = [[NSBundle mainBundle]loadNibNamed:@"MFFolderTableViewCell" owner:nil options:nil];
        self = [nibArray lastObject];
    }
    return self;
}*/

- (void)configureForFolder:(MFFolder *)folder
{
    self.imgVIew.image = [UIImage imageNamed:folder.imgName];
    self.nameLbl.text = folder.name;
    
    self.nameLbl.numberOfLines = 0;
    self.nameLbl.minimumScaleFactor = 0.6;
    self.nameLbl.adjustsFontSizeToFitWidth = YES;
}


@end
