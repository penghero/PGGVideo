//
//  PGG_VideoPlayViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_VideoPlayViewController.h"
#import "WMPlayer.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <YYModel.h>
#import <UIImageView+WebCache.h>
#import "PGGVideoModel.h"
#import "PGGVideoViewCell.h"
#import "PGG_DetailViewController.h"
#import <SVProgressHUD.h>
#import "PGG_DownLoadViewController.h"

static NSString *PGGVideoViewCell_ID = @"PGGVideoViewCell";

@interface PGG_VideoPlayViewController ()<UITableViewDelegate,UITableViewDataSource,WMPlayerDelegate,UIScrollViewDelegate,UIViewControllerPreviewingDelegate>{
    WMPlayer *wmPlayer;
    NSIndexPath *currentIndexPath;
    BOOL isSmallScreen;
    CGRect sourceRect;
}
@property(nonatomic,strong)NSMutableArray * cellHeightArray;//cell高度缓存
@property(strong,nonatomic) UIView *navView;
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic)NSMutableArray * dataSourceArray;//总数据
@property(nonatomic,retain)PGGVideoViewCell *currentCell;


@end

@implementation PGG_VideoPlayViewController
- (NSMutableArray *)cellHeightArray {
    if (!_cellHeightArray) {
        _cellHeightArray = [NSMutableArray array];
    }
    return _cellHeightArray;
}
- (NSMutableArray *)dataSourceArray {
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
    }
    return _dataSourceArray;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        isSmallScreen = NO;
    }
    return self;
}
#pragma mark - UIViewControllerPreviewingDelegate
//1.当进入Peek状态时,系统会回调如下方法
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
        // previewingContext.sourceView: 触发Peek & Pop操作的视图
        // previewingContext.sourceRect: 设置触发操作的视图的不被虚化的区域
    
    PGG_DetailViewController *detailVC = [[PGG_DetailViewController alloc] init];
        // 预览区域大小(可不设置)
//    detailVC.preferredContentSize = CGSizeMake(0, 300);
    if (![self getShouldShowRectAndIndexPathWithLocation:location])
        return nil;
    previewingContext.sourceRect = sourceRect;
    UIView *bgView =[[UIView alloc]initWithFrame:CGRectMake(0,0,kScreen_Width,kScreen_Height)];
    bgView.backgroundColor = [UIColor whiteColor];
    [detailVC.view addSubview:bgView];
    
        // 加个lable
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, kTableView_Height)];
    lable.textAlignment =NSTextAlignmentCenter;
    lable.backgroundColor = [UIColor darkGrayColor];
    lable.textColor = [UIColor whiteColor];
    lable.numberOfLines = 3;
    lable.text = @"标题";
    [bgView addSubview:lable];
    
    return detailVC;
}
#pragma mark  比较巧妙 准确的 获取高亮区域的方法
/** 获取用户手势点所在cell的下标。同时判断手势点是否超出tableView响应范围。*/
- (BOOL)getShouldShowRectAndIndexPathWithLocation:(CGPoint)location
{
        // 根据手指按压的区域，结合 tableView 的 Y 偏移量（上下）
    location.y = self.tableView.contentOffset.y+location.y;
        //定位到当前，按压的区域处于哪个 cell  获得 cell 的indexPath
    currentIndexPath = [self.tableView indexPathForRowAtPoint:location];
        // 根据cell 的indexPath 取出 cell
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:currentIndexPath];
        //    cell.backgroundColor = [UIColor redColor];
        // 根据 获得cell ，确定高亮的区域，记得 高亮区域是相对于屏幕  位置来算，记得减去 tableView 的 Y偏移量
    sourceRect = CGRectMake(cell.frame.origin.x, cell.frame.origin.y-self.tableView.contentOffset.y, cell.frame.size.width,cell.frame.size.height);
        // 如果row越界了，返回NO 不处理peek手势
    return (currentIndexPath.row >= self.dataSourceArray.count && currentIndexPath.row<0) ? NO : YES;
}

//当进入Pop状态时,系统会回调如下方法
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}


#pragma mark tableView
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTableView_Height, kScreen_Width, KTableView_H) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor lightTextColor];
        [_tableView registerNib:[UINib nibWithNibName:@"PGGVideoViewCell" bundle:nil]  forCellReuseIdentifier:PGGVideoViewCell_ID];
    }
    return _tableView;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PGGVideoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PGGVideoViewCell_ID forIndexPath:indexPath];
