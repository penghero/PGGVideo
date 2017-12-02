//
//  PGG_SelfieViewController.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

/**
 自定义相机 拍照 录像 
 */
@class GPUImageBeautifyFilter;
@protocol MediaCaptureManagerDelegate;
@interface PGG_SelfieViewController : UIViewController<AVCaptureFileOutputRecordingDelegate,UIAlertViewDelegate>
{
    dispatch_queue_t sessionQueue;                  //创建一个队列，防止阻塞主线程
    AVCaptureDevice *captureDevice;                 //采集设备
    AVCaptureSession *captureSession;               //采集
    AVCaptureVideoPreviewLayer *previewLayer;       //相机图层
    AVCaptureDeviceInput *inputDevice;              //输入
    CGFloat scaleNum;                               //伸缩系数
    NSTimer *recordTimer;                           //定时器
    int recordSeconds;                              //记录定时
}

@property (nonatomic, strong) CMMotionManager *motionManager;//获取重力
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;//视频输出
@property (nonatomic,strong) AVCaptureStillImageOutput *imageOutput;//图片输出
@property (nonatomic,strong) UIButton *backBtn; //返回
@property (nonatomic,strong) UIButton *previewBtn; //预览图片
@property (nonatomic,strong) UIButton *photoBtn;//照片按钮
@property(nonatomic,strong)UIButton * videoBtn;//视频录制按钮

@property (nonatomic,strong) UIButton *frontBtn;//摄像头切换
@property(nonatomic,strong)UIButton  * mapBtn;//贴图
@property(nonatomic,strong)UIButton * filterBtn;//滤镜
@property(nonatomic,strong)UIButton * proportionBtn;//比例
@property(nonatomic,strong)UIButton  * switchBtn;//拍照和视频切换按钮
@property(nonatomic,strong)UIButton * beautyBtn;//美颜按钮

@property(nonatomic,strong)UIView * mapView;//贴图试图
@property(nonatomic,strong)UIView * filterView;//滤镜试图
@property(nonatomic,strong)UIView * toolView;//底部试图
@property(nonatomic,strong)UIView * topView;//顶部视图
@property(nonatomic,strong)UICollectionView * filterCollectionView;//显示滤镜的视图
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;//GPU


@property(nonatomic,strong)UISlider * silder;//缩放 放大的滑杆 （捏合手势触发）

//闪关灯控制
@property (nonatomic,strong) UIView *flashView;
@property (nonatomic,strong) UIButton *flashBtn;
@property (nonatomic,strong) UIImageView *dotImageView; //视频录制时闪烁的绿点
@property (nonatomic,strong) UILabel *timeLabel; //视频时长
@property (nonatomic,strong) UIImage *previewImage;//预览图片
@property (nonatomic,strong) NSString *previewFileName;//预览文件名称
@property (nonatomic,strong) UIImageView *focusImageView;//定焦视图
@property (nonatomic,strong) UIView *bgView;//定焦视图
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;//屏幕方向
@property (nonatomic, assign) id<MediaCaptureManagerDelegate > delegate; //代理

@end

@protocol MediaCaptureManagerDelegate <NSObject>
@optional
- (void)mediaCaptureController:(UIViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
@end
