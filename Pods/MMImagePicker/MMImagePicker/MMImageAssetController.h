//
//  MMImageAssetController.h
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  选择任一图库展示

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

//#### MMALAsset
#pragma mark - MMALAsset

@interface MMALAsset : NSObject

@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,assign) BOOL isSelected;

@end

//### MMImageAssetController
@interface MMImageAssetController : UIViewController

// 所选相册
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
// 主色调[默认蓝色]
@property (nonatomic, strong) UIColor *mainColor;
// 是否显示原图选项[默认NO]
@property (nonatomic, assign) BOOL showOriginImageOption;
// 只选取一张[默认NO]
@property (nonatomic, assign) BOOL singleImageOption;
// 是否选取一张且需要裁剪[默认NO]
@property (nonatomic, assign) BOOL cropImageOption;
// 裁剪的大小[默认方形、屏幕宽度]
@property (nonatomic, assign) CGSize imageCropSize;
// 最大选择数目[默认9张]
@property (nonatomic, assign) NSInteger maximumNumberOfImage;
// 选择回传[isOrigin:是否回传原图[可用于控制图片压系数]]
@property (nonatomic,copy) void(^completion)(NSArray *info,BOOL isOrigin, BOOL isCancel);

@end
