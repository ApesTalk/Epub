//
//  YLDrawTextView.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLDrawTextView.h"
#import <CoreText/CoreText.h>

@implementation YLDrawTextView
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //1.获得当前绘制画布的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //2.坐标系上下翻转，对于底层的绘制引擎来说，屏幕的左下角是(0,0)，而对于上层的UIKit来说，左上角是(0,0)
    //为了之后的坐标系描述按UIKit来做，需要在这里先上下翻转。翻转之后底层和上层的(0,0)左边就重合了。
    //代码注掉，将会从view的左下角开始绘制文字，并且文字是上下翻转的。
    //固定写法
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置文本矩阵
    CGContextTranslateCTM(context, 0, self.bounds.size.height);//沿Y轴向上平移
    CGContextScaleCTM(context, 1.0, -1.0);//缩放
    
    //3.创建绘制的区域。CoreText本身支持各种文字排版的区域，我们这里简单地将UIView的整个界面作为排版的区域。
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    //4.
    NSAttributedString *attString = [[NSAttributedString alloc]initWithString:@"Hello world!"
                                     "创建绘制的区域，CoreText本身支持各种文字排版的区域，"
                                     "我们这里简单地将UIView的整个界面作为排版的区域。"
                                     "为了加深理解，建议读者将该步骤的代码替换为如下代码，"
                                     "测试设置不同的绘制区域带来的界面变化。"];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
    
    //5.
    CTFrameDraw(frame, context);
    
    //6.
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}
@end
