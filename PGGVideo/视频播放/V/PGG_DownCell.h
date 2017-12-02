//
//  PGG_DownCell.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/12/1.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PGGVideoModel;
@interface PGG_DownCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIProgressView *progressView;//进度条
@property (strong, nonatomic) IBOutlet UILabel *speedProgress;//进度百分比
@property (strong, nonatomic) IBOutlet UILabel *speed;//网速
@property (strong, nonatomic) IBOutlet UIButton *openAndStopBtn;//开始和暂停
@property (strong, nonatomic) IBOutlet UIButton *openBtn;//播放
@property (strong, nonatomic) IBOutlet UILabel *titleLab;//标题
@property(nonatomic,copy)NSString  * URLstr;//下载地址
@property(strong,nonatomic)PGGVideoModel * model;

@end
