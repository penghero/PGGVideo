//
//  PGG_SelfieViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_SelfieViewController.h"
#import "Utility.h"
#import <AVFoundation/AVFoundation.h>
#import "GPUImageBeautifyFilter.h"
#import <GPUImage/GPUImage.h>
#import "HXCustomNavigationController.h"
#import "HXAlbumListViewController.h"
#import "HXPhotoTools.h"

@interface PGG_SelfieViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CAAnimationDelegate,HXAlbumListViewControllerDelegate>

@property(nonatomic,strong)HXPhotoManager * manager;

@end

@implementation PGG_SelfieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
        //音频权限
    if (![Utility isAudioRecordPermit]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设置>隐私>麦克风中开启权限"
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        alert.tag = Tag_PERMIT;
        [alert show];
        return;
    }
        //相机权限
    if (![Utility isCameraPermit]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请在设置>隐私>相机中开启权限"
                                                       delegate:self
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        alert.tag = Tag_PERMIT;
        [alert show];
        return;
    }
//    检测屏幕方向
    self.orientation = AVCaptureVideoOrientationPortrait;
    [self startMotionManager];
    scaleNum = 1.f;
        //队列
    sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
        //采集
    captureSession = [[AVCaptureSession alloc] init];
    if ([captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    NSError *error = nil;
        //获得输入设备
    captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        return;
    }
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [captureDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [captureDevice unlockForConfiguration];
    }
    AVCaptureDeviceInput *captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&error];
    if (error) {
        return;
    }
        //添加一个音频输入设备
    AVCaptureDevice *audioCaptureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        return;
    }
        //将设备输入添加到会话中
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
        [captureSession addInput:audioCaptureDeviceInput];
        inputDevice = captureDeviceInput;
    }
        //相机的实时预览页面
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
    [previewLayer setAffineTransform:CGAffineTransformMakeScale(1.f, 1.f)];
    [self.bgView.layer addSublayer:previewLayer];
        //照片输出
    if ([captureSession canAddOutput:self.imageOutput]) {
        [captureSession addOutput:self.imageOutput];
    }
        //对焦
    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    [focusTap setNumberOfTapsRequired:1];
    [self.bgView addGestureRecognizer:focusTap];
        //伸缩
    UITapGestureRecognizer *zoomTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomGesture:)];
    [zoomTap setNumberOfTapsRequired:2];
    [self.bgView addGestureRecognizer:zoomTap];
    [focusTap requireGestureRecognizerToFail:zoomTap];
    [self initWithUI];
    [captureSession startRunning];

}

#pragma mark - 对焦方法
- (void)focusGesture:(UITapGestureRecognizer *)focusTap
{
    CGPoint currTouchPoint = [focusTap locationInView:self.bgView];
        //对焦
    [self focusInPoint:currTouchPoint];
}

- (void)focusInPoint:(CGPoint)devicePoint
{
    [self focusWithDevicePoint:[self convertPoint:devicePoint]];
    [self.focusImageView setCenter:devicePoint];
    self.focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    [UIView animateWithDuration:0.3f
                          delay:0.f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.focusImageView.alpha = 1.f;
                         self.focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5f
                                               delay:0.5f
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              self.focusImageView.alpha = 0.f;
                                          } completion:nil];
                     }];
}

- (void)focusWithDevicePoint:(CGPoint)point
{
    dispatch_async(sessionQueue, ^{
        AVCaptureDevice *device = [inputDevice device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
            {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
                {
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                [device setFocusPointOfInterest:point];
                }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                {
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                [device setExposurePointOfInterest:point];
                }
            [device setSubjectAreaChangeMonitoringEnabled:YES];
            [device unlockForConfiguration];
            }
    });
}

- (CGPoint)convertPoint:(CGPoint)devicePoint
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewLayer.bounds.size;
    AVCaptureVideoPreviewLayer *videoPreviewLayer = previewLayer;
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(devicePoint.y / frameSize.height, 1.f - (devicePoint.x / frameSize.width));
    }
    else
        {
        CGRect cleanAperture;
        for(AVCaptureInputPort *port in [[captureSession.inputs lastObject]ports])
            {
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = devicePoint;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                }
                else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill])
                    {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    }
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
            }
        }
    return pointOfInterest;
}
#pragma mark - 缩放方法
- (void)zoomGesture:(UITapGestureRecognizer *)zoomTap
{
    if (scaleNum == 1.f) {
        scaleNum = 2.f;
    } else {
        scaleNum = 1.f;
    }
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3];
    [previewLayer setAffineTransform:CGAffineTransformMakeScale(scaleNum, scaleNum)];
    [CATransaction commit];
}

