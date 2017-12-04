# PGGVideo
视频播放 音频录制 可本地可远程  高度自定义相机 自拍录像 AR功能体验 3DTouch 首次进入引导页 等等功能。
代码地址 https://github.com/penghero/PGGVideo.git
# 项目部分功能展示
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG9.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG8.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG7.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG6%201.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG5.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG13.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG12.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG11.jpeg)
![image](https://github.com/penghero/PGGVideo/blob/master/Image/WechatIMG10.jpeg)
# 视频播放
采用了WMP的播放器，对其进行了部分修改，在代码中有详细的使用说明。
附上WMPlayer的作者连接 https://github.com/zhengwenming
感谢大神的优秀代码。
主要代码:
#pragma mark 开始播放方法
- (void) startPlayVideo:(UIButton *)sender {
    PGGLog(@"开始播放视频%ld",(long)sender.tag);
    currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    UIView *cellView = [sender superview];
    while (![cellView isKindOfClass:[UITableViewCell class]])
        {
        cellView =  [cellView superview];
        }
    self.currentCell = (PGGVideoViewCell *)cellView;
    PGGVideoModel *model = [self.dataSourceArray objectAtIndex:sender.tag];
    if (isSmallScreen) {
        [self releaseWMPlayer];
        isSmallScreen = NO;
    }
    if (wmPlayer) {
        [self releaseWMPlayer];
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.videoImageView.bounds];
        wmPlayer.delegate = self;
            //关闭音量调节的手势
            //        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.closeBtnStyle = CloseBtnStyleClose;
        wmPlayer.URLString = model.mp4_url;
        wmPlayer.titleLabel.text = model.title;
    }else{
        wmPlayer = [[WMPlayer alloc]initWithFrame:self.currentCell.videoImageView.bounds];
        wmPlayer.delegate = self;
        wmPlayer.closeBtnStyle = CloseBtnStyleClose;
            //关闭音量调节的手势
            //        wmPlayer.enableVolumeGesture = NO;
        wmPlayer.titleLabel.text = model.title;
        wmPlayer.URLString = model.mp4_url;
    }
    
    [self.currentCell.videoImageView addSubview:wmPlayer];
    [self.currentCell.videoImageView bringSubviewToFront:wmPlayer];
    [self.currentCell.openVideo.superview sendSubviewToBack:self.currentCell.openVideo];
    [self.tableView reloadData];
}
#pragma mark scrollView delegate 滑动超出屏幕 关闭播放器 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.tableView){
        if (wmPlayer==nil) {
            return;
        }
        if (wmPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:currentIndexPath];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            PGGLog(@"rectInSuperview = %@",NSStringFromCGRect(rectInSuperview));
            
            if (rectInSuperview.origin.y<-self.currentCell.videoImageView.frame.size.height||rectInSuperview.origin.y>[UIScreen mainScreen].bounds.size.height-64-49) {//往上拖动
                [self releaseWMPlayer];
                [self.currentCell.openVideo.superview bringSubviewToFront:self.currentCell.openVideo];
            }
        }
    }
}
# 音频录制
使用AVFoundation框架下的AVAudioRecorder进行录制的，值得一提的是 使用了lame进行音频转码 因为手机录制好的音频格式是aac，caf的格式，这些格式并不能进行播放，需要转成mp3格式 对其进行余下操作。
主要代码为：
    //音频转码caf转map3
