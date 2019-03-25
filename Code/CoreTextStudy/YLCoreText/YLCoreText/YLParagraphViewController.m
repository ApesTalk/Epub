//
//  YLParagraphViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/26.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLParagraphViewController.h"
#import <CoreText/CoreText.h>


@interface YLParagraphView : UIView

@end

@implementation YLParagraphView

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
    
    //创建绘图路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGRect bounds = CGRectMake(10.0, 10.0, self.bounds.size.width - 20, self.bounds.size.height - 20);
    CGPathAddRect(path, NULL, bounds);
    
    //创建字符串
    CFStringRef textString = CFSTR("Hello, World! I know nothing in the world that has as much power as a word."
                                   "Sometiems I write one, and I look at it, until it begins to shine.");
    
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
    
    //用富文本字符串创建framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    //创建frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    //将制定frame绘制到图形上下文
    CTFrameDraw(frame, context);
    
    //释放对象
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end


@implementation YLParagraphViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Laying Out a Paragraph";
    
    YLParagraphView *paragraphView = [[YLParagraphView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 300)];
    paragraphView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:paragraphView];
}

@end


