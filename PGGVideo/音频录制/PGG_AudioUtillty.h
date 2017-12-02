//
//  PGG_AudioUtillty.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/27.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 音频的录制及播放[支持本地和网络]
 */

@interface PGG_AudioUtillty : NSObject

    //音频播放完成
@property(nonatomic, copy) void (^audioPlayFinish)();
    //音频是否正在播放
@property(nonatomic, assign) BOOL isPlaying;
    //单例
+ (instancetype)instance;

#pragma mark - 录制相关
    //开始录制
- (void)beginRecord;
    //取消录制
- (void)cancelRecord;
    //完成录制>>返回音频路径
- (NSString *)finishRecord;
#pragma mark - 播放相关
    //播放
- (void)play;
    //暂停
- (void)pause;
    //播放某路径下的文件
- (void)playAudioByFileURL:(NSURL *)url;

@end
