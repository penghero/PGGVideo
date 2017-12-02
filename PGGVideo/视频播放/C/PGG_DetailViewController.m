//
//  PGG_DetailViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/17.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_DetailViewController.h"

@interface PGG_DetailViewController ()

@end

@implementation PGG_DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//3.在Peek时希望提供一些快捷选项,需要在DetailViewController中重写previewActionItems的getter方法
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"播放" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"播放");
    }];
    
    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"下载" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"下载");
    }];
    
    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"分享" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        NSLog(@"分享");
    }];
    //    UIPreviewActionGroup *actionGroup = [UIPreviewActionGroup actionGroupWithTitle:@"删除" style:UIPreviewActionStyleDestructive actions:@[action1, action2,action3]];
    
    return @[action1, action2, action3];
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