#pragma mark - 获取Device || 屏幕方向
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}
- (void)startMotionManager
{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1.0;
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
                //            AVCaptureSession(捕捉会话管理)：它从物理设备得到数据流（比如摄像头和麦克风），输出到一个或多个目的地，它可以通过会话预设值(session preset)，来控制捕捉数据的格式和质量
                //            http://www.jianshu.com/p/8c7ca1dd7f02
                //            所有对 capture session 的调用都是阻塞的，因此建议将它们分配到后台串行队列中
            [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    } else {
        [self setMotionManager:nil];
    }
}
- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion
{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0){
            self.orientation  = AVCaptureVideoOrientationPortraitUpsideDown;
        } else {
            self.orientation  = AVCaptureVideoOrientationPortrait;
        }
    } else {
        if (x >= 0){
            self.orientation  = AVCaptureVideoOrientationLandscapeLeft;
        } else {
            self.orientation  = AVCaptureVideoOrientationLandscapeRight;
        }
    }
}
#pragma mark - 返回事件
- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 镜头转换事件
- (void)frontAction {
    NSArray *inputs = captureSession.inputs;
    for (AVCaptureDeviceInput *input in inputs )
        {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] )
            {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDeviceInput *newInput = nil;
            if (position == AVCaptureDevicePositionFront) {
                [self changeCameraAnimation];
                captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
            } else {
                [self changeCameraAnimation];
                captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
            }
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
            [captureSession beginConfiguration];
            [captureSession removeInput:input];
            [captureSession addInput:newInput];
            [captureSession commitConfiguration];
            break;
            }
        }
}
#pragma mark - 切换动画
- (void)changeCameraAnimation {
    CATransition *changeAnimation = [CATransition animation];
    changeAnimation.delegate = self;
    changeAnimation.duration = 0.45;
    changeAnimation.type = @"oglFlip";
    changeAnimation.subtype = kCATransitionFromRight;
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
}

#pragma mark - 闪光灯事件
- (void)flashAction {
    self.flashBtn.selected = !self.flashBtn.selected;
    [UIView animateWithDuration:0.2 animations:^{
        self.flashView.hidden = !self.flashBtn.selected;
    }];
}
    //闪光灯切换
