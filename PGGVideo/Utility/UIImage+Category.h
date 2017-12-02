//
//  UIImage+Category.h
//  MediaUnitedKit
//
//  Created by LEA on 2017/9/21.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Category)

#pragma mark - 图片素描处理

/**
 图像素描处理

 @return 素描
 */
- (UIImage *)sketchImage;

#pragma mark - 其他
/**
 颜色转图片
 
 @param color 颜色
 @return 图片
 */
+ (UIImage *)imageColor:(UIColor *)color;

#pragma mark - 图像处理

/**
 等比压缩

 @param newSize 压缩后的大小
 @return 压缩后的图片
 */
- (UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;


/**
 添加边框

 @param index 索引
 @return 合成后的图片
 */
- (UIImage *)imageAddBorderByIndex:(NSInteger)index;


/**
 图片旋转

 @return 处理后的图片
 */
- (UIImage *)rotateImage;

@end
