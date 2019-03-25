//
//  YLCTDisplayView.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCTDisplayView.h"
#import "YLCoreTextImageData.h"
#import "YLCoreTextLinkData.h"
#import "YLCoreTextUtils.h"

@interface YLCTDisplayView ()<UIGestureRecognizerDelegate>

@end

@implementation YLCTDisplayView
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self setupEvents];
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    //获得当前绘图上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //将UIKit的坐标系翻转
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //绘制文字
    if(self.data){
        CTFrameDraw(self.data.ctFrame, context);
    }
    
    //绘制图片
    for (YLCoreTextImageData *imageData in self.data.imageArray) {
        UIImage *image = [UIImage imageNamed:imageData.name];
        if(image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
}

-(void)setupEvents
{
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(userTapGestureDetected:)];
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    self.userInteractionEnabled = YES;
}


-(void)userTapGestureDetected:(UIGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
    for(YLCoreTextImageData *imageData in self.data.imageArray){
        //翻转坐标系，因为imageData中的坐标系是CoreText的坐标系
        CGRect imageRect = imageData.imagePosition;
        CGPoint imagePosition = imageRect.origin;
        imagePosition.y = self.bounds.size.height - imageRect.origin.y - imageRect.size.height;
        CGRect rect = CGRectMake(imagePosition.x, imagePosition.y, imageRect.size.width, imageRect.size.height);
        //检测点击位置point是否在rect之内
        if(CGRectContainsPoint(rect, point)){
            //在这里处理点击后的逻辑
            NSLog(@"点击了图片");
            break;
        }
        
    }
    
    YLCoreTextLinkData *linkData = [YLCoreTextUtils touchLinkInView:self atPoint:point data:self.data];
    if(linkData){
        NSLog(@"点击链接：%@",linkData.url);
    }
}





























@end
