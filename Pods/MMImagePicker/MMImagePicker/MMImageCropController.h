//
//  MMImageCropController.h
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  图片裁剪

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MMImageCropController : UIViewController

// 原始图片
@property (nonatomic,strong) UIImage *originalImage;
// 裁剪的大小[默认方形、屏幕宽度]
@property (nonatomic,assign) CGSize imageCropSize;
// 裁剪后回传
@property (nonatomic,copy) void(^imageCropBlock)(UIImage *cropImage);

@end
