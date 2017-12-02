//
//  PGG_BeautyViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_BeautyViewController.h"
#import "PGG_AudioUtillty.h"
#import "Utility.h"
#import "NSString+Category.h"
#import <UIView+Geometry.h>
#import "PGG_PlayAudioController.h"


@interface PGG_BeautyViewController ()
{
    int recordSeconds;      //记录定时
    NSTimer *recordTimer;   //定时器
}
    //顶部视图
@property (nonatomic,strong) UIView *topView;
    //返回
@property (nonatomic,strong) UIButton *backBtn;
    //录制时闪烁的绿点
@property (nonatomic,strong) UIImageView *dotImageView;
    //标识
@property (nonatomic,strong) UILabel *dotLabel;
    //时长
@property (nonatomic,strong) UILabel *timeLabel;
    //完成
@property (nonatomic,strong) UIButton *finishBtn;
    //录制/暂停
@property (nonatomic,strong) UIButton *pauseBtn;
    //取消
@property (nonatomic,strong) UIButton *cancelBtn;
    //中间的图片
@property (nonatomic,strong) UIImageView *midImageView;
    //录音
@property (nonatomic,strong) PGG_AudioUtillty *audioUtil;
@end

@implementation PGG_BeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor darkGrayColor];
    [self initSubview];
}
- (void)initSubview{
        //添加各个视图
    [self.view addSubview:self.topView];
    [self.view addSubview:self.midImageView];
    [self.view addSubview:self.finishBtn];
    [self.view addSubview:self.pauseBtn];
    [self.view addSubview:self.cancelBtn];
    [self.view addSubview:self.timeLabel];
    self.finishBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    _audioUtil = [PGG_AudioUtillty instance];
}

#pragma mark - 返回
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 录制相关

- (void)finishClicked {//完成录制
        //回传录音名称
    NSString *filePath = [_audioUtil finishRecord];
    NSString *mp3FileName = [filePath lastPathComponent];
    if (self.mp3FileNameBlock) {
        self.mp3FileNameBlock(mp3FileName);

    }
    PGG_PlayAudioController *play = [[PGG_PlayAudioController alloc] init];
    play.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:play animated:YES completion:nil];
//    [self backAction];
}

- (void)recordClicked {//录制
    self.pauseBtn.selected = !self.pauseBtn.selected;
    NSString *title = nil;
    if (self.pauseBtn.selected == YES) {
        self.finishBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        title = @"正在录音";
        [self.dotImageView startAnimating];
        if ([self.pauseBtn.titleLabel.text isEqualToString:@"开始"]) {
            recordSeconds = 0;
        }
        recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.00f target:self selector:@selector(recordTime:) userInfo:nil repeats:YES];
            //开始录音
        [_audioUtil beginRecord];
    } else {
        title = @"录音";
        self.finishBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
        [self.dotImageView stopAnimating];
        [self.pauseBtn setTitle:@"继续" forState:UIControlStateNormal];
            //取消定时器
        [recordTimer invalidate],recordTimer = nil;
        [_audioUtil pause];
    }
    
    self.dotLabel.text = title;
    self.dotLabel.frame = CGRectMake((kScreen_Width-100)/2, kStatusBar_Height, 100, 20);
    self.dotImageView.center = self.dotLabel.center;
    self.dotImageView.right = self.dotLabel.left-5;
}

- (void)cancelClicked {//取消
    self.pauseBtn.selected = NO;
    [self.pauseBtn setTitle:@"开始" forState:UIControlStateNormal];
    self.finishBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.timeLabel.text = @"00:00:00";
        //取消录音
    [_audioUtil cancelRecord];
}

#pragma mark - 计时操作
- (void)recordTime:(NSTimer *)timer
{
    recordSeconds ++;
    self.timeLabel.text = [Utility getHMSFormatBySeconds:recordSeconds];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //隐藏状态栏 增加美观
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}
#pragma mark - 懒加载布局
- (UIView *)topView { //导航视图
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kTableView_Height)];
        _topView.backgroundColor = [UIColor clearColor];
        [_topView addSubview:self.backBtn];
        [_topView addSubview:self.dotLabel];
        [_topView addSubview:self.dotImageView];
    }
    return _topView;
}

- (UIButton *)backBtn {//返回按钮
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
        [_backBtn setImage:[UIImage imageNamed:@"media_top_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)dotLabel {
    if (!_dotLabel) {
        NSString *title = @"录音";
        _dotLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width-60)/2, kStatusBar_Height, 60, 20)];
        _dotLabel.textAlignment = NSTextAlignmentCenter;
        _dotLabel.backgroundColor = [UIColor clearColor];
        _dotLabel.font = [UIFont systemFontOfSize:18.0];
        _dotLabel.textColor = [UIColor whiteColor];
        _dotLabel.text = title;
    }
    return _dotLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.topView.bottom, kScreen_Width, 44)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont fontWithName:@"Thonburi" size:30.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:00:00";
    }
    return _timeLabel;
}

