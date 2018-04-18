//
//  YLBookContentController.h
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLBaseViewController.h"

@interface YLBookContentController : YLBaseViewController
@property (nonatomic, assign) NSInteger chapterIndex;///< 章节索引
- (instancetype)initWithHtmlPath:(NSString *)path;
@end
