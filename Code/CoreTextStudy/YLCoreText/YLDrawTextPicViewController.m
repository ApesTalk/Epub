//
//  YLDrawTextPicViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLDrawTextPicViewController.h"
#import "YLCTFrameParserConfig.h"
#import "YLCTFrameParser.h"
#import "YLCTDisplayView.h"
#import "YLCoreTextData.h"
#import "UIView+YLFrame.h"

@implementation YLDrawTextPicViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"图文混排";
    //3.
    YLCTDisplayView *displayView1 = [[YLCTDisplayView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, self.view.frame.size.height - 70)];
    [self.view addSubview:displayView1];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"contentStr" ofType:@"json"];
    
    YLCTFrameParserConfig *config1 = [[YLCTFrameParserConfig alloc]init];
    config1.textColor = [UIColor blackColor];
    config1.width = displayView1.width;
    
    YLCoreTextData *data1 = [YLCTFrameParser parseTemplateFile:path config:config1];
    displayView1.data = data1;
    displayView1.height = data1.height;
    displayView1.backgroundColor = [UIColor whiteColor];
}
@end
