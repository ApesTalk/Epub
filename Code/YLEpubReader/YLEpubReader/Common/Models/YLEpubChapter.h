//
//  YLEpubChapter.h
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLEpubChapter : NSObject
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *path;///< 非完整路径，完整路径需在前面拼接opsPath
@property (nonatomic, strong) YLEpubChapter *preChapter;
@property (nonatomic, strong) YLEpubChapter *nextChapter;

@property (nonatomic, strong, readonly) NSAttributedString *chapterAttributeContent;///全章的富文本
@property (nonatomic, copy, readonly) NSString *chapterContent;//全章的out文本
@property (nonatomic, copy, readonly) NSArray *pageAttributeStrings;//每一页的富文本
@property (nonatomic, copy, readonly) NSArray *pageStrings;//每一页的普通文本
@property (nonatomic, copy, readonly) NSArray *pageLocations;//每一页在章节中的位置
@property (nonatomic, assign, readonly) NSInteger pageCount;//章节总页数

- (void)paginateEpubWithBounds:(CGRect)bounds;

@end

NS_ASSUME_NONNULL_END