- (void)flashSwitch:(UIButton *)btn
{
    NSInteger flashMode = btn.tag-100;
        //更新UI
    UIButton *preBtn = [self.flashView viewWithTag:100+captureDevice.flashMode];
    [preBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:RGBColor(255.0, 197.0, 2, 1.0) forState:UIControlStateNormal];
    
        //设置
    NSError *error = nil;
    if ([captureDevice lockForConfiguration:&error]) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
        [captureDevice unlockForConfiguration];
    }
        //更新UI
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"media_flash_%ld",(long)flashMode]];
    [self.flashBtn setImage:image forState:UIControlStateNormal];
    self.flashBtn.selected = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.flashView.hidden = YES;
    }];
}
#pragma mark - 转换拍照录像按钮
- (void)switchAction:(UIButton *)btn
{
    if (self.switchBtn.selected) {
        self.switchBtn.selected = NO;
            //切换至拍照
        self.videoBtn.hidden = YES;
        self.photoBtn.hidden = NO;
        self.flashBtn.hidden = NO;
            //照片输出
        if ([captureSession canAddOutput:self.imageOutput]) {
            [captureSession addOutput:self.imageOutput];
        }
            //重置
        self.timeLabel.text = nil;
        self.dotImageView.hidden = YES;
        self.timeLabel.hidden = YES;
    } else {
        self.dotImageView.hidden = NO;
        self.timeLabel.hidden = NO;
        self.switchBtn.selected = YES;
            //切换至录制
        self.videoBtn.hidden = NO;
        self.photoBtn.hidden = YES;
        self.flashBtn.hidden = YES;
        self.flashView.hidden = YES;
            //视频输出
        if ([captureSession canAddOutput:self.movieFileOutput]) {
            [captureSession addOutput:self.movieFileOutput];
        }
        self.timeLabel.text = @"00:00:00";
    }
}
#pragma mark - 拍照事件
- (void)photoAction{
        //开始拍照
    AVCaptureConnection *videoConnection = nil;
    for ( AVCaptureConnection *connection in [self.imageOutput connections] ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] )  {
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
            }
        }
    }
    if([videoConnection isVideoOrientationSupported])  {
        [videoConnection setVideoOrientation:self.orientation];
    }
    AVCaptureConnection *captureConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    [captureConnection setVideoScaleAndCropFactor:scaleNum];
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:captureConnection
                                                  completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
     UIImage *image = [[UIImage alloc] initWithData:imageData];
         //存入相册
     [Utility writeImageToMUKAssetsGroup:image completion:nil];
         //预览显示
     _previewImage = image;
     self.previewBtn.userInteractionEnabled = YES;
     [self.previewBtn setImage:nil forState:UIControlStateNormal];
     [self.previewBtn setBackgroundImage:_previewImage forState:UIControlStateNormal];
         //代理回传
     NSDictionary *dic = @{UIImagePickerControllerOriginalImage:image};
     if ([self.delegate respondsToSelector:@selector(mediaCaptureController:didFinishPickingMediaWithInfo:)]) {
         [self.delegate mediaCaptureController:self didFinishPickingMediaWithInfo:dic];
     }
     }];
}
#pragma mark - 视频录制事件
- (void)videoAction {
    if (self.videoBtn.selected) {
        self.videoBtn.selected = NO;
            //录制完成
        [self.movieFileOutput stopRecording];
            //播放结束提示音
        AudioServicesPlaySystemSound(1118);
            //取消定时器
        if (recordTimer != nil) {
            [recordTimer invalidate];
            recordTimer = nil;
        }
            //重置
        self.timeLabel.text = @"00:00:00";
        self.dotImageView.hidden = YES;
        self.switchBtn.userInteractionEnabled = YES;
    } else {
        self.videoBtn.selected = YES;
            //开始录制
        AVCaptureConnection *videoConnection = nil;
        for ( AVCaptureConnection *connection in [self.movieFileOutput connections] ) {
            for ( AVCaptureInputPort *port in [connection inputPorts] )  {
                if ( [[port mediaType] isEqual:AVMediaTypeVideo] ) {
                    videoConnection = connection;
                }
            }
        }
        if([videoConnection isVideoOrientationSupported])  {
            [videoConnection setVideoOrientation:self.orientation];
        }
            //创建视频文件路径
        NSString *prefix = [Utility getNowTimestampString];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp4",prefix];
        NSString *filePath = [[Utility getVideoDir] stringByAppendingPathComponent:fileName];
        [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
            //播放开始提示音
        AudioServicesPlaySystemSound(1117);
            //计时开始
        self.dotImageView.hidden = NO;
        [self.dotImageView startAnimating];
        recordSeconds = 0;
        self.timeLabel.text = @"00:00:00";
        if (recordTimer != nil) {
            [recordTimer invalidate];
            recordTimer = nil;
        }
        recordTimer =  [NSTimer timerWithTimeInterval:1.00f target:self selector:@selector(recordVideoTime:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:recordTimer forMode: NSRunLoopCommonModes];
            //修改左边预览
        self.switchBtn.userInteractionEnabled = NO;
        self.previewBtn.userInteractionEnabled = NO;
        [self.previewBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
}
#pragma mark - 录像计时操作
- (void)recordVideoTime:(NSTimer *)timer {
    recordSeconds ++;
    self.timeLabel.text = [Utility getHMSFormatBySeconds:recordSeconds];
}
#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"视频录制完成");
        //1、保存图库
    [Utility writeVideoToMUKAssetsGroup:outputFileURL completion:nil];
        //2.预览显示
    _previewImage = [Utility getVideoImage:outputFileURL];
    self.previewBtn.userInteractionEnabled = YES;
    [self.previewBtn setImage:[UIImage imageNamed:@"media_video_small"] forState:UIControlStateNormal];
    [self.previewBtn setBackgroundImage:_previewImage forState:UIControlStateNormal];
        //3.代理回传
    NSDictionary *dic = @{UIImagePickerControllerMediaURL:outputFileURL};
    if ([self.delegate respondsToSelector:@selector(mediaCaptureController:didFinishPickingMediaWithInfo:)]) {
        [self.delegate mediaCaptureController:self didFinishPickingMediaWithInfo:dic];
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"视频开始录制");
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == Tag_PERMIT) {
        [self backAction];
    }
}
#pragma mark - 预览方法
- (void)previewAction {
    HXAlbumListViewController *vc = [[HXAlbumListViewController alloc] init];
    vc.delegate = self;
    vc.manager = self.manager;
    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    /*
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
     */
}
#pragma mark - HXAlbumListViewControllerDelegate
- (void)albumListViewController:(HXAlbumListViewController *)albumListViewController didDoneAllList:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photoList videos:(NSArray<HXPhotoModel *> *)videoList original:(BOOL)original {
        //    self.total.text = [NSString stringWithFormat:@"总数量：%ld   ( 照片：%ld   视频：%ld )",allList.count, photoList.count, videoList.count];
        //    [NSString stringWithFormat:@"%ld个",allList.count];
        //    self.photo.text = [NSString stringWithFormat:@"%ld张",photos.count];
        //    self.video.text = [NSString stringWithFormat:@"%ld个",videos.count];
}
- (void)albumListViewControllerDidCancel:(HXAlbumListViewController *)albumListViewController {
    
}

#pragma mark - 美颜方法
- (void)beautyAction {
    /*
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreen_Width, kScreen_Height)];
    self.beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [videoCamera addTarget:self.beautifyFilter];
    [self.beautifyFilter addTarget:filterView];
    [videoCamera startCameraCapture];
     */
}
#pragma mark - 滤镜方法
- (void)filterAction {
    
}
#pragma mark - 比例方法
- (void)proportionAction:(UIButton *)sender {
    self.proportionBtn.selected = !sender.selected;
    if (sender.selected) {
        [previewLayer setFrame:CGRectMake(0, 0,kScreen_Width,kScreen_Height)];
        [self.proportionBtn setTitle:@"小屏" forState:UIControlStateNormal];
    }else{
        [previewLayer setFrame:CGRectMake(0, kTableView_Height,kScreen_Width, kScreen_Width)];
        [self.proportionBtn setTitle:@"全屏" forState:UIControlStateNormal];
    }
}
#pragma mark - 贴图方法
- (void)mapAction {
    
}
#pragma mark - 懒加载页面布局
- (UIView *)bgView {//背景视图
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        _bgView.backgroundColor = [UIColor clearColor];
    }
    return _bgView;
}

- (UIView *)topView {// 顶部视图
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 64)];
        _topView.backgroundColor = RGBColor(87.0, 87.0, 87.0, 0.33);
    }
    return _topView;
}
- (UIButton *) backBtn {//返回按钮
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 40, 40)];
        [_backBtn setBackgroundImage:[UIImage imageNamed:@"media_top_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)frontBtn { //转换镜头按钮
    if (!_frontBtn) {
        _frontBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 50, 20, 40, 40)];
        [_frontBtn setBackgroundImage:[UIImage imageNamed:@"media_top_switch"] forState:UIControlStateNormal];
        [_frontBtn addTarget:self action:@selector(frontAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _frontBtn;
}

- (UIButton *)flashBtn {//闪光灯
    if (!_flashBtn) {
        _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-200)/2, 20, 40, 40)];
        [_flashBtn setImage:[UIImage imageNamed:@"media_flash_2"] forState:UIControlStateNormal];
        [_flashBtn addTarget:self action:@selector(flashAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashBtn;
}

- (UIView *)flashView {//选择是否开启闪光灯
    if (!_flashView) {
        _flashView = [[UIView alloc] initWithFrame:CGRectMake((kScreen_Width-160)/2, 30, 150, 30)];
        _flashView.backgroundColor = [UIColor clearColor];
        
        for (NSInteger i = 0; i < 3; i ++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(50*i, 0, 50, 30)];
            btn.tag = 100+(2-i);
            btn.backgroundColor = [UIColor clearColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(flashSwitch:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                [btn setTitle:@"自动" forState:UIControlStateNormal];
                [btn setTitleColor:RGBColor(255.0, 197.0, 2, 1.0) forState:UIControlStateNormal];
            } else if (i == 1) {
                [btn setTitle:@"打开" forState:UIControlStateNormal];
            } else {
                [btn setTitle:@"关闭" forState:UIControlStateNormal];
            }
            [_flashView addSubview:btn];
        }
    }
    return _flashView;
}

- (UIView *)toolView {//底部视图
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame: CGRectMake(0, kScreen_Height - 120, kScreen_Width, 120)];
        _toolView.backgroundColor = RGBColor(87.0, 87.0, 87.0, 0.33);
    }
    return _toolView;
}

