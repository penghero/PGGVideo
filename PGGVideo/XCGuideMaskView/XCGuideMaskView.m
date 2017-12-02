/*
 *  备注：自定义引导介绍视图 🐾
 */

#import "XCGuideMaskView.h"


typedef NS_ENUM(NSInteger, XCGuideMaskItemRegion)
{
    /// 左上方
    XCGuideMaskItemRegionLeftTop = 0,
    
    /// 左下方
    XCGuideMaskItemRegionLeftBottom,
    
    /// 右上方
    XCGuideMaskItemRegionRightTop,
    
    /// 右下方
    XCGuideMaskItemRegionRightBottom
};


@interface XCGuideMaskView ()

/** 👀 蒙板 👀 */
@property (strong, nonatomic) UIView *maskView;
/** 👀 箭头图片 👀 */
@property (strong, nonatomic) UIImageView *arrowImgView;
/** 👀 描述LB 👀 */
@property (strong, nonatomic) UILabel *textLB;

@property (strong, nonatomic) CAShapeLayer *maskLayer;

/** 👀 当前正在进行引导的 item 的下标 👀 */
@property (assign, nonatomic) NSInteger currentIndex;

@end


@implementation XCGuideMaskView
{
    /// 记录 items 的数量
    NSInteger _count;
}

#pragma mark - 👀 Init Method 👀 💤

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds])
    {
        /// 设置 UI
        [self setupUI];
    }
    
    return self;
}

- (instancetype)initWithDatasource:(id<XCGuideMaskViewDataSource>)dataSource
{
    XCGuideMaskView *guideView = [[XCGuideMaskView alloc] initWithFrame:CGRectZero];
    
    guideView.dataSource = dataSource;
    
    return guideView;
}

/**
 *  设置 UI
 */
- (void)setupUI
{
    /// 添加子视图
    [self addSubview:self.maskView];
    [self addSubview:self.arrowImgView];
    [self addSubview:self.textLB];
    
    /// 设置默认数据
    self.backgroundColor     = [UIColor clearColor];
    self.maskBackgroundColor = [UIColor blackColor];
    self.maskAlpha  = .7f;
    self.arrowImage = [UIImage imageNamed:@"guide_arrow"];
    
    self.textLB.textColor = [UIColor whiteColor];
    self.textLB.font = [UIFont systemFontOfSize:13];
}

#pragma mark - 💤 👀 LazyLoad Method 👀

- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer)
    {
        _maskLayer = [CAShapeLayer layer];
    }
    
    return _maskLayer;
}

- (UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
    }
    
    return _maskView;
}

- (UILabel *)textLB
{
    if (!_textLB)
    {
        _textLB = [UILabel new];
        _textLB.numberOfLines = 0;
    }
    
    return _textLB;
}

- (UIImageView *)arrowImgView
{
    if (!_arrowImgView)
    {
        _arrowImgView = [UIImageView new];
    }
    
    return _arrowImgView;
}

#pragma mark - 👀 Setter Method 👀 💤

- (void)setArrowImage:(UIImage *)arrowImage
{
    _arrowImage = arrowImage;
    
    self.arrowImgView.image = arrowImage;
}

