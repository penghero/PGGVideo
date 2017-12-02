//
//  MMImageAssetController.m
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMImageAssetController.h"
#import "MMImagePreviewController.h"
#import "MMImageCropController.h"
#import "MMImagePickerComponent.h"
#import "MMAssetCell.h"

//#### MMALAsset
@implementation MMALAsset

@end

//#### MMImageAssetController
static NSString *const CellIdentifier = @"MMPhotoAlbumCell";

@interface MMImageAssetController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) ALAssetsLibrary *library;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray<MMALAsset *> *mmAssetArray;
@property (nonatomic,strong) NSMutableArray<ALAsset *> *selectedAssetArray;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *previewBtn;
@property (nonatomic,strong) UIButton *originBtn;
@property (nonatomic,strong) UIButton *finishBtn;
@property (nonatomic,strong) UILabel *numberLab;

// 是否回传原图[可用于控制图片压系数]
@property (nonatomic, assign) BOOL isOrigin;

@end

@implementation MMImageAssetController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:MMImagePickerSrcName(@"mmphoto_back")]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(leftBarItemAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarItemAction)];
    
    // 标题
    NSString *groupPropertyName = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
    self.title = groupPropertyName;
    
    // 初始化
    _isOrigin = NO;
    if (!_mainColor) {
        _mainColor = kMainColor;
    }
    if (_maximumNumberOfImage == 0) {
        _maximumNumberOfImage = 9;
    }
    [self.view addSubview:self.collectionView];
    if (!_cropImageOption && !_singleImageOption) {
        self.collectionView.height = self.view.height-64-kBottomHeight;
        [self.view addSubview:self.bottomView];
    }
    [self getPhotoAlbum];
    
    // 是否显示原图选项
    _originBtn.hidden = !self.showOriginImageOption;
}

#pragma mark - 获取照片刷新瀑布流
- (void)getPhotoAlbum
{
    self.mmAssetArray = [[NSMutableArray alloc] init];
    self.selectedAssetArray = [[NSMutableArray alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if (!result) {  //为空时，枚举完成
             [weakSelf.collectionView reloadData];
             return;
         }
         //只处理图片[忽略视频]
         if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto])
         {
             MMALAsset *mmAsset = [[MMALAsset alloc] init];
             mmAsset.asset = result;
             mmAsset.isSelected = NO;
             [weakSelf.mmAssetArray insertObject:mmAsset atIndex:0];
         }
     }];
}

#pragma mark - getter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[MMAssetCell class] forCellWithReuseIdentifier:CellIdentifier];
    }
    return _collectionView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.collectionView.bottom, self.view.width, kBottomHeight)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        _bottomView.userInteractionEnabled = NO;
        _bottomView.alpha = 0.5;
        
        // 上边框
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, _bottomView.width, 0.5);
        layer.backgroundColor = [[UIColor lightGrayColor] CGColor];
        [_bottomView.layer addSublayer:layer];
    
        // 预览
        _previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 50, kBottomHeight)];
        _previewBtn.tag = 100;
        [_previewBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_previewBtn setTitle:@"预览" forState:UIControlStateNormal];
        [_previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_previewBtn];
        
        // 原图
        _originBtn = [[UIButton alloc] initWithFrame:CGRectMake(_previewBtn.right+10, 0, 90, kBottomHeight)];
        _originBtn.tag = 101;
        [_originBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_originBtn setTitle:@"原图" forState:UIControlStateNormal];
        [_originBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_originBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_originBtn setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 70)];
        [_originBtn setImage:[UIImage imageNamed:MMImagePickerSrcName(@"mmphoto_mark")] forState:UIControlStateNormal];
        [_originBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_originBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_originBtn];
        
        _numberLab = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width-70, (kBottomHeight-20)/2, 20, 20)];
        _numberLab.backgroundColor = _mainColor;
        _numberLab.layer.cornerRadius = _numberLab.frame.size.height/2;
        _numberLab.layer.masksToBounds = YES;
        _numberLab.textColor = [UIColor whiteColor];
        _numberLab.textAlignment = NSTextAlignmentCenter;
        _numberLab.font = [UIFont boldSystemFontOfSize:13.0];
        _numberLab.adjustsFontSizeToFitWidth = YES;
        [_bottomView addSubview:_numberLab];
        _numberLab.hidden = YES;
        
        _finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width-60, 0, 60, kBottomHeight)];
        _finishBtn.tag = 102;
        [_finishBtn.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
        [_finishBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_finishBtn setTitleColor:_mainColor forState:UIControlStateNormal];
        [_finishBtn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_finishBtn];
    }
    return _bottomView;
}

#pragma mark - 事件处理
- (void)rightBarItemAction
{
    if (self.completion) {
        self.completion(nil, _isOrigin, YES);
    }
}

