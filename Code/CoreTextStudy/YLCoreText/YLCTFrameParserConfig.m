//
//  YLCTFrameParserConfig.m
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCTFrameParserConfig.h"

@implementation YLCTFrameParserConfig
-(instancetype)init
{
    if(self = [super init]){
        _width = 200.f;
        _fontSize = 16.0f;
        _lineSpace = 8.0f;
        _textColor = [UIColor colorWithRed:105/255.0 green:105/255.0 blue:105/255.0 alpha:1];
    }
    return self;
}

@end