- (void)setMaskBackgroundColor:(UIColor *)maskBackgroundColor
{
    _maskBackgroundColor = maskBackgroundColor;
    
    self.maskView.backgroundColor = maskBackgroundColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha
{
    _maskAlpha = maskAlpha;
    
    self.maskView.alpha = maskAlpha;
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    /// 显示遮罩
    [self showMask];
    
    /// 设置 子视图的 frame
    [self congifureItemsFrame];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  显示蒙板
 */
- (void)showMask
{
    CGPathRef fromPath = self.maskLayer.path;
    
    /// 更新 maskLayer 的 尺寸
    self.maskLayer.frame = self.bounds;
    self.maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGFloat maskCornerRadius = 5;
    
    if (self.layout && [self.layout respondsToSelector:@selector(guideMaskView:cornerRadiusForViewAtIndex:)])
    {
        maskCornerRadius = [self.layout guideMaskView:self cornerRadiusForViewAtIndex:self.currentIndex];
    }
    
    /// 获取可见区域的路径(开始路径)
    UIBezierPath *visualPath = [UIBezierPath bezierPathWithRoundedRect:[self fetchVisualFrame] cornerRadius:maskCornerRadius];
    
    /// 获取终点路径
    UIBezierPath *toPath = [UIBezierPath bezierPathWithRect:self.bounds];
    
    [toPath appendPath:visualPath];
    
    /// 遮罩的路径
    self.maskLayer.path = toPath.CGPath;
    self.maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.layer.mask = self.maskLayer;
    
    /// 开始移动动画
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.duration  = 0.3;
    anim.fromValue = (__bridge id _Nullable)(fromPath);
    anim.toValue   = (__bridge id _Nullable)(toPath.CGPath);
    [self.maskLayer addAnimation:anim forKey:NULL];
}

/**
 *  设置 items 的 frame
 */
- (void)congifureItemsFrame
{
    /// 设置 描述文字的属性
    // 文字颜色
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:colorForDescriptionAtIndex:)])
    {
        self.textLB.textColor = [self.dataSource guideMaskView:self colorForDescriptionAtIndex:self.currentIndex];
    }
    // 文字字体
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(guideMaskView:fontForDescriptionAtIndex:)])
    {
        self.textLB.font = [self.dataSource guideMaskView:self fontForDescriptionAtIndex:self.currentIndex];
    }
    
    // 描述文字
    NSString *desc = [self.dataSource guideMaskView:self descriptionForItemAtIndex:self.currentIndex];
    
    self.textLB.text = desc;
    
    /// 每个 item 的文字与左右边框间的距离
    CGFloat descInsetsX = 50;
    
    if (self.layout && [self.layout respondsToSelector:@selector(guideMaskView:horizontalInsetForDescriptionAtIndex:)])
    {
        descInsetsX = [self.layout guideMaskView:self horizontalInsetForDescriptionAtIndex:self.currentIndex];
    }
    
    /// 每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距
    CGFloat space = 20;
    
    if (self.layout && [self.layout respondsToSelector:@selector(guideMaskView:spaceForItemAtIndex:)])
    {
        space = [self.layout guideMaskView:self spaceForItemAtIndex:self.currentIndex];
    }
    
    /// 设置 文字 与 箭头的位置
    CGRect textRect, arrowRect;
    CGSize imgSize   = self.arrowImgView.image.size;
    CGFloat maxWidth = self.bounds.size.width - descInsetsX * 2;
    CGSize textSize  = [desc boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                     attributes:@{NSFontAttributeName : self.textLB.font}
                                                                        context:NULL].size;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    /// 获取 item 的 方位
    XCGuideMaskItemRegion itemRegion = [self fetchVisualRegion];
    
    switch (itemRegion)
    {
        case XCGuideMaskItemRegionLeftTop:
        {
            /// 左上
            transform = CGAffineTransformMakeScale(-1, 1);
            arrowRect = CGRectMake(CGRectGetMidX([self fetchVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self fetchVisualFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self fetchVisualFrame]))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
            break;
        }
        case XCGuideMaskItemRegionRightTop:
        {
            /// 右上
            arrowRect = CGRectMake(CGRectGetMidX([self fetchVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMaxY([self fetchVisualFrame]) + space,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self fetchVisualFrame]))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMaxY(arrowRect) + space, textSize.width, textSize.height);
            break;
        }
        case XCGuideMaskItemRegionLeftBottom:
        {
            /// 左下
            transform = CGAffineTransformMakeScale(-1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self fetchVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self fetchVisualFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self fetchVisualFrame]))
            {
                x = CGRectGetMaxX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
        case XCGuideMaskItemRegionRightBottom:
        {
            /// 右下
            transform = CGAffineTransformMakeScale(1, -1);
            arrowRect = CGRectMake(CGRectGetMidX([self fetchVisualFrame]) - imgSize.width * 0.5,
                                   CGRectGetMinY([self fetchVisualFrame]) - space - imgSize.height,
                                   imgSize.width,
                                   imgSize.height);
            
            CGFloat x = 0;
            
            if (textSize.width < CGRectGetWidth([self fetchVisualFrame]))
            {
                x = CGRectGetMinX(arrowRect) - textSize.width * 0.5;
            }
            else
            {
                x = descInsetsX + maxWidth - textSize.width;
            }
            
            textRect = CGRectMake(x, CGRectGetMinY(arrowRect) - space - textSize.height, textSize.width, textSize.height);
            break;
        }
    }
    
    /// 图片 和 文字的动画
    [UIView animateWithDuration:0.3 animations:^{
        
        self.arrowImgView.transform = transform;
        self.arrowImgView.frame = arrowRect;
        self.textLB.frame = textRect;
    }];
}

