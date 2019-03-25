//
//  YLCTFrameParser.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCTFrameParser.h"
#import <CoreText/CoreText.h>
#import "YLCoreTextImageData.h"
#import "YLCoreTextLinkData.h"

@implementation YLCTFrameParser

/**生成富文本内容属性*/
+(NSDictionary *)attributesWithConfig:(YLCTFrameParserConfig *)config
{
    CGFloat fontSize = config.fontSize;
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
    CGFloat lineSpace = config.lineSpace;
    const CFIndex kNumberOfSettings = 3;
    CTParagraphStyleSetting theSettings[kNumberOfSettings] = {
        {kCTParagraphStyleSpecifierLineSpacingAdjustment,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing,sizeof(CGFloat),&lineSpace},
        {kCTParagraphStyleSpecifierMinimumLineSpacing,sizeof(CGFloat),&lineSpace}
    };
    
    CTParagraphStyleRef theParagraphRef = CTParagraphStyleCreate(theSettings, kNumberOfSettings);
    
    UIColor *textColor = config.textColor;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[(id)kCTForegroundColorAttributeName] = (id)textColor.CGColor;
    dict[(id)kCTFontAttributeName] = (__bridge id)fontRef;
    dict[(id)kCTParagraphStyleAttributeName] = (__bridge id)theParagraphRef;
    
    CFRelease(theParagraphRef);
    CFRelease(fontRef);
    
    return dict;
}

+(CTFrameRef)createFrameWithFrameSetter:(CTFramesetterRef)framesetter
                                 config:(YLCTFrameParserConfig *)config
                                 height:(CGFloat)height
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0, 0, config.width, height));
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    CFRelease(path);
    return frame;
}

+(YLCoreTextData *)parseContent:(NSString *)content
                         config:(YLCTFrameParserConfig *)config
{
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSAttributedString *contentString = [[NSMutableAttributedString alloc]initWithString:content
                                                                              attributes:attributes];
    
    //创建CTFrameSetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)contentString);
    
    //获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width,CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFrameSetter:framesetter config:config height:textHeight];
    
    //将生成好的CTFrameRef实例和计算好的绘制高度保存到YLCoreTextData实例中，最后返回YLCoreTextData实例
    YLCoreTextData *data = [[YLCoreTextData alloc]init];
    data.ctFrame = frame;
    data.height = textHeight;
    
    //释放
    CFRelease(frame);
    CFRelease(framesetter);
    
    return data;
}


//加载并解析约定好的json格式的数据并生成显示样式
//用于提供对外的接口
+(YLCoreTextData *)parseTemplateFile:(NSString *)path
                              config:(YLCTFrameParserConfig *)config
{
    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *linkArray = [NSMutableArray array];
    NSAttributedString *content = [self loadTemplateFile:path config:config imageArray:imageArray linkArray:linkArray];
    YLCoreTextData *data = [self parseAttributedContent:content cofig:config];
    data.imageArray = imageArray;
    data.linkArray = linkArray;
    return data;
}

//实现从一个JSON的模板文件中读取内容
+(NSAttributedString *)loadTemplateFile:(NSString *)path
                                 config:(YLCTFrameParserConfig *)config
                             imageArray:(NSMutableArray *)imageArray
                              linkArray:(NSMutableArray *)linkArray
{
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]init];
    if(data){
        NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingAllowFragments
                                                           error:nil];
        if([array isKindOfClass:[NSArray class]]){
            for(NSDictionary *dict in array){
                NSString *type = dict[@"type"];
                if([type isEqualToString:@"txt"]){
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                }else if ([type isEqualToString:@"img"]){
                    //创建YLCoreTextImageData
                    YLCoreTextImageData *imageData = [[YLCoreTextImageData alloc]init];
                    imageData.name = dict[@"name"];
                    imageData.position = [result length];
                    [imageArray addObject:imageData];
                    //创建空白占位符，并且设置它的CTRunDelegate信息
                    NSAttributedString *as = [self parseImageDataFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                }else if([type isEqualToString:@"link"]){
                    NSUInteger startPos = result.length;
                    NSAttributedString *as = [self parseAttributedContentFromNSDictionary:dict config:config];
                    [result appendAttributedString:as];
                    //创建YLCoreTextLinkData
                    NSUInteger length = result.length - startPos;
                    NSRange linkRange = NSMakeRange(startPos, length);
                    YLCoreTextLinkData *linkData = [[YLCoreTextLinkData alloc]init];
                    linkData.title = dict[@"content"];
                    linkData.url = dict[@"url"];
                    linkData.range = linkRange;
                    [linkArray addObject:linkData];
                }
            }
        }
    }
    return result;
}

