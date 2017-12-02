//
//  PGGVideoViewCell.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/17.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGGVideoViewCell.h"
#import <UIImageView+WebCache.h>
#import "PGGVideoModel.h"

@implementation PGGVideoViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(PGGVideoModel *)model {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleDescription.text = model.title;
    [self.videoImageView sd_setImageWithURL:[NSURL URLWithString:model.cover]];
    [self.whereCome setTitle:model.topicName forState:UIControlStateNormal];
    self.count.text = [NSString stringWithFormat:@"%ld",(long)model.sizeSD];
    self.whereCome.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.count.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
