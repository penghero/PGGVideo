//
//  ViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "ViewController.h"
#import "PGG_ARViewController.h"
#import "PGG_BeautyViewController.h"
#import "PGG_SelfieViewController.h"
#import "PGG_VideoPlayViewController.h"
#import "PGG_VideoEditingViewController.h"
#import "XCGuideMaskView.h"
#import "DHGuidePageHUD.h"

@interface ViewController ()<XCGuideMaskViewLayout,XCGuideMaskViewDataSource>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if ([ViewController isShow]) {
        [self setStaticGuidePage];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}
- (void)back {
    XCGuideMaskView *maskView = [[XCGuideMaskView alloc] initWithDatasource:self];
    maskView.layout = self;
    [maskView show];
}

#pragma mark - 设置APP静态图片引导页
- (void)setStaticGuidePage {
    NSArray *imageNameArray = @[@"Simulator1",@"Simulator2",@"Simulator3",@"Simulator4",@"Simulator5"];
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.view.frame imageNameArray:imageNameArray buttonIsHidden:NO];
    guidePage.slideInto = YES;
    [self.view addSubview:guidePage];
}

#pragma mark - 设置APP动态图片引导页
- (void)setDynamicGuidePage {
    NSArray *imageNameArray = @[@"guideImage6.gif",@"guideImage7.gif",@"guideImage8.gif"];
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.view.frame imageNameArray:imageNameArray buttonIsHidden:YES];
    guidePage.slideInto = YES;
    [self.view addSubview:guidePage];
}

#pragma mark - 设置APP视频引导页
- (void)setVideoGuidePage {
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"guideMovie" ofType:@"mov"]];
    DHGuidePageHUD *guidePage = [[DHGuidePageHUD alloc] dh_initWithFrame:self.view.frame videoURL:videoURL];
    [self.view addSubview:guidePage];
}
#pragma mark - 更新出现引导页或者第一次安装出现
+ (BOOL)isShow {
// 读取版本信息
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *localVersion = [user objectForKey:VERSION_INFO_CURRENT];
    NSString *currentVersion =[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    if (localVersion == nil || ![currentVersion isEqualToString:localVersion]) {
        [ViewController saveCurrentVersion];
        return YES;
    }else {
        return NO;
    }
}
#pragma mark - 保存版本信息
+ (void)saveCurrentVersion {
    NSString *version =[[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:version forKey:VERSION_INFO_CURRENT];
    [user synchronize];
}

//视频播放入口
- (IBAction)videoPlay:(id)sender {
    PGG_VideoPlayViewController *videoplay = [[PGG_VideoPlayViewController alloc] init];
    videoplay.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:videoplay animated:YES completion:nil];
}
//视频编辑入口
- (IBAction)videoEditing:(id)sender {
    PGG_VideoEditingViewController *videoediting = [[PGG_VideoEditingViewController alloc] init];
    videoediting.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:videoediting animated:YES completion:nil];
}
//自拍入口
- (IBAction)selfie:(id)sender {
    PGG_SelfieViewController *selfie = [[PGG_SelfieViewController alloc] init];
    selfie.modalTransitionStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:selfie animated:YES completion:nil];
}
//音频录制入口
- (IBAction)beauty:(id)sender {
    PGG_BeautyViewController *beauty = [[PGG_BeautyViewController alloc] init];
    beauty.modalTransitionStyle = UIModalPresentationPageSheet;
    [self presentViewController:beauty animated:YES completion:nil];
}
//AR入口
- (IBAction)AR:(id)sender {
    PGG_ARViewController *ar = [[PGG_ARViewController alloc] init];
    ar.modalTransitionStyle = UIModalPresentationPopover;
    [self presentViewController:ar animated:YES completion:nil];
}


#pragma mark - 📕 👀 XCGuideMaskViewDataSource 👀

- (NSInteger)numberOfItemsInGuideMaskView:(XCGuideMaskView *)guideMaskView
{
    return self.dataArray.count;
}

- (UIView *)guideMaskView:(XCGuideMaskView *)guideMaskView viewForItemAtIndex:(NSInteger)index
{
    return self.dataArray[index];
}

- (NSString *)guideMaskView:(XCGuideMaskView *)guideMaskView descriptionForItemAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"这是第 %zi 个视图的描述", index];
}

- (UIColor *)guideMaskView:(XCGuideMaskView *)guideMaskView colorForDescriptionAtIndex:(NSInteger)index
{
    return arc4random_uniform(2) ? [UIColor whiteColor] : [UIColor redColor];
}

- (UIFont *)guideMaskView:(XCGuideMaskView *)guideMaskView fontForDescriptionAtIndex:(NSInteger)index
{
    return arc4random_uniform(2) ? [UIFont systemFontOfSize:13] : [UIFont systemFontOfSize:15];
}

#pragma mark - 👀 XCGuideMaskViewLayout 👀 💤

- (CGFloat)guideMaskView:(XCGuideMaskView *)guideMaskView cornerRadiusForViewAtIndex:(NSInteger)index
{
    if (index == self.dataArray.count - 1)
        {
        return 25;
        }
    
    return 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
