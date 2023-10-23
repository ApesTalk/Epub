//
//  YLCoreTextContentController.m
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCoreTextContentController.h"
#import "YLEpub.h"
#import "YLReadManager.h"

@interface YLCoreTextContentController ()
@end

@implementation YLCoreTextContentController

- (instancetype)initWithChapterNum:(NSInteger)chapterNum pageNum:(NSInteger)pageNum {
    if (self = [super init]) {
        self.chapterNum = chapterNum;
        self.pageNum = pageNum;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    CGRect frame = [YLReadManager readViewFrame];
    self.readView = [[YLCoreTextReadView alloc] initWithFrame:frame chapterNum:self.chapterNum pageNum:self.pageNum];
    self.readView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.readView];
}

@end
