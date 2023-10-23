//
//  YLCoreTextReadView.h
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YLCoreTextReadView : UIView
- (instancetype)initWithFrame:(CGRect)frame chapterNum:(NSInteger)chapterNum pageNum:(NSInteger)pageNum;

@end

NS_ASSUME_NONNULL_END