//2.在控制器内为需要实现Peek & Pop交互的控件注册Peek & Pop功能
    [self registerForPreviewingWithDelegate:self sourceView:cell];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.model = self.dataSourceArray[indexPath.row];
    [cell.openVideo addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.openVideo.tag = indexPath.row;
    
    [cell.downVideo addTarget:self action:@selector(downVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.downVideo.tag = indexPath.row;
    
    if (wmPlayer&&wmPlayer.superview) {
        if (indexPath.row==currentIndexPath.row) {
            [cell.openVideo.superview sendSubviewToBack:cell.openVideo];
        }else{
            [cell.openVideo.superview bringSubviewToFront:cell.openVideo];
        }
        NSArray *indexpaths = [tableView indexPathsForVisibleRows];
        if (![indexpaths containsObject:currentIndexPath]&&currentIndexPath!=nil) {//复用
            if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:wmPlayer]) {
                wmPlayer.hidden = NO;
            }else{
                wmPlayer.hidden = YES;
                [cell.openVideo.superview bringSubviewToFront:cell.openVideo];
            }
        }else{
            if ([cell.videoImageView.subviews containsObject:wmPlayer]) {
                [cell.videoImageView addSubview:wmPlayer];
                [wmPlayer play];
                wmPlayer.hidden = NO;
            }
        }
    }
    return cell;
}
#pragma mark - 下载方法
- (void)downVideoAction:(UIButton *)sender {
    PGGLog(@"下载---%ld",sender.tag);
}
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

#pragma mark 旋转屏幕
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self makeDataUseOfAFNetworking];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        //旋转屏幕通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange{
    if (wmPlayer==nil||wmPlayer.superview==nil){
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            PGGLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            PGGLog(@"第0个旋转方向---电池栏在上");
            if (wmPlayer.isFullscreen) {
                if (isSmallScreen) {
                        //放widow上,小屏显示
//                    [self toSmallScreen];
                }else{
//                    [self toCell];
                }
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            PGGLog(@"第2个旋转方向---电池栏在左");
            wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            PGGLog(@"第1个旋转方向---电池栏在右");
            wmPlayer.isFullscreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
        }
            break;
        default:
            break;
    }
}
//全屏显示
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [wmPlayer removeFromSuperview];
    wmPlayer.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    wmPlayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    wmPlayer.playerLayer.frame =  CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height,[UIScreen mainScreen].bounds.size.width);
    
    [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset(0);
    }];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.height/2-155/2, [UIScreen mainScreen].bounds.size.width/2-155/2, 155, 155);
    }else{
    }
    [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-120/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-60/2);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(120);
    }];
    
    [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(70);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.top.equalTo(wmPlayer.contentView).with.offset(0);
    }];
    
    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.equalTo(wmPlayer).with.offset(0);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
        make.bottom.equalTo(wmPlayer.contentView).with.offset(0);
    }];
    
    [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset(0);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-30/2);
        make.height.equalTo(@30);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.height);
    }];
    
    [wmPlayer.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.height/2-22/2);
        make.top.equalTo(wmPlayer).with.offset([UIScreen mainScreen].bounds.size.width/2-22/2);
        make.height.mas_equalTo(22);
        make.width.mas_equalTo(22);
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
    wmPlayer.fullScreenBtn.selected = YES;
    wmPlayer.isFullscreen = YES;
    wmPlayer.FF_View.hidden = YES;
}
//把播放器wmPlayer对象放到cell上，同时更新约束
-(void)toCell{
    PGGVideoViewCell *currentCell = (PGGVideoViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.7f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = currentCell.videoImageView.bounds;
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [currentCell.videoImageView addSubview:wmPlayer];
        [currentCell.videoImageView bringSubviewToFront:wmPlayer];
        [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wmPlayer).with.offset(0);
            make.width.mas_equalTo(wmPlayer.frame.size.width);
            make.height.mas_equalTo(wmPlayer.frame.size.height);
        }];
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            wmPlayer.effectView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-155/2, [UIScreen mainScreen].bounds.size.height/2-155/2, 155, 155);
        }else{
        }
        
        [wmPlayer.FF_View  mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(wmPlayer.contentView);
            make.height.mas_equalTo(60);
            make.width.mas_equalTo(120);
        }];
        
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(50);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(70);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer.topView).with.offset(45);
            make.right.equalTo(wmPlayer.topView).with.offset(-45);
            make.center.equalTo(wmPlayer.topView);
            make.top.equalTo(wmPlayer.topView).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(20);
        }];
        [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wmPlayer);
            make.width.equalTo(wmPlayer);
            make.height.equalTo(@30);
        }];
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        isSmallScreen = NO;
        wmPlayer.fullScreenBtn.selected = NO;
        wmPlayer.FF_View.hidden = YES;
    }];
}
-(void)toSmallScreen{
//放widow上
    [wmPlayer removeFromSuperview];
    [UIView animateWithDuration:0.7f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height-([UIScreen mainScreen].bounds.size.width/2)*0.75, [UIScreen mainScreen].bounds.size.width/2, ([UIScreen mainScreen].bounds.size.width/2)*0.75);
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
        
        [wmPlayer.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width/2);
            make.height.mas_equalTo(([UIScreen mainScreen].bounds.size.width/2)*0.75);
            make.left.equalTo(wmPlayer).with.offset(0);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.top.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer.topView).with.offset(45);
            make.right.equalTo(wmPlayer.topView).with.offset(-45);
            make.center.equalTo(wmPlayer.topView);
            make.top.equalTo(wmPlayer.topView).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(5);
            
        }];
        [wmPlayer.loadFailedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(wmPlayer);
            make.width.equalTo(wmPlayer);
            make.height.equalTo(@30);
        }];
        
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        wmPlayer.fullScreenBtn.selected = NO;
        isSmallScreen = YES;
        wmPlayer.FF_View.hidden = YES;
        [[UIApplication sharedApplication].keyWindow bringSubviewToFront:wmPlayer];
    }];
}
#pragma mark WMPDelegate
    ///播放器事件
