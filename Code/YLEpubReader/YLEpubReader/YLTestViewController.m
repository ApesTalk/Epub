//
//  YLTestViewController.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/1.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLTestViewController.h"

@interface YLTestViewController ()

@end

@implementation YLTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = _bgColor;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:18];
    label.text = @"EPUB READER";
    label.textAlignment = NSTextAlignmentCenter;
    label.center = self.view.center;
    [self.view addSubview:label];
}


@end
