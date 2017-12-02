//
//  PGG_DownCell.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/12/1.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_DownCell.h"
#import "PGGVideoModel.h"

@implementation PGG_DownCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(PGGVideoModel *)model {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLab.text = model.title;
    self.URLstr = model.mp4_url;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