-(void)wmplayer:(WMPlayer *)wmplayer clickedCloseButton:(UIButton *)closeBtn{
    PGGLog(@"didClickedCloseButton");
    PGGVideoViewCell *currentCell = (PGGVideoViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.openVideo.superview bringSubviewToFront:currentCell.openVideo];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}
-(void)wmplayer:(WMPlayer *)wmplayer clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (fullScreenBtn.isSelected) {//全屏显示
        wmPlayer.isFullscreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        if (isSmallScreen) {
                //放widow上,小屏显示
//            [self toSmallScreen];
        }else{
            [self  toCell];
        }
    }
}
-(void)wmplayer:(WMPlayer *)wmplayer singleTaped:(UITapGestureRecognizer *)singleTap{
    PGGLog(@"didSingleTaped");
}
-(void)wmplayer:(WMPlayer *)wmplayer doubleTaped:(UITapGestureRecognizer *)doubleTap{
    PGGLog(@"didDoubleTaped");
}
//播放状态
-(void)wmplayerFailedPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    PGGLog(@"wmplayerDidFailedPlay");
}
-(void)wmplayerReadyToPlay:(WMPlayer *)wmplayer WMPlayerStatus:(WMPlayerState)state{
    PGGLog(@"wmplayerDidReadyToPlay");
}
-(void)wmplayerFinishedPlay:(WMPlayer *)wmplayer{
    PGGLog(@"wmplayerDidFinishedPlay");
    PGGVideoViewCell *currentCell = (PGGVideoViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row inSection:0]];
    [currentCell.openVideo.superview bringSubviewToFront:currentCell.openVideo];
    [self releaseWMPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}
/**
 *  释放WMPlayer
 */
-(void)releaseWMPlayer{
    [wmPlayer pause];
    [wmPlayer removeFromSuperview];
    [wmPlayer.playerLayer removeFromSuperlayer];
    [wmPlayer.player replaceCurrentItemWithPlayerItem:nil];
    wmPlayer.player = nil;
    wmPlayer.currentItem = nil;
//释放定时器，否侧不会调用WMPlayer中的dealloc方法
    [wmPlayer.autoDismissTimer invalidate];
    wmPlayer.autoDismissTimer = nil;
    wmPlayer.playOrPauseBtn = nil;
    wmPlayer.playerLayer = nil;
    wmPlayer = nil;
}
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height;
    if (self.cellHeightArray.count > indexPath.row) {
            // 如果有缓存的高度，取出缓存高度
        height = [self.cellHeightArray[indexPath.row] floatValue];;
    }else{
            // 无缓存高度，计算高度，并加入数组
            // 這裏返回需要的高度
        height = 180;
            // 加入数组
        [self.cellHeightArray addObject:[NSNumber numberWithDouble:height]];
    }
    return height;
}

