//
//  Utility.m
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//
#import "Utility.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

static NSString *kAssetsGroup = @"鹏哥哥Video";
#define ORIGINAL_MAX_WIDTH 640.0f

@implementation Utility

#pragma mark - 时间
//获取当前时间的时间戳(秒)
+ (long long)getNowTimestampSec
{
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [dat timeIntervalSince1970];
    NSInteger Timestamp = a;
    return (int)Timestamp;
}

//获取当前时间的时间戳(毫秒)
+ (long long)getNowTimestampMesc
{
    NSDate *date = [NSDate date];
    long long timeInterval = [date timeIntervalSince1970] * 1000;
    return timeInterval;
}

//获取当前时间的时间戳字符串(秒)
+ (NSString *)getNowTimestampString
{
    NSString *timeString = [self getDateByTimestamp:[self getNowTimestampSec] type:17];
    return timeString;
}

+ (NSString *)getHMSFormatBySeconds:(int)seconds
{
    NSString *hour = [NSString stringWithFormat:@"%02d",seconds/3600];
    NSString *minute = [NSString stringWithFormat:@"%02d",(seconds%3600)/60];
    NSString *second = [NSString stringWithFormat:@"%02d",seconds%60];
    NSString *hmsFormat = [NSString stringWithFormat:@"%@:%@:%@",hour,minute,second];
    return hmsFormat;
}

#pragma mark - 时间戳与日期的相互转换
//时间戳转日期
+ (NSString *)getDateByTimestamp:(long long)timestamp type:(NSInteger)timeType
{
    if (timestamp == 0) {
        return nil;
    }
    NSTimeInterval time = timestamp;
    NSDate *detaildate =[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    //分类处理
    switch (timeType)
    {
        case 0: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        }
        case 1:{
            [dateFormatter setDateFormat:@"yyyy-MM-dd (EEE)"];
            break;
        }
        case 2: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        }
        case 3: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm EEE"];
            break;
        }
        case 4: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        }
        case 5: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;
        }
        case 6: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            break;
        }
        case 7: {
            [dateFormatter setDateFormat:@"yyyy年MM月"];
            break;
        }
        case 8: {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            break;
        }
        case 9:{
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 EEE"];
            break;
        }
        case 10: {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
            break;
        }
        case 11: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;
        }
        case 12: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            break;
        }
        case 13: {
            [dateFormatter setDateFormat:@"yyyy.MM.dd"];
            break;
        }
        case 14: {
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            break;
        }
        case 15: {
            [dateFormatter setDateFormat:@"dd M EEE"];
            break;
        }
        case 16: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEE"];
            break;
        }
        case 17: {
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
            break;
        }
        default:
            break;
    }
    NSString *timeString = [dateFormatter stringFromDate:detaildate];
    return timeString;
}

//日期转时间戳
+ (NSInteger)getTimestampByDate:(NSString *)dateString type:(NSInteger)timeType;
{
    if (!dateString) {
        return 0;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    switch (timeType)
    {
        case 0: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            break;
        }
        case 1:{
            [dateFormatter setDateFormat:@"yyyy-MM-dd (EEE)"];
            break;
        }
        case 2: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            break;
        }
        case 3: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm EEE"];
            break;
        }
        case 4: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        }
        case 5: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;
        }
        case 6: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            break;
        }
        case 7: {
            [dateFormatter setDateFormat:@"yyyy年MM月"];
            break;
        }
        case 8: {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
            break;
        }
        case 9:{
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 EEE"];
            break;
        }
        case 10: {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
            break;
        }
        case 11: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd"];
            break;
        }
        case 12: {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            break;
        }
        case 13: {
            [dateFormatter setDateFormat:@"yyyy.MM.dd"];
            break;
        }
        case 14: {
            [dateFormatter setDateFormat:@"MM-dd HH:mm"];
            break;
        }
        case 15: {
            [dateFormatter setDateFormat:@"dd M EEE"];
            break;
        }
        case 16: {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss EEE"];
            break;
        }
        case 17: {
            [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
            break;
        }
        default:
            break;
    }
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [dateFormatter setTimeZone:timeZone];
    NSDate *date = [dateFormatter dateFromString:dateString];
    NSTimeInterval a = [date timeIntervalSince1970];
    NSInteger Timestamp = a;
    return Timestamp;
}

#pragma mark - 文件、路劲
//doc路径
+( NSString *)getDocDir
{
    NSArray *searchPaths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return documentPath;
}

