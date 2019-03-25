//
//  YLCTFrameParser.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YLCoreTextData.h"
#import "YLCTFrameParserConfig.h"

@interface YLCTFrameParser : NSObject

+(YLCoreTextData *)parseContent:(NSString *)content
                         config:(YLCTFrameParserConfig *)config;

+(YLCoreTextData *)parseTemplateFile:(NSString *)path
                              config:(YLCTFrameParserConfig *)config;

@end
//用于生成最后绘制界面需要的CTFrameRef实例
