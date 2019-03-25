//
//  YLCoreTextData.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCoreTextData.h"
#import "YLCoreTextImageData.h"

@implementation YLCoreTextData
-(void)setCtFrame:(CTFrameRef)ctFrame
{
    if(_ctFrame != ctFrame){
        if(_ctFrame != nil){
            CFRelease(_ctFrame);
        }
        CFRetain(ctFrame);
        _ctFrame = ctFrame;
    }
}

-(void)setImageArray:(NSArray *)imageArray
{
    _imageArray = imageArray;
    [self fillImagePosition];
}

-(void)fillImagePosition
{
    if(self.imageArray.count==0){
        return;
    }
    //获得指定frame中的所有行对象数组
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    NSUInteger lineCount = lines.count;
    //起点坐标数组
    CGPoint lineOrigins[lineCount];
    //获得每行的起点坐标
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    NSInteger imgIndex = 0;
    YLCoreTextImageData *imageData = self.imageArray[0];
    for(NSInteger i = 0; i < lineCount; i++){
        if(imageData == nil){
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];//获得行对象
        NSArray *runObjArray = (NSArray *)CTLineGetGlyphRuns(line);//获得一行中的CTRun对象数组
        for(id runObj in runObjArray){
            CTRunRef run = (__bridge CTRunRef)runObj;//获得CTRun对象
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);//获得CTRun对象的属性
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            if(delegate == nil){
                continue;
            }
            NSDictionary *metaDic = CTRunDelegateGetRefCon(delegate);
            if(![metaDic isKindOfClass:[NSDictionary class]]){
                continue;
            }
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL);//获得CTRun的宽度
            runBounds.size.height = ascent + descent;
            
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y -= descent;
            
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imagePosition = delegateBounds;
            imgIndex++;
            if(imgIndex == self.imageArray.count){
                imageData = nil;
                break;
            }else{
                imageData = self.imageArray[imgIndex];
            }
        }
    }
}

-(void)dealloc
{
    if(_ctFrame != nil){
        CFRelease(_ctFrame);
        _ctFrame = nil;
    }
}

@end
