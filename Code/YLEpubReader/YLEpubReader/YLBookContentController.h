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
@property (nonatomic, assign, readonly) NSInteger currentColumnIndex;
@property (nonatomic, assign, readonly) NSInteger maxColumnIndex;
@property (nonatomic, assign) BOOL goLastPageWhenFinishLoad;
- (instancetype)initWithHtmlPath:(NSString *)path;
- (void)loadHtmlWithPath:(NSString *)path;
@end
