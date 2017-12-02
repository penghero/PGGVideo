//
//  PGG_BeautyViewController.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 音频录制
 */
@interface PGG_BeautyViewController : UIViewController
//播放完成回调属性
@property(nonatomic, copy) void (^mp3FileNameBlock)(NSString *mp3FileName);

@end
