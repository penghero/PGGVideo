//
//  MMAlbumCell.m
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMAlbumCell.h"
#import "MMImagePickerComponent.h"

@implementation MMAlbumCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setOrigin:CGPointMake(0, 0)];
    [self.textLabel setLeft:self.imageView.right + 10];
    [self setSeparatorInset:UIEdgeInsetsMake(0, self.imageView.width, 0, 0)];
}

@end
