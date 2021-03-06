//
//  YLBookContentController.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBaseViewController.h"
@class YLEpubChapter;

typedef NS_ENUM(NSInteger, ChapterLoadStatus) {
    ChapterLoadStatusIdle,///< 闲置状态
    ChapterLoadStatusLoading,///< 加载中
    ChapterLoadStatusSuccess,///< 加载完成 -> 成功
    ChapterLoadStatusError,///< 加载完成 -> 失败
};

@class YLBookContentController;
@protocol BookControllerDelegate <NSObject>

- (void)contentController:(YLBookContentController *)vc shouldDirect:(UIPageViewControllerNavigationDirection)direction;

@end



@interface YLBookContentController : YLBaseViewController
@property (nonatomic, strong) YLEpubChapter *chapter;
@property (nonatomic, copy) NSString *bookPath;

@property (nonatomic, assign, readonly) NSInteger currentColumnIndex;
@property (nonatomic, assign, readonly) NSInteger maxColumnIndex;
@property (nonatomic, assign, readonly) ChapterLoadStatus loadStatus;
@property (nonatomic, assign) BOOL goLastPageWhenFinishLoad;
@property (nonatomic, weak) id<BookControllerDelegate> delegate;

//- (instancetype)initWithHtmlPath:(NSString *)path title:(NSString *)title;
- (instancetype)initWithChapter:(YLEpubChapter *)chapter bookPath:(NSString *)bookPath;
//- (void)loadHtmlWithPath:(NSString *)path;
- (void)scrollToPageIndex:(NSInteger)page;
@end