- (UIButton *)photoBtn {//拍照开始按钮
    if (!_photoBtn) {
        _photoBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-80)/2,10, 80, 80)];
        [_photoBtn setBackgroundImage:[UIImage imageNamed:@"media_camera"] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"media_camera_down"] forState:UIControlStateHighlighted];
        [_photoBtn addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}
- (UIButton *)videoBtn {//录像开始按钮
    if (!_videoBtn) {
        _videoBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-80)/2,10, 80, 80)];
        [_videoBtn setImage:[UIImage imageNamed:@"media_video"] forState:UIControlStateNormal];
        [_videoBtn setImage:[UIImage imageNamed:@"media_video_down"] forState:UIControlStateSelected];
        [_videoBtn addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoBtn;
}

- (UIButton *)switchBtn
{
    if (!_switchBtn) {
        _switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-100, 10, 50, 50)];
        _switchBtn.selected = NO;
        [_switchBtn setImage:[UIImage imageNamed:@"media_note_video"] forState:UIControlStateNormal];
        [_switchBtn setImage:[UIImage imageNamed:@"media_note_camera"] forState:UIControlStateSelected];
        [_switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (UIButton *)previewBtn {//预览视图
    if (!_previewBtn) {
        _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 50 ,50)];
        [_previewBtn addTarget:self action:@selector(previewAction) forControlEvents:UIControlEventTouchUpInside];
        _previewBtn.layer.cornerRadius = 5;
        _previewBtn.clipsToBounds = YES;
    }
    return _previewBtn;
}

