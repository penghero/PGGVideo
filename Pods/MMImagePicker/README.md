# MMImagePickerCheeryLau

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/CheeryLau/MMImagePicker/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/MMImagePicker.svg?style=flat)](http://cocoapods.org/pods/MMImagePicker)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/MMImagePicker.svg?style=flat)](http://cocoapods.org/pods/MMImagePicker)&nbsp;

![MMImagePicker](Screenshot.png)

`MMImagePicker`基于`AssetsLibrary`框架的图片选择器：支持多选、单选、对图片进行裁剪、选择原图、可预览。若想使用基于`Photos`框架的图片选择器，点击[这里](https://github.com/CheeryLau/MMPhotoPicker)。



## 使用

1. `pod "MMImagePicker"` ;
2. `pod install` / `pod update`;
3. `#import <MMImagePicker/MMImagePickerController.h>`.

```objc
MMImagePickerController属性介绍：
   
// 主色调[默认蓝色]
@property (nonatomic, strong) UIColor *mainColor;
// 是否回传原图[可用于控制图片压系数]
@property (nonatomic, assign) BOOL isOrigin;
// 是否显示原图选项[默认NO]
@property (nonatomic, assign) BOOL showOriginImageOption;
// 是否只选取一张[默认NO]
@property (nonatomic, assign) BOOL singleImageOption;
// 是否选取一张且需要裁剪[默认NO]
@property (nonatomic, assign) BOOL cropImageOption;
// 裁剪的大小[默认方形、屏幕宽度]
@property (nonatomic, assign) CGSize imageCropSize;
// 最大选择数目[默认9张]
@property (nonatomic, assign) NSInteger maximumNumberOfImage;
// 代理
@property (nonatomic, assign) id<MMImagePickerDelegate> delegate;
```

  
## 示例

```objc
MMImagePickerController *mmVC = [[MMImagePickerController alloc] init];
// 代理
mmVC.delegate = self;  
// 最大图片选择数量 
mmVC.maximumNumberOfImage = 9; 
// 显示原图选项
mmVC.showOriginImageOption = YES;
UINavigationController *mmNav = [[UINavigationController alloc] initWithRootViewController:mmVC];
[self.navigationController presentViewController:mmNav animated:YES completion:nil];
```
```objc
#pragma mark - MMImagePickerDelegate
- (void)mmImagePickerController:(MMImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
     NSLog(@"%@",info);
}

 - (void)mmImagePickerControllerDidCancel:(MMImagePickerController *)picker
{
     NSLog(@"Cancel");
}
```

## 注意

1. 需要在Info.plist中添加隐私授权：`Privacy - Photo Library Usage Description`；
2. 如果相册名称需要根据手机语言环境显示相应语言，需要在Info.plist中设置`Localized resources can be mixed` 为 `YES`。

## END

有问题可以联系我【QQ:1539901764 要备注来源哦】，如果这个工具对你有些帮助，请给我一个star、watch。O(∩_∩)O谢谢


