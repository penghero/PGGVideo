//
//  PGGVideoViewCell.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/17.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 视频cell
 */
@class PGGVideoModel;
@interface PGGVideoViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *titleDescription;
@property (strong, nonatomic) IBOutlet UIImageView *videoImageView;
@property (strong, nonatomic) IBOutlet UIButton *openVideo;
@property (strong, nonatomic) IBOutlet UIButton *whereCome;
@property (strong, nonatomic) IBOutlet UILabel *count;
@property (strong, nonatomic) IBOutlet UIButton *downVideo;

@property(strong,nonatomic)PGGVideoModel * model;

@end
