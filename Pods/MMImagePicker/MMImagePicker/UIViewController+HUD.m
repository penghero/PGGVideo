//
//  UIViewController+HUD.m
//  MMImagePicker
//
//  Created by LEA on 2017/3/2.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

static char *hudKey = "hudKey" ;

@implementation UIViewController (HUD)

#pragma mark - 带风火轮的
- (MBProgressHUD *)hud
{
    MBProgressHUD *hud;
    if (!objc_getAssociatedObject(self, hudKey))
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        objc_setAssociatedObject(self, hudKey, hud, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, hudKey);
}

- (void)showHUD:(NSString *)title
{
    self.hud.color = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    self.hud.customView = nil;
    self.hud.dimBackground = NO;
    self.hud.labelText = title;
    self.hud.cornerRadius = 4.0f;
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.hud.alpha = 1.0f;
}

- (void)hideHUD
{
    [self.hud hide:YES];
}

@end
