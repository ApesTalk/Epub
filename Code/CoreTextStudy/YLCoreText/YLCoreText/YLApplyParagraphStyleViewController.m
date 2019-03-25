//
//  YLApplyParagraphStyleViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/27.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLApplyParagraphStyleViewController.h"

#import <CoreText/CoreText.h>


NSAttributedString *applyParaStyle(CFStringRef fontName, CGFloat pointSize, NSString *plainText, CGFloat lineSpaceInc){
    //创建字体，以便我们可以确定其高度
    CTFontRef font = CTFontCreateWithName(fontName, pointSize, NULL);
    
    //设置行间距
    CGFloat lineSpacing = (CTFontGetLeading(font) + lineSpaceInc) * 2;
    
    //创建段落样式设置
    CTParagraphStyleSetting setting;
    
    setting.spec = kCTParagraphStyleSpecifierLineSpacing;
    setting.valueSize = sizeof(CGFloat);
    setting.value = &lineSpacing;
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(&setting, 1);
    
    //添加段落样式到字典中
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                (__bridge id)font, (id)kCTFontNameAttribute,
                                (__bridge id)paragraphStyle, (id)kCTParagraphStyleAttributeName, nil];
    CFRelease(font);
    CFRelease(paragraphStyle);
    
    //添加段落样式到字符串来创建富文本字符串
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:(NSString *)plainText attributes:attributes];
    return attrString;
}

@interface YLApplyParagraphView : UIView

@end

@implementation YLApplyParagraphView

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
    
    CFStringRef fontName = CFSTR("Courier");
    CGFloat pointSize = 24.0;
    
    CFStringRef string = CFSTR("Hello, World! I know nothing in the world that has as much power as a world. "
                               "Sometimes I write one, and I look at it, until it begins to shine.");
    
    //应用段落样式
    NSAttributedString *attrString = applyParaStyle(fontName, pointSize, (__bridge NSString *)(string), 50.0);
    
    //将富文本字符串和应用的段落样式添加到framesetter中
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    //创建绘图路径
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    
    //创建一个将要绘制的frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    //绘制frame
    CTFrameDraw(frame, context);
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

@end


@implementation YLApplyParagraphStyleViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Applying a Paragraph Style";
    
    YLApplyParagraphView *paragraphView = [[YLApplyParagraphView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 500)];
    paragraphView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:paragraphView];
}

@end
