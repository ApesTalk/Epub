//
//  YLCoreTextUtils.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/22.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCoreTextUtils.h"
#import "YLCoreTextData.h"
#import "YLCoreTextLinkData.h"

@implementation YLCoreTextUtils
+(YLCoreTextLinkData *)touchLinkInView:(UIView *)view
                               atPoint:(CGPoint)point
                                  data:(YLCoreTextData *)data
{
    CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if(!lines){
        return nil;
    }
    CFIndex count = CFArrayGetCount(lines);
    YLCoreTextLinkData *foundLink = nil;
    
    //获得每一行的orign坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    //翻转坐标系
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    for(NSInteger i = 0; i < count; i++){
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        //获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        if(CGRectContainsPoint(rect, point)){
            //将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x - CGRectGetMinX(rect), point.y - CGRectGetMinY(rect));
            //获得当前点击坐标对应的字符串偏移
            CFIndex idx = CTLineGetStringIndexForPosition(line, relativePoint);
            //判断这个偏移是否在我们的链接列表中
            foundLink = [self linkAtIndex:idx linkArray:data.linkArray];
            return foundLink;
        }
    }
    return nil;
}

+(CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point
{
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = ascent + descent;
    return CGRectMake(point.x, point.y - descent, width, height);
}

+(YLCoreTextLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray
{
    YLCoreTextLinkData *link = nil;
    for(YLCoreTextLinkData *data in linkArray){
        if(NSLocationInRange(i, data.range)){
            link = data;
            break;
        }
    }
    return link;
}

@end
