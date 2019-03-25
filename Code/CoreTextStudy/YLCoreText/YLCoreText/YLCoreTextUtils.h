//
//  YLCoreTextUtils.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/22.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@class YLCoreTextLinkData;
@class YLCoreTextData;

@interface YLCoreTextUtils : NSObject
+(YLCoreTextLinkData *)touchLinkInView:(UIView *)view
                               atPoint:(CGPoint)point
                                  data:(YLCoreTextData *)data;
@end
//专门用来检测用户点击的是否在链接上的工具类
