//
//  YLCoreTextContentController.h
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBaseViewController.h"
#import "YLCoreTextReadView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YLCoreTextContentController : YLBaseViewController
@property (nonatomic, strong) YLCoreTextReadView *readView;

@property (nonatomic, assign) NSInteger chapterNum;
@property (nonatomic, assign) NSInteger pageNum;
//@property (nonatomic, copy) NSString *pageUrl;

- (instancetype)initWithChapterNum:(NSInteger)chapterNum pageNum:(NSInteger)pageNum;

@end

NS_ASSUME_NONNULL_END
