//
//  PGG_DownLoadViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/30.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_DownLoadViewController.h"
#import <Masonry.h>
#import "PGG_DownCell.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "PGGVideoModel.h"
#import <YYModel.h>


static NSString *PGG_DownCell_ID = @"PGG_DownCell_ID";

@interface PGG_DownLoadViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray * cellHeightArray;//cell高度缓存
@property(strong,nonatomic) UIView *navView;
@property(strong,nonatomic) UITableView * tableView;
@property(strong,nonatomic)NSMutableArray * dataSourceArray;//总数据
/** AFNetworking断点下载（支持离线）需用到的属性 **********/
/** 文件的总长度 */
@property (nonatomic, assign) NSInteger fileLength;
/** 当前下载长度 */
@property (nonatomic, assign) NSInteger currentLength;
/** 文件句柄对象 */
@property (nonatomic, strong) NSFileHandle *fileHandle;
/** 下载任务 */
@property (nonatomic, strong) NSURLSessionDataTask *downloadTask;
/* AFURLSessionManager */
@property (nonatomic, strong) AFURLSessionManager *manager;

@end

@implementation PGG_DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initWithUILayout];
    [self makeDataUseOfAFNetworking];
}
/**
 * manager的懒加载
 */
- (AFURLSessionManager *)manager {
    if (!_manager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            // 1. 创建会话管理者
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _manager;
}


#pragma mark AFNetWorking
- (void) makeDataUseOfAFNetworking {
    [SVProgressHUD showWithStatus:@"正在加载数据"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;// 超时时间
    manager.requestSerializer = [AFHTTPRequestSerializer serializer]; // 上传JSON格式
    [manager GET:@"http://c.m.163.com/nc/video/home/5-20.html" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
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

#pragma mark - 初始化
- (void)initWithUILayout {
    [self createNavigationView];
    [self.view addSubview:self.tableView];
}
#pragma mark - 懒加载
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
        [_tableView registerNib:[UINib nibWithNibName:@"PGG_DownCell" bundle:nil]  forCellReuseIdentifier:PGG_DownCell_ID];
    }
    return _tableView;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PGG_DownCell *cell = [tableView dequeueReusableCellWithIdentifier:PGG_DownCell_ID forIndexPath:indexPath];
    cell.model = self.dataSourceArray[indexPath.row];
    
    return cell;
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
        height = 60;
            // 加入数组
        [self.cellHeightArray addObject:[NSNumber numberWithDouble:height]];
    }
    return height;
}
#pragma mark 导航条
- (void)createNavigationView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kTableView_Height)];
    self.navView.backgroundColor = [UIColor darkGrayColor];
    self.navView.alpha = 0.8;
    [self.view addSubview:self.navView];
    
    UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:@[@"下载列表"]];
    segment.tintColor = [UIColor whiteColor];
    segment.userInteractionEnabled = NO;
    [self.navView addSubview:segment];
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"navigator_btn_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.navView addSubview:backBtn];
    
    [segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.navView).with.offset(10);
        make.bottom.equalTo(self.navView).with.offset(-10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(30);
    }];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView).with.offset(16);
        make.bottom.equalTo(self.navView).with.offset(-10);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
}
#pragma mark 返回
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
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