/**
 *  获取可见的视图的frame
 */
- (CGRect)fetchVisualFrame
{
    if (self.currentIndex >= _count)
    {
        return CGRectZero;
    }
    
    UIView *view = [self.dataSource guideMaskView:self viewForItemAtIndex:self.currentIndex];
    
    CGRect visualRect = [self convertRect:view.frame fromView:view.superview];
    
    /// 每个 item 的 view 与蒙板的边距
    UIEdgeInsets maskInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
    
    if (self.layout && [self.layout respondsToSelector:@selector(guideMaskView:insetForViewAtIndex:)])
    {
        [self.layout guideMaskView:self insetForViewAtIndex:self.currentIndex];
    }
    
    visualRect.origin.x += maskInsets.left;
    visualRect.origin.y += maskInsets.top;
    visualRect.size.width  -= (maskInsets.left + maskInsets.right);
    visualRect.size.height -= (maskInsets.top + maskInsets.bottom);
    
    return visualRect;
}

/**
 *  获取可见区域的方位
 */
- (XCGuideMaskItemRegion)fetchVisualRegion
{
    /// 可见区域的中心坐标
    CGPoint visualCenter = CGPointMake(CGRectGetMidX([self fetchVisualFrame]),
                                       CGRectGetMidY([self fetchVisualFrame]));
    /// self.view 的中心坐标
    CGPoint viewCenter   = CGPointMake(CGRectGetMidX(self.bounds),
                                       CGRectGetMidY(self.bounds));
    
    if ((visualCenter.x <= viewCenter.x)    &&
        (visualCenter.y <= viewCenter.y))
    {
        /// 当前显示的视图在左上角
        return XCGuideMaskItemRegionLeftTop;
    }
    
    if ((visualCenter.x > viewCenter.x)     &&
        (visualCenter.y <= viewCenter.y))
    {
        /// 当前显示的视图在右上角
        return XCGuideMaskItemRegionRightTop;
    }
    
    if ((visualCenter.x <= viewCenter.x)    &&
        (visualCenter.y > viewCenter.y))
    {
        /// 当前显示的视图在左下角
        return XCGuideMaskItemRegionLeftBottom;
    }
    
    /// 当前显示的视图在右下角
    return XCGuideMaskItemRegionRightBottom;
}


#pragma mark - 🔓 👀 Public Method 👀

/**
 *  显示
 */
- (void)show
{
    if (self.dataSource)
    {
        _count = [self.dataSource numberOfItemsInGuideMaskView:self];
    }
    
    /// 如果当前没有可以显示的 item 的数量
    if (_count < 1)  return;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.alpha = 0;
    
    [UIView animateWithDuration:.3f animations:^{
        
        self.alpha = 1;
    }];

    /// 从 0 开始进行显示
    self.currentIndex = 0;
}

#pragma mark - 🎬 👀 Action Method 👀

/**
 *  隐藏
 */
- (void)hide
{
    [UIView animateWithDuration:.3f animations:^{
        
        self.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    /**
     *  如果当前下标不是最后一个，则移到下一个介绍的视图
     *  如果当前下标是最后一个，则直接返回
     */
    
    if (self.currentIndex < _count-1)
    {
        self.currentIndex ++;
    }
    else
    {
        [self hide];
    }
}

@end
