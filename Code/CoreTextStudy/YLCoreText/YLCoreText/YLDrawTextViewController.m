//
//  YLDrawTextViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/15.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLDrawTextViewController.h"
#import "YLDrawTextView.h"
#import "YLCTDisplayView.h"
#import "YLCTFrameParserConfig.h"
#import "YLCTFrameParser.h"
#import "YLCoreTextData.h"
#import "UIView+YLFrame.h"

@interface YLDrawTextViewController ()

@end

@implementation YLDrawTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"绘制文本";
    //1.
    YLDrawTextView *textView = [[YLDrawTextView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 100)];
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    
    //2.
    YLCTDisplayView *displayView = [[YLCTDisplayView alloc]initWithFrame:CGRectMake(0, 170, self.view.frame.size.width, 200)];
    [self.view addSubview:displayView];
    
    YLCTFrameParserConfig *config = [[YLCTFrameParserConfig alloc]init];
    config.textColor = [UIColor redColor];
    config.width = displayView.width;
    
    YLCoreTextData *data = [YLCTFrameParser parseContent:@"按照‘单一功能原则’，我们应该把功能拆分，"
                                                        "把不同的功能都放到各自不同的类里面"
                                                        "1.一个显示用的类，仅负责显示内容，不负责排版。"
                                                        "2.一个模型类，用于承载显示所需要的所有数据。"
                                                        "3.一个排版类，用于实现文字内容的排版。"
                                                        "4.一个配置类，用于实现一些排版时的可配置项。"
                                                  config:config];
    displayView.data = data;
    displayView.height = data.height;
    displayView.backgroundColor = [UIColor yellowColor];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
