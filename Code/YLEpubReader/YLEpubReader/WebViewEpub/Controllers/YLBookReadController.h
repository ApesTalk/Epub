//
//  YLBookReadController.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBaseViewController.h"
@class YLEpub;

@interface YLBookReadController : YLBaseViewController<CustomTransitionController>
@property (nonatomic, strong) UIView *transitionView;
- (instancetype)initWithEpub:(YLEpub *)epub;
@end
