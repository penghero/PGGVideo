//
//  AppDelegate.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PGG_SelfieViewController.h"
#import "PGG_ARViewController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self creatShortcutItem];  //动态创建应用图标上的3D touch快捷选项
    UIApplicationShortcutItem *shortcutItem = [launchOptions valueForKey:UIApplicationLaunchOptionsShortcutItemKey];
    if (shortcutItem) {
            //判断设置的快捷选项标签唯一标识，根据不同标识执行不同操作
        if ([shortcutItem.type isEqualToString:PGG3D_TouchShare]) {
            NSDictionary *dict = @{@"type":shortcutItem.type};
                //          通过 通知中心 发送 通知
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Notification" object:nil userInfo:dict]];
        }
        if ([shortcutItem.type isEqualToString:PGG3D_TouchPhoto]) {
            NSLog(@"进入自拍");
            NSDictionary *dict = @{@"type":shortcutItem.type};
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Notification" object:nil userInfo:dict]];
        }
        if ([shortcutItem.type isEqualToString:PGG3D_TouchAR]) {
            NSLog(@"进入AR");
            NSDictionary *dict = @{@"type":shortcutItem.type};
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Notification" object:nil userInfo:dict]];
        }
        return NO;
    }
    return YES;
}
//1.添加快捷选项
- (void)creatShortcutItem {
        // 使用系统提供的图标
//    + (instancetype)iconWithType:(UIApplicationShortcutIconType)type;
        // 自定义图标
//    + (instancetype)iconWithTemplateImageName:(NSString *)templateImageName;
    
        //创建系统风格的icon
    UIApplicationShortcutIcon *iconShare = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeShare];
    UIApplicationShortcutIcon *iconPhoto = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCapturePhoto];
    UIApplicationShortcutIcon *iconAR = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay];
        //创建快捷选项
    UIApplicationShortcutItem * itemShare = [[UIApplicationShortcutItem alloc]initWithType:PGG3D_TouchShare localizedTitle:@"分享'鹏哥哥Video'" localizedSubtitle:nil icon:iconShare userInfo:nil];
    UIApplicationShortcutItem * itemPhoto = [[UIApplicationShortcutItem alloc]initWithType:PGG3D_TouchPhoto localizedTitle:@"自拍" localizedSubtitle:nil icon:iconPhoto userInfo:nil];
    UIApplicationShortcutItem *itemAR = [[UIApplicationShortcutItem alloc] initWithType:PGG3D_TouchAR localizedTitle:@"体验AR" localizedSubtitle:nil icon:iconAR userInfo:nil];
        //添加到快捷选项数组
    [UIApplication sharedApplication].shortcutItems = @[itemShare,itemPhoto,itemAR];
}

//2.如果APP没被杀死，还存在后台，点开Touch会调用该代理方法 app通过图标的3D touch功能进入时，系统会调入如下方法
//注意：应用上线之后系统会给应用自动生成一个分享功能，然后测试的时候是不会显示这个分享的。
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    ViewController *mainView = [[ViewController alloc] init];
    self.window.rootViewController = mainView;
    [self.window makeKeyAndVisible];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0    &&self.window.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable)
            {
            if (shortcutItem) {
                    //判断设置的快捷选项标签唯一标识，根据不同标识执行不同操作
                if ([shortcutItem.type isEqualToString:PGG3D_TouchShare]) {
                    NSLog(@"APP没被杀死-- 分享");
                }
                if ([shortcutItem.type isEqualToString:PGG3D_TouchPhoto]) {
                    NSLog(@"进入自拍");
                    PGG_SelfieViewController *selfie = [[PGG_SelfieViewController alloc] init];
                    selfie.modalTransitionStyle = UIModalPresentationOverCurrentContext;
                    [self.window.rootViewController presentViewController:selfie animated:YES completion:nil];
                }
                if ([shortcutItem.type isEqualToString:PGG3D_TouchAR]) {
                    NSLog(@"进入AR");
                    PGG_ARViewController *ar = [[PGG_ARViewController alloc] init];
                    ar.modalTransitionStyle = UIModalPresentationPopover;
                    [self.window.rootViewController presentViewController:ar animated:YES completion:nil];
                }
            }
            }else {
                NSLog(@"您的手机不支持3D Touch功能!");
            }
    if (completionHandler) {
        completionHandler(YES);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
