//
//  YLReadManager.h
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class YLEpub;
@class YLCoreTextContentController;

NS_ASSUME_NONNULL_BEGIN

#define CurrentReadBook [YLReadManager shareManager].bookModel


@interface YLReadManager : NSObject
+ (instancetype)shareManager;

+ (CGRect)readViewFrame;
+ (UIEdgeInsets)readViewEdgeInsets;
+ (CGRect)readViewContentFrame;

@property (nonatomic,strong) YLEpub *bookModel;
//@property (nonatomic,weak) id<XDSReadManagerDelegate> rmDelegate;

//获取对于章节页码的radViewController
+ (YLCoreTextContentController *)readViewWithChapter:(NSInteger)chapter page:(NSInteger)page;

- (void)readViewJumpToChapter:(NSInteger)chapter page:(NSInteger)page;//跳转到指定章节（上一章，下一章，slider，目录）
//- (void)readViewJumpToNote:(XDSNoteModel *)note;//跳转到指定笔记，因为是笔记是基于位置查找的，使用page查找可能出错
//- (void)readViewJumpToMark:(XDSMarkModel *)mark;//跳转到指定书签，因为是书签是基于位置查找的，使用page查找可能出错
- (void)configReadFontSize:(BOOL)plus;//设置字体大小;
- (void)configReadFontName:(NSString *)fontName;//设置字体;

- (void)configReadTheme:(UIColor *)theme;//设置阅读背景
- (void)updateReadModelWithChapter:(NSInteger)chapter page:(NSInteger)page;//更新阅读记录
- (void)closeReadView;//关闭阅读器
//- (void)addBookMark;//添加或删除书签
//- (void)addNoteModel:(XDSNoteModel *)noteModel;//添加笔记

@end

NS_ASSUME_NONNULL_END