- (UIImageView *)dotImageView {//闪点
    if (!_dotImageView) {
        _dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"media_dot_clear"]];
        _dotImageView.center = self.dotLabel.center;
        _dotImageView.right = self.dotLabel.left-5;
        _dotImageView.animationImages = @[[UIImage imageNamed:@"media_dot"],[UIImage imageNamed:@"media_dot_clear"]];
        _dotImageView.animationDuration = 0.8;
    }
    return _dotImageView;
}

- (UIImageView *)midImageView{//中心圈
    if (!_midImageView) {
        _midImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"audio_mid"]];
        _midImageView.size = CGSizeMake(self.view.width*2/3, self.view.width*2/3);
        _midImageView.center = self.view.center;
    }
    return _midImageView;
}

- (UIButton *)finishBtn { //完成录音
    if (!_finishBtn) {
        UIImage *image = [UIImage imageNamed:@"audio_finish"];
        NSString *title = @"完成";
        CGFloat titleW = [title sizeWithFont:[UIFont systemFontOfSize:16.0] maxSize:CGSizeMake(kScreen_Width, 40)].width;
        CGFloat btnH = (kScreen_Width-6*k_MARGIN)/3;
        CGFloat imgH = image.size.height;
        CGFloat top = (btnH-imgH-40)/2+5;
        CGFloat left = (btnH-imgH)/2;
        
        _finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(2*k_MARGIN, kScreen_Height-btnH-2*k_MARGIN, btnH, btnH)];
        _finishBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _finishBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_finishBtn setTitle:title forState:UIControlStateNormal];
        [_finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_finishBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_finishBtn setImage:[UIImage imageNamed:@"audio_finish"] forState:UIControlStateNormal];
        [_finishBtn setImage:[UIImage imageNamed:@"audio_finished"] forState:UIControlStateHighlighted];
        [_finishBtn setImageEdgeInsets:UIEdgeInsetsMake(top, left, btnH-imgH-top, left)];
        [_finishBtn setTitleEdgeInsets:UIEdgeInsetsMake(top+imgH, left-(imgH+titleW)/2, btnH-(top+imgH+40), 0)];
        [_finishBtn addTarget:self action:@selector(finishClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}

- (UIButton *)pauseBtn { //开始录音
    if (!_pauseBtn) {
        UIImage *image = [UIImage imageNamed:@"audio_record"];
        NSString *title = @"开始";
        CGFloat titleW = [title sizeWithFont:[UIFont systemFontOfSize:16.0] maxSize:CGSizeMake(kScreen_Width, 40)].width;
        CGFloat btnH = (kScreen_Width-6*k_MARGIN)/3;
        CGFloat imgH = image.size.height;
        CGFloat top = (btnH-imgH-40)/2+5;
        CGFloat left = (btnH-imgH)/2;
        
        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.finishBtn.right+k_MARGIN, kScreen_Height-btnH-2*k_MARGIN, btnH, btnH)];
        _pauseBtn.selected = NO;
        _pauseBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _pauseBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_pauseBtn setTitle:title forState:UIControlStateNormal];
        [_pauseBtn setTitle:@"暂停" forState:UIControlStateSelected];
        [_pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_pauseBtn setImage:[UIImage imageNamed:@"audio_record"] forState:UIControlStateNormal];
        [_pauseBtn setImage:[UIImage imageNamed:@"audio_pause"] forState:UIControlStateSelected];
        [_pauseBtn setImageEdgeInsets:UIEdgeInsetsMake(top, left, btnH-imgH-top, left)];
        [_pauseBtn setTitleEdgeInsets:UIEdgeInsetsMake(top+imgH, left-(imgH+titleW)/2, btnH-(top+imgH+40), 0)];
        [_pauseBtn addTarget:self action:@selector(recordClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}

- (UIButton *)cancelBtn {//取消
    if (!_cancelBtn) {
        UIImage *image = [UIImage imageNamed:@"audio_cancel"];
        NSString *title = @"取消";
        CGFloat titleW = [title sizeWithFont:[UIFont systemFontOfSize:16.0] maxSize:CGSizeMake(kScreen_Width, 40)].width;
        CGFloat btnH = (kScreen_Width-6*k_MARGIN)/3;
        CGFloat imgH = image.size.height;
        CGFloat top = (btnH-imgH-40)/2+5;
        CGFloat left = (btnH-imgH)/2;
        
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.pauseBtn.right+k_MARGIN, kScreen_Height-btnH-2*k_MARGIN, btnH, btnH)];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn setTitle:title forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_cancelBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_cancelBtn setImage:[UIImage imageNamed:@"audio_cancel"] forState:UIControlStateNormal];
        [_cancelBtn setImage:[UIImage imageNamed:@"audio_canceled"] forState:UIControlStateHighlighted];
        [_cancelBtn setImageEdgeInsets:UIEdgeInsetsMake(top, left, btnH-imgH-top, left)];
        [_cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(top+imgH, left-(imgH+titleW)/2, btnH-(top+imgH+40), 0)];
        [_cancelBtn addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
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
