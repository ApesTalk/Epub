//
//  YLStatics.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#ifndef YLStatics_h
#define YLStatics_h

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define ISIPHONEX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kStatusBarHeight (ISIPHONEX ? (20.f + 24.f) : 20.f)
#define kNavigationBarHeight 44.f
#define kStatusAndNavigationBarHeight (kStatusBarHeight + kNavigationBarHeight)
#define kTabBarHeight (ISIPHONEX ? (49.f + 34.f) : 49.f)
#define kHomeIndicatorHeight (ISIPHONEX ? 34.f : 0.f)
#define kBookContentDiv @"yl_bookcontent"
#define kCSSPaddingLeft 20
#define kCSSPaddingRight 20

#endif /* YLStatics_h */
