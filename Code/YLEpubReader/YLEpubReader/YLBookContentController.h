//
//  YLBookContentController.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBaseViewController.h"

typedef NS_ENUM(NSInteger, YLWebLoadStatus) {
    YLWebLoadStatusIdle,///< 闲置状态
    YLWebLoadStatusLoading,///< 加载中
    YLWebLoadStatusLoadFinish,///< 加载完成，成功或失败
};

@interface YLBookContentController : YLBaseViewController
@property (nonatomic, assign) NSInteger chapterIndex;///< 章节索引
@property (nonatomic, assign, readonly) NSInteger currentColumnIndex;
@property (nonatomic, assign, readonly) NSInteger maxColumnIndex;
@property (nonatomic, assign, readonly) YLWebLoadStatus loadStatus;
@property (nonatomic, assign) BOOL goLastPageWhenFinishLoad;
- (instancetype)initWithHtmlPath:(NSString *)path;
- (void)loadHtmlWithPath:(NSString *)path;
- (void)scrollToPageIndex:(NSInteger)page;
@end
