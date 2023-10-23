//
//  YLCoreTextReadController.h
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLCoreTextReadController : YLBaseViewController<CustomTransitionController>
@property (nonatomic, strong) UIView *transitionView;
@end

NS_ASSUME_NONNULL_END
