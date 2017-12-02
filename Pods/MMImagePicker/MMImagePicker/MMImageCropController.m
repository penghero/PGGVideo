//
//  MMImageCropController.m
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMImageCropController.h"
#import "MMImagePickerComponent.h"

@interface MMImageCropController ()

// 图片显示视图
@property (nonatomic,strong) UIImageView *imageView;
// 蒙版
@property (nonatomic,strong) UIView *overlayView;
// 裁剪frame
@property (nonatomic, assign) CGRect cropFrame;
// 记录frame
@property (nonatomic, assign) CGRect oldFrame;
// 最大frame
@property (nonatomic, assign) CGRect largeFrame;
// 最终frame
@property (nonatomic, assign) CGRect latestFrame;
// 比例
@property (nonatomic, assign) CGFloat limitRatio;

@end

@implementation MMImageCropController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"图片裁剪";
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:MMImagePickerSrcName(@"mmphoto_back")]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(leftBarItemAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarItemAction)];
    
    //添加视图
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.overlayView];
    
    //添加手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureAction:)];
    [self.view addGestureRecognizer:pinch];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:pan];
    
    //赋值
    if (_imageCropSize.width * _imageCropSize.height == 0) {
        _imageCropSize = CGSizeMake(self.view.width, self.view.width);
    }
    _limitRatio = 3.f;
    _cropFrame = CGRectMake(0, (self.view.height-64-_imageCropSize.height)/2, _imageCropSize.width, _imageCropSize.height);
    CGFloat oriWidth = _cropFrame.size.width;
    CGFloat oriHeight = oriWidth * _originalImage.size.height / _originalImage.size.width;
    CGFloat oriX = _cropFrame.origin.x + (_cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = _cropFrame.origin.y + (_cropFrame.size.height - oriHeight) / 2;
    _oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    _latestFrame = _oldFrame;
    _largeFrame = CGRectMake(0, 0, _limitRatio * _oldFrame.size.width, _limitRatio * _oldFrame.size.height);
    self.imageView.frame = _oldFrame;
    self.imageView.image = _originalImage;

    //裁剪区
    [self overlayClipping];
}

#pragma mark - 事件处理
- (void)leftBarItemAction
{
    self.imageView.frame = _oldFrame;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBarItemAction
{
    if (self.imageCropBlock) {
        self.imageCropBlock([self getCropImage]);
    }
}

#pragma mark - 视图区
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.multipleTouchEnabled = YES;
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _overlayView.alpha = .5f;
        _overlayView.userInteractionEnabled = NO;
        _overlayView.backgroundColor = [UIColor blackColor];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    }
    return _overlayView;
}

#pragma mark - 裁剪区
- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    //图片高度与截取框高度保持一致
    if(_oldFrame.size.height >=  _cropFrame.size.height) {
        CGPathAddRect(path, nil, CGRectMake(0, 0, _cropFrame.origin.x, self.overlayView.height));
        CGPathAddRect(path, nil, CGRectMake(_cropFrame.origin.x + _cropFrame.size.width, 0, self.overlayView.width - _cropFrame.origin.x - _cropFrame.size.width, self.overlayView.height));
        CGPathAddRect(path, nil, CGRectMake(0, 0, self.overlayView.width, _cropFrame.origin.y));
        CGPathAddRect(path, nil, CGRectMake(0, _cropFrame.origin.y + _cropFrame.size.height, self.overlayView.width, self.overlayView.height - _cropFrame.origin.y + _cropFrame.size.height));
    } else { //重新赋值
        _cropFrame = _oldFrame;
        CGPathAddRect(path, nil, CGRectMake(0, 0, _oldFrame.origin.x, self.overlayView.height));
        CGPathAddRect(path, nil, CGRectMake(_oldFrame.origin.x + _oldFrame.size.width, 0, self.overlayView.width - _oldFrame.origin.x - _oldFrame.size.width, self.overlayView.height));
        CGPathAddRect(path, nil, CGRectMake(0, 0, self.overlayView.width, _oldFrame.origin.y));
        CGPathAddRect(path, nil, CGRectMake(0, _oldFrame.origin.y + _oldFrame.size.height, self.overlayView.width, self.overlayView.height - _oldFrame.origin.y + _oldFrame.size.height));
    }
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

#pragma mark - 手势处理
- (void)pinchGestureAction:(UIPinchGestureRecognizer *)pinch
{
    //缩放
    UIView *view = self.imageView;
    if (pinch.state == UIGestureRecognizerStateBegan || pinch.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(view.transform, pinch.scale, pinch.scale);
        pinch.scale = 1;
    }
    else if (pinch.state == UIGestureRecognizerStateEnded)
    {
        CGRect newFrame = self.imageView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f
                         animations:^{
                             weakSelf.latestFrame = newFrame;
                             weakSelf.imageView.frame = newFrame;
                         }];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    //拖动
    UIView *view = self.imageView;
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged)
    {
        CGFloat absCenterX = _cropFrame.origin.x + _cropFrame.size.width / 2;
        CGFloat absCenterY = _cropFrame.origin.y + _cropFrame.size.height / 2;
        CGFloat scaleRatio = self.imageView.width / _cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [pan translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [pan setTranslation:CGPointZero inView:view.superview];
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        CGRect newFrame = self.imageView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f
                         animations:^{
                             weakSelf.latestFrame = newFrame;
                             weakSelf.imageView.frame = newFrame;
                         }];
    }
}

#pragma mark - 重置frame
- (CGRect)handleScaleOverflow:(CGRect)newFrame
{
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < _oldFrame.size.width) {
        newFrame = _oldFrame;
    }
    if (newFrame.size.width > _largeFrame.size.width) {
        newFrame = _largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame
{
    if (newFrame.origin.x > _cropFrame.origin.x) newFrame.origin.x = _cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < _cropFrame.size.width) newFrame.origin.x = _cropFrame.size.width - newFrame.size.width;
    if (newFrame.origin.y > _cropFrame.origin.y) newFrame.origin.y = _cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < _cropFrame.origin.y + _cropFrame.size.height) {
        newFrame.origin.y = _cropFrame.origin.y + _cropFrame.size.height - newFrame.size.height;
    }
    if (self.imageView.width > self.imageView.height && newFrame.size.height <= _cropFrame.size.height) {
        newFrame.origin.y = _cropFrame.origin.y + (_cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

#pragma mark - 获取裁剪后的图片
- (UIImage *)getCropImage
{
    CGRect squareFrame = _cropFrame;
    CGFloat scaleRatio = _latestFrame.size.width / _originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - _latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - _latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = _originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}

#pragma mark - 内存
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