// 获取视频文件夹路径
+ (NSString *)getVideoDir
{
    NSString *docDir = [self getDocDir];
    NSString *videoDir = [docDir stringByAppendingPathComponent:@"Video"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return videoDir;
}
// 获取音频文件夹路径
+ (NSString *)getAudioDir
{
    NSString *docDir = [self getDocDir];
    NSString *audioDir = [docDir stringByAppendingPathComponent:@"Audio"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:audioDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:audioDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return audioDir;
}

// 获取音频文件路径
+ (NSString *)getAudioFilePath
{
    NSString *audioDir = [self getAudioDir];
    NSString *filepath = [audioDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",[self getNowTimestampString]]];
    return filepath;
}

// 图片临时路径（用于图像处理）
+ (NSString *)getTempPicDir
{
    NSString *docDir = [self getDocDir];
    NSString *picDir = [docDir stringByAppendingPathComponent:@"TempPic"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:picDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:picDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return picDir;
}

#pragma mark - 产生视频缩略图
+ (UIImage *)getVideoImage:(NSURL *)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.maximumSize = CGSizeMake(kScreen_Width, kScreen_Height);
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(10, 10) actualTime:NULL error:&error];
    UIImage *image = [UIImage imageWithCGImage: img];
    return image;
}

#pragma mark - 权限
+ (BOOL)isAudioRecordPermit
{
    __block BOOL isOK = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                isOK = YES;
            } else {
                isOK = NO;
            }
        }];
    }
    return isOK;
}

+ (BOOL)isPhotoLibraryPermit
{
    __block BOOL isOK = YES;
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
        isOK = NO;
    }
    return isOK;
}

+ (BOOL)isCameraPermit
{
    __block BOOL isOK = YES;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        isOK = NO;
    }
    return isOK;
}

#pragma mark - 创建自定义相册
+ (void)writeImageToMUKAssetsGroup:(UIImage *)image completion:(void(^)(BOOL isSuccess))completion
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status)
            {
                case PHAuthorizationStatusAuthorized://权限打开
                {
                    //获取所有自定义相册
                    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    //筛选
                    __block PHAssetCollection *simoCollection = nil;
                    __block NSString *collectionID = nil;
                    for (PHAssetCollection *collection in collections)  {
                        if ([collection.localizedTitle isEqualToString:kAssetsGroup]) {
                            simoCollection = collection;
                            break;
                        }
                    }
                    if (!simoCollection) {
                        //创建相册
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            collectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAssetsGroup].placeholderForCreatedAssetCollection.localIdentifier;
                        } error:nil];
                        //取出
                        simoCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionID] options:nil].firstObject;
                    }
                    //保存图片
                    __block NSString *assetId = nil;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        if (@available(iOS 9.0, *)) {
                            assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
                        } else {
                                // Fallback on earlier versions
                        }
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (error) {
                            PGGLog(@"保存橡胶相册失败");
                            if (completion) completion(NO);
                            return ;
                        }
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:simoCollection];
                            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                            // 添加图片到相册中
                            [request addAssets:@[asset]];
                            
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                PGGLog(@"保存自定义相册失败");
                            }
                            if (completion) completion(success);
                        }];
                    }];
                    
                    break;
                }
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        return;
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请在设置>隐私>相册中开启权限"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

+ (void)writeVideoToMUKAssetsGroup:(NSURL *)videoURL completion:(void(^)(BOOL isSuccess))completion
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status)
            {
                case PHAuthorizationStatusAuthorized://权限打开
                {
                    //获取所有自定义相册
                    PHFetchResult *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
                    //筛选
                    __block PHAssetCollection *simoCollection = nil;
                    __block NSString *collectionID = nil;
                    for (PHAssetCollection *collection in collections)  {
                        if ([collection.localizedTitle isEqualToString:kAssetsGroup]) {
                            simoCollection = collection;
                            break;
                        }
                    }
                    if (!simoCollection) {
                        //创建相册
                        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                            collectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:kAssetsGroup].placeholderForCreatedAssetCollection.localIdentifier;
                        } error:nil];
                        //取出
                        simoCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionID] options:nil].firstObject;
                    }
                    //保存图片
                    __block NSString *assetId = nil;
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        if (@available(iOS 9.0, *)) {
                            assetId = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL].placeholderForCreatedAsset.localIdentifier;
                        } else {
                                // Fallback on earlier versions
                        }
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        if (error) {
                            PGGLog(@"视频保存橡胶相册失败");
                            if (completion) completion(NO);
                            return ;
                        }
                        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:simoCollection];
                            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                            // 添加图片到相册中
                            [request addAssets:@[asset]];
                            
                        } completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (error) {
                                PGGLog(@"视频保存自定义相册失败");
                            }
                            if (completion) completion(success);
                        }];
                    }];
                    
                    break;
                }
                case PHAuthorizationStatusDenied:
                case PHAuthorizationStatusRestricted:
                {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        return;
                    }
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                    message:@"请在设置>隐私>相册中开启权限"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"知道了"
                                                          otherButtonTitles:nil, nil];
                    [alert show];
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

#pragma mark - 图片
+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    //我们需要计算出适当的变换使图像直立。
    //我们在2个步骤：如果左/右/下就旋转，如果镜像就翻转。
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        PGGLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}
@end
