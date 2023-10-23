//
//  YLNavigationController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLNavigationController.h"
#import "YLNavigationDelegate.h"

@interface YLNavigationController ()
@property (nonatomic, strong) YLNavigationDelegate *naviDelegate;
@end

@implementation YLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:20], NSForegroundColorAttributeName: [UIColor blackColor]}];
    _naviDelegate = [YLNavigationDelegate new];
    self.delegate = _naviDelegate;
//    self.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
