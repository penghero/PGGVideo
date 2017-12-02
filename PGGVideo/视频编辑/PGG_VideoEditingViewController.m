//
//  PGG_VideoEditingViewController.m
//  PGGVideo
//
//  Created by 陈鹏 on 2017/11/16.
//  Copyright © 2017年 penggege.CP. All rights reserved.
//

#import "PGG_VideoEditingViewController.h"

@interface PGG_VideoEditingViewController ()

@end

@implementation PGG_VideoEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}
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