- (UIButton *)beautyBtn {//添加美颜按钮
    if (!_beautyBtn) {
        _beautyBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 60, 50, 50)];
        [_beautyBtn setTitle:@"美颜" forState:UIControlStateNormal];
        [_beautyBtn setBackgroundColor:[UIColor clearColor]];
        [_beautyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_beautyBtn addTarget:self action:@selector(beautyAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyBtn;
}


- (UIButton *)filterBtn {//添加滤镜按钮
    if (!_filterBtn) {
        _filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 60, 50, 50)];
        [_filterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
        [_filterBtn setBackgroundColor:[UIColor clearColor]];
        [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_filterBtn addTarget:self action:@selector(filterAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _filterBtn;
}

- (UIButton *) proportionBtn {//比例按钮
    if (!_proportionBtn) {
        _proportionBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-60, 60, 50, 50)];
        [_proportionBtn setTitle:@"小屏" forState:UIControlStateNormal];
        [_proportionBtn setBackgroundColor:[UIColor clearColor]];
        [_proportionBtn addTarget:self action:@selector(proportionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _proportionBtn;
}
- (UIButton *)mapBtn {//添加贴纸按钮
    if (!_mapBtn ){
        _mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-150, 60, 50, 50)];
        [_mapBtn setTitle:@"贴纸" forState:UIControlStateNormal];
        [_mapBtn setBackgroundColor:[UIColor clearColor]];
        [_mapBtn addTarget:self action:@selector(mapAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mapBtn;
}

- (UIView *)mapView {//贴图视图
    if (!_mapView) {
        _mapView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-120-150-1, kScreen_Width, 150)];
        _mapView.backgroundColor = RGBColor(87.0, 87.0, 87.0, 0.33);
    }
    return _mapView;
}

- (UIView *)filterView {//滤镜视图
    if (!_filterView) {
        _filterView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height-120-150-1, kScreen_Width, 150)];
        _filterView.backgroundColor = RGBColor(87.0, 87.0, 87.0, 0.33);
    }
    return _filterView;
}

- (UIImageView *)dotImageView { //录像开始后 时间点边上的闪烁点
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_dot"]];
        _dotImageView.center = self.timeLabel.center;
        _dotImageView.frame = CGRectMake((kScreen_Width-90)/2, 40, 5, 5);
        _dotImageView.animationImages = @[[UIImage imageNamed:@"media_dot"],[UIImage imageNamed:@"media_dot_clear"]];
        _dotImageView.animationDuration = 0.8;
    }
    return _dotImageView;
}

