//
//  MMImagePickerComponent.h
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "UIView+Geometry.h"
#import "MBProgressHUD.h"

//#### 宏定义
// 6p?
#define kDeviceIsIphone6p               CGSizeEqualToSize(CGSizeMake(1242,2208), [[[UIScreen mainScreen] currentMode] size])
// 图片边距
#define kBlankWidth                     4.0f
// 底部菜单高度
#define kBottomHeight                   44.0f
// RGB颜色
#define RGBColor(r,g,b,a)               [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
// 主颜色
#define kMainColor                      RGBColor(26, 181, 237, 1.0)
// 图片路径
#define MMImagePickerSrcName(file)      [@"MMImagePicker.bundle" stringByAppendingPathComponent:file]
