//
//  YLCatalogController.h
//  YLEpubReader
//
//  Created by ApesTalk on 2019/3/25.
//  Copyright © 2019年 https://github.com/ApesTalk. All rights reserved.
//  目录

#import "YLBaseViewController.h"
@class YLEpub;

@interface YLCatalogController : YLBaseViewController
@property (nonatomic, copy) void (^dismissCatalog)(void);
@property (nonatomic, copy) void (^didSelectCatalog)(YLEpub *epub, NSUInteger cIndex);
- (instancetype)initWithEpub:(YLEpub *)epub currentCatalogIndex:(NSUInteger)cIndex;
- (void)showInController:(UIViewController *)controller;
@end