#pragma mark scrollView delegate
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

#pragma mark MJRefresh
-(void)addMJRefresh{
    __unsafe_unretained UITableView *tableView = self.tableView;
        // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self makeDataUseOfAFNetworking];
        [tableView.mj_header endRefreshing];
        [SVProgressHUD dismiss];

    }];
        // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
        // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 5;// 超时时间
        manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传JSON格式
        NSString *URLString = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%ld-100.html",self.dataSourceArray.count - self.dataSourceArray.count%10];
        [manager GET:URLString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
                // 这里可以获取到目前数据请求的进度
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                // 请求成功
            if(responseObject){
                NSArray *data = responseObject[@"videoList"];
                for (NSDictionary *dic in data) {
                    PGGVideoModel *model = [PGGVideoModel yy_modelWithJSON:dic];
                    [self.dataSourceArray addObject:model];
                }
                [self.cellHeightArray removeAllObjects];
                [self.tableView reloadData];
                [SVProgressHUD showWithStatus:@"加载成功"];
            } else {
                PGGLog(@"暂时没有数据");
                [SVProgressHUD showWithStatus:@"由于网络原因 暂没有请求到数据"];
            }
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                // 请求失败
            PGGLog(@"%@",error);
            [SVProgressHUD showErrorWithStatus:@"小主很抱歉 网络不咋好 没有请求到数据"];
        }];
        [tableView.mj_footer endRefreshing];
        [SVProgressHUD dismiss];
    }];
}
#pragma mark viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addMJRefresh];
    [self createNavigationView];
    
}
#pragma mark AFNetWorking
- (void) makeDataUseOfAFNetworking {
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;// 超时时间
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传JSON格式
    [manager GET:@"http://c.m.163.com/nc/video/home/0-50.html" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
            // 这里可以获取到目前数据请求的进度
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // 请求成功
        if(responseObject){
            NSArray *data = responseObject[@"videoList"];
            for (NSDictionary *dic in data) {
                PGGVideoModel *model = [PGGVideoModel yy_modelWithJSON:dic];
                [self.dataSourceArray addObject:model];
            }
            [self.cellHeightArray removeAllObjects];
            [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"加载完成"];
        } else {
            PGGLog(@"暂时没有数据");
            [SVProgressHUD showWithStatus:@"暂无数据"];
        }
        [SVProgressHUD dismiss];

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // 请求失败
        PGGLog(@"%@",error);
        [SVProgressHUD showErrorWithStatus:@"由于网络原因，暂没有找到数据"];
    }];
    [SVProgressHUD dismiss];
}

#pragma mark 导航条
- (void)createNavigationView {
    self.view.backgroundColor = [UIColor darkGrayColor];
    self.navView = [[UIView alloc] initWithFrame:CGRectMake(0, kStatusBar_Height, kScreen_Width, 44)];
    self.navView.backgroundColor = [UIColor darkGrayColor];
    self.navView.alpha = 0.8;
    [self.view addSubview:self.navView];
    [self.view addSubview:self.tableView];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"播放列表"]];
    segment.tintColor = [UIColor whiteColor];
    segment.userInteractionEnabled = NO;
    [self.navView addSubview:segment];
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"navigator_btn_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    UIButton *down = [[UIButton alloc] init];
    [down setBackgroundImage:[UIImage imageNamed:@"下载"] forState:UIControlStateNormal];
    [down addTarget:self action:@selector(down) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:down];
    
    [down mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.navView).with.offset(-16);
        make.top.equalTo(self.navView).with.offset(10);
        make.bottom.equalTo(self.navView).with.offset(-10);
        make.width.mas_equalTo(20);
    }];
    
    [segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.navView);
        make.top.equalTo(self.navView).with.offset(10);
        make.bottom.equalTo(self.navView).with.offset(-10);
        make.width.mas_equalTo(150);
    }];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView).with.offset(16);
        make.top.equalTo(self.navView).with.offset(10);
        make.bottom.equalTo(self.navView).with.offset(-10);
        make.width.mas_equalTo(24);
    }];
}
#pragma mark 下载
- (void) down {
    PGG_DownLoadViewController *down = [[PGG_DownLoadViewController alloc] init];
    down.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:down animated:YES completion:nil];
}
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    PGGLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseWMPlayer];
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
