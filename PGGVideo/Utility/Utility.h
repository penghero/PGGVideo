//
//  Utility.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface Utility : NSObject

#pragma mark - 时间
+ (long long)getNowTimestampSec;
+ (long long)getNowTimestampMesc;
+ (NSString *)getNowTimestampString;
+ (NSString *)getHMSFormatBySeconds:(int)seconds;

#pragma mark - 时间戳与日期的相互转换
//时间戳转日期
+ (NSString *)getDateByTimestamp:(long long)timestamp type:(NSInteger)timeType;
//日期转时间戳
+ (NSInteger)getTimestampByDate:(NSString *)dateString type:(NSInteger)timeType;

#pragma mark - 文件路径
+ (NSString *)getDocDir;
+ (NSString *)getVideoDir;
+ (NSString *)getAudioDir;
+ (NSString *)getAudioFilePath;
+ (NSString *)getTempPicDir;

#pragma mark - 获取视频缩略图
+ (UIImage *)getVideoImage:(NSURL *)videoPath;

#pragma mark - 权限
+ (BOOL)isAudioRecordPermit;
+ (BOOL)isPhotoLibraryPermit;
+ (BOOL)isCameraPermit;

#pragma mark - 保存图片/视频
+ (void)writeImageToMUKAssetsGroup:(UIImage *)image completion:(void(^)(BOOL isSuccess))completion;
+ (void)writeVideoToMUKAssetsGroup:(NSURL *)videoURL completion:(void(^)(BOOL isSuccess))completion;

#pragma mark - 图片处理
+ (UIImage *)fixOrientation:(UIImage *)aImage;
+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage;
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

@end
