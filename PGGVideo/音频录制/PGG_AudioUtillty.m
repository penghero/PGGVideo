//
//  PGG_AudioUtillty.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/27.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_AudioUtillty.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>
#import <lame/lame.h>
#import "Utility.h"


@interface PGG_AudioUtillty()<AVAudioRecorderDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate>{
    AVAudioRecorder *audioRecorder;
    AVPlayer *audioPlayer;
    NSString *filePath;
}
@end

@implementation PGG_AudioUtillty

#pragma mark - 单例
+ (instancetype)instance {
    static PGG_AudioUtillty *audioUtillty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioUtillty = [[self alloc] init];
    });
    return audioUtillty;
}

#pragma mark - >>>录制相关
    //开始录制
- (void)beginRecord
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    BOOL change = [[[NSUserDefaults standardUserDefaults] objectForKey:@"arpiece"] boolValue];
    UInt32 audioRouteOverride = change ?kAudioSessionOverrideAudioRoute_None:kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                   [NSNumber numberWithFloat:11025.0], AVSampleRateKey,
                                   [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt: AVAudioQualityMin],AVEncoderAudioQualityKey, nil];
    
        //获取音频文件的路径:xxxx/Audio/时间戳.caf
    filePath = [Utility getAudioFilePath];
    NSURL *audioURL = [NSURL fileURLWithPath:filePath];
    NSError *error;
    audioRecorder = [[ AVAudioRecorder alloc] initWithURL:audioURL settings:recordSetting error:&error];
    if (error)
        {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                            message:@"录音失败"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
        }
    [audioRecorder setDelegate:self];
    audioRecorder.meteringEnabled = YES;
    if ([audioRecorder prepareToRecord]) {
        [audioRecorder record];
    }
}

    //取消录制
- (void)cancelRecord
{
    [audioRecorder stop];
    [audioRecorder deleteRecording];
    audioRecorder = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

    //完成录制>>返回音频路径
- (NSString *)finishRecord
{
    [audioRecorder stop],audioRecorder = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
        //aac、caf 到mp3转换、并写入数据
    NSString *mp3Path = [self audioToMP3:filePath];
    return mp3Path;
}

    //音频转码caf转map3
- (NSString *)audioToMP3:(NSString *)cafPath
{
        //MP3路径
    NSString *mp3Path = [cafPath stringByReplacingOccurrencesOfString:@".caf" withString:@".mp3"];
    @try {
        int read, write;
        FILE *pcm = fopen([cafPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                               //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0){
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
                //转换完的音频写入到指定路径下
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        PGGLog(@"音频转码异常：%@",[exception description]);
    }
    @finally {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:cafPath error:nil];
        return mp3Path;
    }
    return nil;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    PGGLog(@"录制完成");
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    PGGLog(@"录制出错");
}
#pragma mark - >>>播放相关
    //播放某路径下的文件
- (void)playAudioByFileURL:(NSURL *)url;
{
    if (audioPlayer) {
        _isPlaying = NO;
        [audioPlayer pause],audioPlayer = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    audioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [audioPlayer play];
        //扬声器
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        //添加观察者
    _isPlaying = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

    //播放
- (void)play
{
    _isPlaying = YES;
    [audioPlayer play];
}

    //暂停
- (void)pause
{
    _isPlaying = NO;
    [audioPlayer pause];
}

#pragma mark - 播放完成
- (void)playToEnd
{
    _isPlaying = NO;
    if (self.audioPlayFinish) {
        self.audioPlayFinish();
    }
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
