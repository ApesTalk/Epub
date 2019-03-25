//
//  YLTextLabelViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/26.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLTextLabelViewController.h"

#import <CoreText/CoreText.h>


@interface YLTextLabelView : UIView

@end

@implementation YLTextLabelView

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //初始化绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //上下翻转绘图上下文的坐标系
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    //创建字符串
    CFStringRef textString = CFSTR("Hello, World!");
    
    NSDictionary *fontAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Courier",(NSString *)kCTFontFamilyNameAttribute,
                                    @"Bold",(NSString *)kCTFontStyleNameAttribute,
                                    [NSNumber numberWithFloat:16.0],(NSString *)kCTFontSizeAttribute, nil];
    //创建字体描述
    CTFontDescriptorRef descriptor = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)fontAttributes);
    
    //使用字体描述创建字体
    CTFontRef font = CTFontCreateWithFontDescriptor(descriptor, 0.0, NULL);
    
    CFStringRef keys[] = {kCTFontAttributeName};
    CFTypeRef values[] = {font};
    
    CFDictionaryRef attributes = CFDictionaryCreate(kCFAllocatorDefault, (const void**)&keys, (const void**)&values, sizeof(keys)/sizeof(keys[0]), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    CFAttributedStringRef attrString = CFAttributedStringCreate(kCFAllocatorDefault, textString, attributes);
    CFRelease(textString);
    CFRelease(attributes);
    CFRelease(font);
    
    //使用CFAttributedString创建CTLine对象
    CTLineRef line = CTLineCreateWithAttributedString(attrString);
    
    //将CTLine绘制到图形上下文的指定位置处
    CGContextSetTextPosition(context, 10.0, 10.0);
    CTLineDraw(line, context);
    
    CFRelease(line);
}

@end


@implementation YLTextLabelViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Simple Text Label";
    
    YLTextLabelView *textLabelView = [[YLTextLabelView alloc]initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 300)];
    textLabelView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textLabelView];
}

@end
