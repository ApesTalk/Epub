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
#define kIPHONE_XR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIPHONE_XS ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIPHONE_XSMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define kIsX (kIPHONE_XR || kIPHONE_XS || kIPHONE_XSMax)

#define kStatusBarHeight (kIsX ? (20 + 24) : 20)
#define kNavigationBarHeight 44
#define kStatusAndNavigationBarHeight (kStatusBarHeight + kNavigationBarHeight)
#define kTabBarHeight (kIsX ? (49 + 34) : 49)
#define kHomeIndicatorHeight (kIsX ? 34 : 0)
#define kBookContentDiv @"yl_bookcontent"
#define kCSSPaddingLeft 20
#define kCSSPaddingRight 20
#define kCSSPaddingBottom 20
#define kCSSPaddingTop 20

#define kEpubViewBottomGap (kIsX ? 0 : 20)

#define kEpubViewWidth kScreenWidth
#define kEpubViewHeight (kScreenHeight - kStatusAndNavigationBarHeight - kHomeIndicatorHeight - kEpubViewBottomGap)

#define kEpubFontSize 15
#define kEpubFontColor [UIColor blackColor]

#endif /* YLStatics_h */
