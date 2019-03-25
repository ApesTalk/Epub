//
//  YLManualLineBreakingController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/26.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLManualLineBreakingController.h"

#import <CoreText/CoreText.h>


@interface YLManualView : UIView

@end

@implementation YLManualView
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //初始化绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //上下翻转绘图上下文的坐标系
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    //设置矩阵
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    double width = 300;//行宽
    CGPoint textPosition = CGPointMake(10, 400);
    
    //创建字符串
    CFStringRef textString = CFSTR("Hello, World! I know nothing in the world that has as much power as a word."
                                   "Sometiems I write one, and I look at it, until it begins to shine."
                                   "巴拉巴拉巴拉巴拉巴拉撒客服和康师傅喊口号分开后首付款后法兰克和金额晚礼服可好看了解分红看上"
                                   "和首付款哈萨克立法会上客服两会上客服哈萨克分哈克斯拉夫哈市了客服哈萨克分哈萨克龙卷风哈萨克龙");
    
    //创建可变富文本字符串 0 表示不限制
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    //将textString复制到attrString中
    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), textString);
    
    //创建富文本的颜色
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.0, 0.0, 0.8};
    CGColorRef red = CGColorCreate(rgbColorSpace, components);
    CGColorSpaceRelease(rgbColorSpace);
    
    //设置前12个字符的颜色为红色
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 12), kCTForegroundColorAttributeName, red);
    
    //使用富文本字符串创建一个typesetter
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(attrString);
    
    //从字符串开头到给定宽度寻找换行点
    CFIndex start = 0;
    for(NSInteger i = 0; i < 15; i++){
        CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, width);
        
        //使用返回的要断点的字符长度来创建行对象
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));
        
        //获取将行居中需要的偏移量
        float flush = 0.5;//居中
        double penOffset = CTLineGetPenOffsetForFlush(line, flush, width);
        
        //将给定的文本绘制位置按照计算结果偏移并绘制行
        CGContextSetTextPosition(context, textPosition.x + penOffset, textPosition.y);
        CTLineDraw(line, context);
        
        //将索引超出换行符的位置
        start += count;
        textPosition.y -= CTLineGetBoundsWithOptions(line, kCTLineBoundsExcludeTypographicLeading).size.height;
    }
    
}

@end


@implementation YLManualLineBreakingController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Manual Line Breaking";
    
    YLManualView *manualView = [[YLManualView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 500)];
    manualView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:manualView];
}

@end

