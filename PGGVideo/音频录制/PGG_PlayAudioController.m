//
//  PGG_PlayAudioController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/28.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_PlayAudioController.h"
#import "PGG_AudioUtillty.h"
#import "Utility.h"
#import <UIView+Geometry.h>
#import "UIImage+Category.h"

@interface PGG_PlayAudioController ()
@property (nonatomic,strong) UIButton *localBtn;
@property (nonatomic,strong) UIButton *remoteBtn;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) UILabel *pathLabel;
@property (nonatomic,strong) PGG_AudioUtillty *audioUtil;
@property (nonatomic,copy) NSString *remoteMP3Path;
@property(nonatomic,strong)UIView * topView;
@property(nonatomic,strong)UIButton * backBtn;


@end

@implementation PGG_PlayAudioController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.localBtn];
    [self.view addSubview:self.remoteBtn];
    [self.view addSubview:self.pathLabel];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.backBtn];
        //播放
    _audioUtil = [PGG_AudioUtillty instance];
    _remoteMP3Path = @"http://39.108.135.80:8080/file/message/1234/voi/20170918114342.mp3";
    
}

#pragma mark - 音频播放相关
- (void)typeSelect:(UIButton *)btn
{
    if (btn.tag == 100) {
        self.localBtn.selected = YES;
        self.remoteBtn.selected = NO;
        self.pathLabel.text = [[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName];
    } else {
        self.localBtn.selected = NO;
        self.remoteBtn.selected = YES;
        self.pathLabel.text = _remoteMP3Path;
    }
}

- (void)playAudio
{
    self.playBtn.selected = !self.playBtn.selected;
        //播放
    if (self.playBtn.selected) {
        NSURL *mp3URL = nil;
        if (self.localBtn.selected) {
            mp3URL = [NSURL fileURLWithPath:[[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName]];
        } else {
            mp3URL = [NSURL URLWithString:_remoteMP3Path];
        }
        [_audioUtil playAudioByFileURL:mp3URL];
        
            //播放完成
        __weak typeof(self) weakSelf = self;
        [_audioUtil setAudioPlayFinish:^{
            weakSelf.playBtn.selected = NO;
        }];
    } else { //停止
        [_audioUtil pause];
    }
}
#pragma mark - 返回事件
- (void)backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 视图界面
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kTableView_Height)];
        _topView.backgroundColor = [UIColor darkGrayColor];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width-200)/2, 30, 200, 30)];
        title.text = @"音频播放";
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont systemFontOfSize:20];
        title.backgroundColor = [UIColor clearColor];
        [self.topView addSubview:title];
    }
    return _topView;
}
- (UIButton *)backBtn {//返回按钮
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 24, 40, 40)];
        [_backBtn setImage:[UIImage imageNamed:@"media_top_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIButton *)localBtn
{
    if (!_localBtn) {
        _localBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-220)/2, kTableView_Height+30, 100, 40)];
        _localBtn.tag = 100;
        _localBtn.selected = YES;
        _localBtn.layer.masksToBounds = YES;
        _localBtn.layer.cornerRadius = _localBtn.height/2;
        _localBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_localBtn setTitle:@"本地音频" forState:UIControlStateNormal];
        [_localBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_localBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_localBtn setBackgroundImage:[UIImage imageColor:RGBColor(235, 241, 245, 1.0)] forState:UIControlStateNormal];
        [_localBtn setBackgroundImage:[UIImage imageColor:[UIColor redColor]] forState:UIControlStateSelected];
        [_localBtn addTarget:self action:@selector(typeSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localBtn;
}

- (UIButton *)remoteBtn
{
    if (!_remoteBtn) {
        _remoteBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.localBtn.right+20, kTableView_Height+30, 100, 40)];
        _remoteBtn.tag = 200;
        _remoteBtn.selected = NO;
        _remoteBtn.layer.masksToBounds = YES;
        _remoteBtn.layer.cornerRadius = _remoteBtn.height/2;
        _remoteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_remoteBtn setTitle:@"在线音频" forState:UIControlStateNormal];
        [_remoteBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_remoteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_remoteBtn setBackgroundImage:[UIImage imageColor:RGBColor(235, 241, 245, 1.0)] forState:UIControlStateNormal];
        [_remoteBtn setBackgroundImage:[UIImage imageColor:[UIColor redColor]] forState:UIControlStateSelected];
        [_remoteBtn addTarget:self action:@selector(typeSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _remoteBtn;
}

- (UILabel *)pathLabel
{
    if (!_pathLabel) {
        _pathLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, kScreen_Width-20, 60)];
        _pathLabel.font = [UIFont systemFontOfSize:12.0];
        _pathLabel.textColor = [UIColor lightGrayColor];
        _pathLabel.numberOfLines = 0;
        _pathLabel.backgroundColor = [UIColor darkGrayColor];
        _pathLabel.text = [[Utility getAudioDir] stringByAppendingPathComponent:self.mp3FileName];
    }
    return _pathLabel;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-100)/2, 300, 100, 100)];
        _playBtn.selected = NO;
        [_playBtn setImage:[UIImage imageNamed:@"media_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"media_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
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