- (void)leftBarItemAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonAction:(UIButton *)btn
{
    if (btn.tag == 100) //预览
    {
        MMImagePreviewController *previewVC = [[MMImagePreviewController alloc] init];
        previewVC.assetArray = self.selectedAssetArray;
        
        __weak typeof(self) weakSelf = self;
        [previewVC setPhotoDeleteBlock:^(ALAsset *asset)
         {
             for (MMALAsset *mmAsset in weakSelf.mmAssetArray) {
                 if (mmAsset.asset == asset)  {
                     NSInteger index = [weakSelf.mmAssetArray indexOfObject:mmAsset];
                     mmAsset.isSelected = NO;
                     [weakSelf.mmAssetArray replaceObjectAtIndex:index withObject:mmAsset];
                     [weakSelf.collectionView reloadData];
                     break;
                 }
             }
             [weakSelf updateUI];
         }];
        [self.navigationController pushViewController:previewVC animated:YES];
    }
    else if (btn.tag == 101)  //原图
    {
        if (_isOrigin) {
            [_originBtn setImage:[UIImage imageNamed:MMImagePickerSrcName(@"mmphoto_mark")] forState:UIControlStateNormal];
        } else {
            [_originBtn setImage:[UIImage imageNamed:MMImagePickerSrcName(@"mmphoto_marked")] forState:UIControlStateNormal];
        }
        _isOrigin = !_isOrigin;
    }
    else //确定
    {
        if (!self.completion) {
            NSLog(@"警告:未设置回传!!!");
            return;
        }
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for(ALAsset *asset in self.selectedAssetArray)
        {
            id obj = [asset valueForProperty:ALAssetPropertyType];
            if (!obj) {
                continue;
            }
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
            if (location) {
                [dictionary setObject:location forKey:ALAssetPropertyLocation];
            }
            [dictionary setObject:obj forKey:UIImagePickerControllerMediaType];
            ALAssetRepresentation *assetRep = [asset defaultRepresentation];
            if(assetRep != nil)
            {
                CGImageRef imgRef = [assetRep fullScreenImage];
                UIImageOrientation orientation = UIImageOrientationUp;
                UIImage *image = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:orientation];
                [dictionary setObject:image forKey:UIImagePickerControllerOriginalImage];
                [dictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
                [result addObject:dictionary];
            }
        }
        //回传
        self.completion(result, _isOrigin, NO);
    }
}

- (void)updateUI
{
    if (![self.selectedAssetArray count]) {
        self.bottomView.alpha = 0.5;
        _numberLab.hidden = YES;
        self.bottomView.userInteractionEnabled = NO;
    } else {
        self.bottomView.alpha = 1.0;
        _numberLab.hidden = NO;
        _numberLab.text = [NSString stringWithFormat:@"%d",(int)[self.selectedAssetArray count]];
        self.bottomView.userInteractionEnabled = YES;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSInteger eachLine = 4;
    if (kDeviceIsIphone6p) {
        eachLine = 5;
    }
    CGFloat cellWidth = (self.view.width-(eachLine+1)*kBlankWidth)/eachLine;
    return CGSizeMake(cellWidth, cellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(kBlankWidth, kBlankWidth, kBlankWidth, kBlankWidth);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return kBlankWidth;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.mmAssetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MMALAsset *mmAsset = [self.mmAssetArray objectAtIndex:indexPath.row];
    //## 赋值
    MMAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.image = [UIImage imageWithCGImage:mmAsset.asset.thumbnail];
    cell.selected = mmAsset.isSelected;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MMALAsset *mmAsset = [self.mmAssetArray objectAtIndex:indexPath.row];
    ALAsset *asset = mmAsset.asset;
    //## 图片裁剪
    if (_cropImageOption)
    {
        //获取图片
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        CGImageRef imgRef = [assetRep fullScreenImage];
        UIImageOrientation orientation = UIImageOrientationUp;
        UIImage *originalImage = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:orientation];
        
        MMImageCropController *controller = [[MMImageCropController alloc] init];
        controller.originalImage = originalImage;
        controller.imageCropSize = self.imageCropSize;
        
        __weak typeof(self) weakSelf = self;
        [controller setImageCropBlock:^(UIImage *cropImage){
            if (!weakSelf.completion) {
                NSLog(@"警告:未设置回传!!!");
                return;
            }
            //封装
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
            if (location) {
                [dictionary setObject:location forKey:ALAssetPropertyLocation];
            }
            id obj = [asset valueForProperty:ALAssetPropertyType];
            if (obj) {
                [dictionary setObject:obj forKey:UIImagePickerControllerMediaType];
            }
            [dictionary setObject:cropImage forKey:UIImagePickerControllerOriginalImage];
            [dictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
            //回传
            weakSelf.completion(@[dictionary], _isOrigin, NO);
        }];
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    //## 选择一个>>直接返回
    if (_singleImageOption)
    {
        if (!self.completion) {
            NSLog(@"警告:未设置回传!!!");
            return;
        }
        //封装
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        if (location) {
            [dictionary setObject:location forKey:ALAssetPropertyLocation];
        }
        id obj = [asset valueForProperty:ALAssetPropertyType];
        if (obj) {
            [dictionary setObject:obj forKey:UIImagePickerControllerMediaType];
        }
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        if(assetRep != nil) {
            CGImageRef imgRef = [assetRep fullScreenImage];
            UIImageOrientation orientation = UIImageOrientationUp;
            UIImage *image = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:orientation];
            [dictionary setObject:image forKey:UIImagePickerControllerOriginalImage];
            [dictionary setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:UIImagePickerControllerReferenceURL];
        }
        //回传
        self.completion(@[dictionary], _isOrigin, NO);
        return;
    }
    
    //## 提醒
    if (([self.selectedAssetArray count] == _maximumNumberOfImage) && !mmAsset.isSelected) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"最多可以添加%ld张图片",(long)_maximumNumberOfImage]
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"知道了"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    mmAsset.isSelected = !mmAsset.isSelected;
    [self.mmAssetArray replaceObjectAtIndex:indexPath.row withObject:mmAsset];
    [self.collectionView reloadData];
    
    if (mmAsset.isSelected) {
        [self.selectedAssetArray addObject:asset];
    } else {
        [self.selectedAssetArray removeObject:asset];
    }
    [self updateUI];
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
