//
//  YLCTFrameParserConfig.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface YLCTFrameParserConfig : NSObject
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat fontSize;
@property(nonatomic,assign)CGFloat lineSpace;
@property(nonatomic,assign)UIColor *textColor;

@end
//用户配置绘制的参数，例如文字颜色，大小，行间距等。
