//
//  YLColumarLayoutViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/26.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLColumarLayoutViewController.h"

#import <CoreText/CoreText.h>


@interface YLColumnarView : UIView

@end

@implementation YLColumnarView

-(CFArrayRef)createColumnsWithColumnCount:(NSInteger)columnCount
{
    NSInteger column;
    
    CGRect *columnRects = (CGRect *)calloc(columnCount, sizeof(*columnRects));
    
    //设置第一列覆盖整个view
    columnRects[0] = self.bounds;
    
    //将窗体宽平分成宽度相同的列
    CGFloat columnWidth = CGRectGetWidth(self.bounds) / columnCount;
    for(column = 0; column < columnCount - 1; column++){
        //循环切割 该方法的注解见.h
        CGRectDivide(columnRects[column], &columnRects[column], &columnRects[column + 1], columnWidth, CGRectMinXEdge);
    }
    
    //设置偏移量
    for(column = 0; column < columnCount; column++){
        columnRects[column] = CGRectInset(columnRects[column], 8.0, 15.0);
    }
    
    //创建一组布局路径，每个列对应一个路径
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, columnCount, &kCFTypeArrayCallBacks);
    for(column = 0; column < columnCount; column++){
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, columnRects[column]);
        CFArrayInsertValueAtIndex(array, column, path);
        CFRelease(path);
    }
    
    free(columnRects);
    return array;
}

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
    
    //用富文本字符串创建framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    CFRelease(attrString);
    
    //分为3列
    CFArrayRef columnPaths = [self createColumnsWithColumnCount:3];
    
    CFIndex pathCount = CFArrayGetCount(columnPaths);
    CFIndex startIndex = 0;
    NSInteger column;
    
    //为每个列创建一个frame
    for(column = 0; column < pathCount; column++){
        //获得每列的path
        CGPathRef path = (CGPathRef)CFArrayGetValueAtIndex(columnPaths, column);
        
        //创建列对应的frame，并绘制
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
        CTFrameDraw(frame, context);
        
        //在当前frame的第一个不可见的字符处开始下一个frame的绘制
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
    }
    
    CFRelease(columnPaths);
    CFRelease(framesetter);
}

@end


@implementation YLColumarLayoutViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Columnar Layout";
    
    YLColumnarView *columnarView = [[YLColumnarView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 150)];
    columnarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:columnarView];
}

@end
