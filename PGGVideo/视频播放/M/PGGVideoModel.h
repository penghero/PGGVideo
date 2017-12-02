//
//  PGGVideoModel.h
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/17.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 视频模型
 */
@interface PGGVideoModel : NSObject

@property(copy,nonatomic)NSString  * descriptionD;
@property(copy,nonatomic)NSString  * cover;
@property(copy,nonatomic)NSString  * m3u8_url;
@property(copy,nonatomic)NSString  * mp4_url;
@property(copy,nonatomic)NSString  * title;
@property(copy,nonatomic)NSString  * topicDesc;
@property(copy,nonatomic)NSString  * topicImg;
@property(copy,nonatomic)NSString  * topicName;
@property(assign,nonatomic)NSInteger  sizeSD;

@end
