//
//  YLDisplayInNonrectViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/27.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLDisplayInNonrectViewController.h"

#import <CoreText/CoreText.h>


@interface YLNonRectView : UIView

@end

@implementation YLNonRectView
//创建一个原环形的绘图区域
static void AddSquashedDonutPath(CGMutablePathRef path, const CGAffineTransform *m, CGRect rect)
{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    
    CGFloat radiusH = width / 3.0;
    CGFloat radiusV = height / 3.0;
    
    //坐标系是反着的
    
    //点移动到初始位置
    CGPathMoveToPoint(path, m, rect.origin.x, rect.origin.y + height - radiusV);//C
    //添加二次曲线 cpx cpy是控制点 会将当前点移动到x,y点处
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x, rect.origin.y + height,
                              rect.origin.x + radiusH, rect.origin.y + height);//以A为控制点 从C到I画弧线
    CGPathAddLineToPoint(path, m, rect.origin.x + width - radiusH, rect.origin.y + height);//从I到J画直线
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x + width, rect.origin.y + height,
                              rect.origin.x + width, rect.origin.y + height - radiusV);//以B为控制点，从J到D画弧线
    
    CGPathAddLineToPoint(path, m, rect.origin.x + width, rect.origin.y + radiusV);//从D到F画直线
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x + width, rect.origin.y,
                              rect.origin.x + width - radiusH, rect.origin.y);//以H为控制点，从F到L画曲线
    CGPathAddLineToPoint(path, m, rect.origin.x + radiusH, rect.origin.y);//从L到K画直线
    CGPathAddQuadCurveToPoint(path, m, rect.origin.x, rect.origin.y,
                              rect.origin.x, rect.origin.y + radiusV);//以G为控制点，从K到E画曲线
    CGPathCloseSubpath(path);//从E到C画直线，结束绘图
    
    CGPathAddEllipseInRect(path, m, CGRectMake(rect.origin.x + width / 2.0 - width / 5.0,
                                               rect.origin.y + height / 2.0 - height / 5.0,
                                               width / 5.0 * 2.0,
                                               height / 5.0 * 2.0));//在中心处画椭圆
    
    /*
     A----------I----------J----------B
     |                                |
     |                                |
     |                                |
     |                                |
     |                                |
     C                                D
     |                                |
     |                                |
     |                                |
     |                                |
     |                                |
     E                                F
     |                                |
     |                                |
     |                                |
     |                                |
     |                                |
     G----------K----------L----------H
     */
}

//在drawRect方法外面生成绘图路径，所以路径只会计算一次
-(NSArray *)paths
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, 10.0, 10.0);
    AddSquashedDonutPath(path, NULL, bounds);
    
    NSMutableArray *result = [NSMutableArray arrayWithObjects:CFBridgingRelease(path), nil];
    return result;
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
    
    CFStringRef textString = CFSTR("Hello, World! I know nothing in the world that has as much power as a world. "
                               "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   "Sometimes I write one, and I look at it, until it begins to shine."
                                   "Hello, World! I know nothing in the world that has as much power as a world. "
                                   );
    
    //创建富文本
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    //复制textString到富文本中
    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), textString);
    
    //创建颜色
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {1.0, 0.0, 0.0, 0.8};
    CGColorRef red = CGColorCreate(rgbColorSpace, components);
    CGColorSpaceRelease(rgbColorSpace);
    
    //设置前13个字符颜色
    CFAttributedStringSetAttribute(attrString, CFRangeMake(0, 13), kCTForegroundColorAttributeName, red);
    
    //创建framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
    
    //创建绘图路径数组
    NSArray *paths = [self paths];
    
    CFIndex startIndex = 0;
    
#define GREEN_COLOR [UIColor greenColor]
#define YELLOW_COLOR [UIColor yellowColor]
#define BLACK_COLOR [UIColor blackColor]
    
    for(id object in paths){
        CGPathRef path = (__bridge CGPathRef)object;
        
        //设置路径背景色为黄色
        CGContextSetFillColorWithColor(context, YELLOW_COLOR.CGColor);
        
        CGContextAddPath(context, path);
        CGContextFillPath(context);

        CGContextDrawPath(context, kCGPathStroke);
        
        //创建frame
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
        CTFrameDraw(frame, context);
        
        //在当前frame的第一个看不到的字符处开始下一个frame
        CFRange frameRange = CTFrameGetVisibleStringRange(frame);
        startIndex += frameRange.length;
        CFRelease(frame);
    }
    CFRelease(attrString);
    CFRelease(framesetter);
}

@end


@implementation YLDisplayInNonrectViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Display Text in a Nonrectangular Region";
    
    YLNonRectView *nonRectView = [[YLNonRectView alloc]initWithFrame:CGRectMake(0, 70, 300, 300)];
    nonRectView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nonRectView];
}

@end
