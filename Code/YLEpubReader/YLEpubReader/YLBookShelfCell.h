//
//  YLBookShelfCell.h
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YLEpub;

@interface YLBookShelfCell : UICollectionViewCell
- (void)loadWithEpub:(YLEpub *)epub;
+ (CGFloat)width;
+ (CGFloat)height;
@end