- (UILabel *)timeLabel {//录像时间
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width-80)/2, 20, 80, 40)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:18.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UIImageView *)focusImageView { //定焦视图
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_focus"]];
        _focusImageView.alpha = 0;
    }
    return _focusImageView;
}

- (AVCaptureMovieFileOutput *)movieFileOutput {//视频输出
    if (!_movieFileOutput) {
        _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    }
    return _movieFileOutput;
}

- (AVCaptureStillImageOutput *)imageOutput {//图片输出
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        _imageOutput.outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    }
    return _imageOutput;
}
- (HXPhotoManager *)manager{//自定义相册
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _manager.cacheAlbum = YES;
        _manager.style = HXPhotoAlbumStylesSystem;
        _manager.deleteTemporaryPhoto = NO;
        _manager.saveSystemAblum = YES;
        _manager.downloadICloudAsset = YES;
        _manager.cameraCellShowPreview = NO;
        _manager.openCamera = NO;
        _manager.showDateHeaderSection = YES;
        _manager.videoMaxNum = 9;
        _manager.photoMaxNum = 9;
    }
    return _manager;
}

#pragma mark - 加载视图控件
- (void) initWithUI {
    [self.view addSubview:self.bgView];
    
    [self.bgView addSubview:self.topView];
    [self.topView addSubview:self.flashView];
    [self.topView addSubview:self.backBtn];
    [self.topView addSubview:self.frontBtn];
    [self.topView addSubview:self.flashBtn];
    [self.topView addSubview:self.dotImageView];
    [self.topView addSubview:self.timeLabel];
    
    [self.bgView addSubview:self.toolView];
    [self.toolView addSubview:self.photoBtn];
    [self.toolView addSubview:self.videoBtn];
    [self.toolView addSubview:self.switchBtn];
    [self.toolView addSubview:self.previewBtn];
    [self.toolView addSubview:self.filterBtn];
    [self.toolView addSubview:self.proportionBtn];
    [self.toolView addSubview:self.mapBtn];
    [self.toolView addSubview:self.beautyBtn];
    
    [self.bgView addSubview:self.mapView];
    [self.bgView addSubview:self.filterView];
    [self.bgView addSubview:self.focusImageView];
    
    self.mapView.hidden = YES;
    self.filterView.hidden = YES;
    self.timeLabel.hidden = YES;
    self.dotImageView.hidden = YES;
    self.flashView.hidden = YES;
    self.videoBtn.hidden = YES;
    self.proportionBtn.selected = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