- (NSString *)audioToMP3:(NSString *)cafPath
{
        //MP3路径
    NSString *mp3Path = [cafPath stringByReplacingOccurrencesOfString:@".caf" withString:@".mp3"];
    @try {
        int read, write;
        FILE *pcm = fopen([cafPath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                               //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:1], "wb+");  //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0){
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            }
                //转换完的音频写入到指定路径下
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        PGGLog(@"音频转码异常：%@",[exception description]);
    }
    @finally {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:cafPath error:nil];
        return mp3Path;
    }
    return nil;
}
# 自拍
在AVFoundation框架下进行相机的高度自定义，包括，自定义相册采用的是HXAlbumListViewController，聚焦，缩放，镜头翻转（带翻转动画），全屏小屏互换，闪光灯设置，录像等等。感谢《微博照片选择》的优秀代码。
主要方法：
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
#pragma mark - 预览方法
- (void)previewAction {
    HXAlbumListViewController *vc = [[HXAlbumListViewController alloc] init];
    vc.delegate = self;
    vc.manager = self.manager;
    HXCustomNavigationController *nav = [[HXCustomNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
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
        self.switchBtn.userInteractionEnabled = NO;
        self.previewBtn.userInteractionEnabled = NO;
        [self.previewBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
}
美颜，贴图，滤镜方法后续添加。
# AR
在ARKit和SceneKit框架下实现的AR简单体验功能。
主要的使用的类
/*AR视图：展示3D界面*/
@property (nonatomic, strong)ARSCNView *arSCNView;
/*AR会话，负责管理相机追踪配置及3D相机坐标*/
@property(nonatomic,strong)ARSession *arSession;
 /*会话追踪配置*/
@property(nonatomic,strong)ARWorldTrackingConfiguration *arSessionConfiguration;
#pragma mark - 初始化ARSCNView 用来加载AR的3D场景视图
- (ARSCNView *)arSCNView {
    if (!_arSCNView ) {
        _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
//绑定session
        _arSCNView.session = self.arSession;
//自适应环境光照度，过渡更平滑
        _arSCNView.automaticallyUpdatesLighting = YES;
        _arSCNView.delegate = self;
//初始化节点
        [self initNodeWithRootView:_arSCNView];
    }
    return _arSCNView;
}
#pragma mark - ARSessionConfiguration(会话追踪配置)主要目的就是负责追踪相机在3D世界中的位置以及一些特征场景的捕捉，需要配置一些参数
- (ARWorldTrackingConfiguration *)arSessionConfiguration {
    if (!_arSessionConfiguration) {
        //1.创建世界追踪会话配置（使用ARWorldTrackingSessionConfiguration效果更加好），需要A9芯片支持
        ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
        //2.设置追踪方向（追踪平面，后面会用到）
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        _arSessionConfiguration = configuration;
        //3.自适应灯光（相机从暗到强光快速过渡效果会平缓一些）
        _arSessionConfiguration.lightEstimationEnabled = YES;
    }
    return _arSessionConfiguration;
}
#pragma mark - ARSession通过管理ARSessionConfiguration实现场景的追踪并且返回一个ARFrame
- (ARSession *)arSession {
    if(!_arSession){
        _arSession = [[ARSession alloc] init];
        _arSession.delegate = self;
    }
    return _arSession;
}
对节点的一些普及知识：
/*
 * SceneNode
 SceneNode提供几种几何模型，例如六面体(SCNBox)、平面(SCNPlane，只有一面)、无限平面(SCNFloor，沿着x-z平面无限延伸)、球体(SCNSphere)
 
 * SCNMaterial
 SceneNode提供8种属性用来设置模型材质
 Diffuse 漫发射属性表示光和颜色在各个方向上的反射量
 Ambient 环境光以固定的强度和固定的颜色从表面上的所有点反射出来。如果场景中没有环境光对象，这个属性对节点没有影响
 Specular 镜面反射是直接反射到使用者身上的光线，类似于镜子反射光线的方式。此属性默认为黑色，这将导致材料显得呆滞
 Normal 正常照明是一种用于制造材料表面光反射的技术，基本上，它试图找出材料的颠簸和凹痕，以提供更现实发光效果
 Reflective 反射光属性是一个镜像表面反射环境。表面不会真实地反映场景中的其他物体
 Emission 该属性是由模型表面发出的颜色。默认情况下，此属性设置为黑色。如果你提供了一个颜色，这个颜色就会体现出来，你可以提供一个图像。SceneKit将使用此图像提供“基于材料的发光效应”。
 Transparent 用来设置材质的透明度
 Multiply 通过计算其他所有属性的因素生成最终的合成的颜色
 
 *3. SCNLight
 SceneNode中完全都是动态光照，提供四种类型的光照
 SCNLightTypeAmbient 环境光
 SCNLightTypeOmni 聚光灯
 SCNLightTypeDirectional 定向光源
 SCNLightTypeSpot 点光源
 
 */
# END
欢迎喜欢开发的朋友一起研究探讨问题，可以通过邮件形式发给我，896733185@qq.com ！
# 更新
后续会将视频下载还有视频剪辑，对录像进行添加贴图，滤镜等功能。同时，有这方面经验的朋友欢迎与我联系。
