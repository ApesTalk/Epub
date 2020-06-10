//
//  YLFlipPushTransition.h
//  YLEpubReader
//
//  Created by ApesTalk on 2020/6/10.
//  Copyright © 2020 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YLFlipPushTransition : NSObject<UIViewControllerAnimatedTransitioning>
- (instancetype)initWithFromView:(UIView *)fromView toView:(UIView *)toView;
@end

