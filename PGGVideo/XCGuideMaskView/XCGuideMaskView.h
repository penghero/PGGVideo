/*
 *  备注：自定义引导介绍视图 🐾
 */

#import <UIKit/UIKit.h>

@class XCGuideMaskView;

/**
 *  数据源协议
 */
@protocol XCGuideMaskViewDataSource <NSObject>

@required
/**
 *  item 的个数
 */
- (NSInteger)numberOfItemsInGuideMaskView:(XCGuideMaskView *)guideMaskView;
/**
 *  每个 item 的 view
 */
- (UIView *)guideMaskView:(XCGuideMaskView *)guideMaskView viewForItemAtIndex:(NSInteger)index;
/**
 *  每个 item 的文字
 */
- (NSString *)guideMaskView:(XCGuideMaskView *)guideMaskView descriptionForItemAtIndex:(NSInteger)index;

@optional
/**
 *  每个 item 的文字颜色：默认白色
 */
- (UIColor *)guideMaskView:(XCGuideMaskView *)guideMaskView colorForDescriptionAtIndex:(NSInteger)index;
/**
 *  每个 item 的文字字体：默认 [UIFont systemFontOfSize:13]
 */
- (UIFont *)guideMaskView:(XCGuideMaskView *)guideMaskView fontForDescriptionAtIndex:(NSInteger)index;

@end



@protocol XCGuideMaskViewLayout <NSObject>

@optional
/**
 *  每个 item 的 view 蒙板的圆角：默认为 5
 */
- (CGFloat)guideMaskView:(XCGuideMaskView *)guideMaskView cornerRadiusForViewAtIndex:(NSInteger)index;
/**
 *  每个 item 的 view 与蒙板的边距：默认 (-8, -8, -8, -8)
 */
- (UIEdgeInsets)guideMaskView:(XCGuideMaskView *)guideMaskView insetForViewAtIndex:(NSInteger)index;
/**
 *  每个 item 的子视图（当前介绍的子视图、箭头、描述文字）之间的间距：默认为 20
 */
- (CGFloat)guideMaskView:(XCGuideMaskView *)guideMaskView spaceForItemAtIndex:(NSInteger)index;
/**
 *  每个 item 的文字与左右边框间的距离：默认为 50
 */
- (CGFloat)guideMaskView:(XCGuideMaskView *)guideMaskView horizontalInsetForDescriptionAtIndex:(NSInteger)index;

@end



@interface XCGuideMaskView : UIView

/** 👀 箭头图片 👀 */
@property (strong, nonatomic) UIImage *arrowImage;

/** 👀 蒙板背景颜色：默认 黑色 👀 */
@property (strong, nonatomic) UIColor *maskBackgroundColor;
/** 👀 蒙板透明度：默认 .7f 👀 */
@property (assign, nonatomic) CGFloat maskAlpha;

/** 👀 数据源 👀 */
@property (weak, nonatomic) id<XCGuideMaskViewDataSource> dataSource;
/** 👀 布局 👀 */
@property (weak, nonatomic) id<XCGuideMaskViewLayout> layout;

/**
 *  根据一个数据源，来创建一个 guideView
 */
- (instancetype)initWithDatasource:(id<XCGuideMaskViewDataSource>)dataSource;

/**
 *  显示
 */
- (void)show;

@end