//将NSDictionary内容转换成为NSAttributedString
+(NSAttributedString *)parseAttributedContentFromNSDictionary:(NSDictionary *)dict
                                                       config:(YLCTFrameParserConfig *)config
{
    NSMutableDictionary *attributes = [[self attributesWithConfig:config]mutableCopy];
    //设置颜色
    UIColor *color = [self colorFromTemplate:dict[@"color"]];
    if(color){
        attributes[(id)kCTForegroundColorAttributeName] = (id)color.CGColor;
    }
    //设置字体
    CGFloat fontSize = [dict[@"size"]floatValue];
    if(fontSize){
        CTFontRef fontRef = CTFontCreateWithName((CFStringRef)@"ArialMT", fontSize, NULL);
        attributes[(id)kCTFontAttributeName] = (__bridge id)fontRef;
        CFRelease(fontRef);
    }
    NSString *content = dict[@"content"];
    return [[NSAttributedString alloc]initWithString:content attributes:attributes];
}

static CGFloat ascendCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary*)ref objectForKey:@"height"]floatValue];
}

static CGFloat descentCallback(void *ref){
    return 0;
}

static CGFloat widthCallback(void *ref){
    return [(NSNumber *)[(__bridge NSDictionary*)ref objectForKey:@"width"]floatValue];
}

+(NSAttributedString *)parseImageDataFromNSDictionary:(NSDictionary *)dict
                                               config:(YLCTFrameParserConfig *)config
{
    CTRunDelegateCallbacks callbacks;
    //void	*memset(void *, int, size_t)函数，将指定内存的前size_t个字节设置为特定的int值，并返回字符串地址
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.getAscent = ascendCallback;
    callbacks.getDescent = descentCallback;
    callbacks.getWidth = widthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge void*)(dict));
    //使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString *content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    NSDictionary *attributes = [self attributesWithConfig:config];
    NSMutableAttributedString *space = [[NSMutableAttributedString alloc]initWithString:content attributes:attributes];
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1), kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    return space;
}

//提供将NSString转换为UIColor
+(UIColor *)colorFromTemplate:(NSString *)name
{
    if([name isEqualToString:@"blue"]){
        return [UIColor blueColor];
    }else if ([name isEqualToString:@"red"]){
        return [UIColor redColor];
    }else if ([name isEqualToString:@"black"]){
        return [UIColor blackColor];
    }else{
        return nil;
    }
}

//辅助函数
+(YLCoreTextData *)parseAttributedContent:(NSAttributedString *)content
                                    cofig:(YLCTFrameParserConfig *)config
{
    //创建CTFrameSetterRef实例
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)content);
    
    //获得要绘制的区域的高度
    CGSize restrictSize = CGSizeMake(config.width, CGFLOAT_MAX);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, restrictSize, nil);
    CGFloat textHeight = coreTextSize.height;
    
    //生成CTFrameRef实例
    CTFrameRef frame = [self createFrameWithFrameSetter:framesetter config:config height:textHeight];
    
    //将生成好的CTFrameRef实例和计算好的绘制高度保存到YLCoreTextData实例中
    YLCoreTextData *data = [[YLCoreTextData alloc]init];
    data.ctFrame = frame;
    data.height = textHeight;
    
    //释放
    CFRelease(frame);
    CFRelease(framesetter);

    return data;
}


@end
