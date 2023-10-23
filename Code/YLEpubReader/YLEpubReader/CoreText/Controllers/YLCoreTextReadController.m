//
//  YLCoreTextReadController.m
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCoreTextReadController.h"
#import "YLCoreTextContentController.h"
#import "YLEpub.h"
#import "YLStatics.h"
#import "YLCatalogController.h"
#import "YLReadManager.h"
#import "YLEpubChapter.h"
#import "SVProgressHUD.h"

@interface YLCoreTextReadController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) NSUInteger currentChapterIndex;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) UILabel *countLbl;
@end

@implementation YLCoreTextReadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _transitionView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:[CurrentReadBook coverPath]]];
    _transitionView.frame = [UIScreen mainScreen].bounds;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(checkSpine)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    YLCoreTextContentController *readVC = [YLReadManager readViewWithChapter:0 page:0];
    NSArray *controllers = @[readVC];
    
    NSDictionary *options = nil;
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    //UIPageViewController重置数据源animated必须传NO才能清除缓存
    [self.pageViewController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, kStatusBarHeight, kScreenWidth-40, 20)];
    _titleLbl.font = [UIFont systemFontOfSize:12];
    _titleLbl.textColor = [UIColor blackColor];
    [self.view addSubview:_titleLbl];
    
    _countLbl = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-20-150, kScreenHeight-kHomeIndicatorHeight-20, 150, 20)];
    _countLbl.font = [UIFont systemFontOfSize:12];
    _countLbl.textColor = [UIColor blackColor];
    _countLbl.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_countLbl];
    
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    _tapGesture.delegate = self;
    [self.view addGestureRecognizer:_tapGesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark---UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    YLCoreTextContentController *readView = (YLCoreTextContentController *)viewController;
    NSInteger chapter = readView.chapterNum, page = readView.pageNum;
    if(chapter == 0 && page == 0){
        [SVProgressHUD showInfoWithStatus:@"已经是第一页"];
        return nil;
    }
    if(page == 0){
        //本章第一页
        chapter--;
        YLEpubChapter *chapterModel = CurrentReadBook.chapters[chapter];
        if(!chapterModel.pageAttributeStrings){
            [chapterModel paginateEpubWithBounds:[YLReadManager readViewContentFrame]];
        }
        page = chapterModel.pageCount - 1;
    } else {
        page--;
    }
    return [YLReadManager readViewWithChapter:chapter page:page];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    YLCoreTextContentController *readView = (YLCoreTextContentController *)viewController;
    NSInteger chapter = readView.chapterNum, page = readView.pageNum;
    if(chapter == CurrentReadBook.chapters.count - 1 && page == CurrentReadBook.chapters.lastObject.pageCount - 1){
        [SVProgressHUD showInfoWithStatus:@"已经是最后一页"];
        return nil;
    }
    YLEpubChapter *chapterModel = CurrentReadBook.chapters[chapter];
    if(page == chapterModel.pageCount - 1){
        //本章最后一页
        chapter++;
        YLEpubChapter *nChapterModel = CurrentReadBook.chapters[chapter];
        if(!nChapterModel.pageAttributeStrings){
            [nChapterModel paginateEpubWithBounds:[YLReadManager readViewContentFrame]];
        }
        page = 0;
    } else {
        page++;
    }
    return [YLReadManager readViewWithChapter:chapter page:page];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(finished){
        YLCoreTextContentController *readView = (YLCoreTextContentController *)[pageViewController.viewControllers firstObject];
        self.currentChapterIndex = readView.chapterNum;
        YLEpubChapter *chapter = CurrentReadBook.chapters[self.currentChapterIndex];
        _titleLbl.text = chapter.title;
        _countLbl.text = [NSString stringWithFormat:@"%zd/%zd", readView.pageNum+1, chapter.pageCount];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    gesture.enabled = NO;
    [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden];
    gesture.enabled = YES;
}


- (void)checkSpine
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tapGesture.enabled = NO;
    YLCatalogController *catalogVc = [[YLCatalogController alloc]initWithEpub:CurrentReadBook currentCatalogIndex:self.currentChapterIndex];
    __weak typeof(self) weakSelf = self;
    catalogVc.didSelectCatalog = ^(YLEpub *epub, NSUInteger cIndex) {
        YLCoreTextContentController *chapterVc = [YLReadManager readViewWithChapter:cIndex page:0];
        UIPageViewControllerNavigationDirection direction = weakSelf.currentChapterIndex < cIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
        [weakSelf.pageViewController setViewControllers:@[chapterVc] direction:direction animated:YES completion:nil];
    };
    catalogVc.dismissCatalog = ^{
        weakSelf.tapGesture.enabled = YES;
    };
    [catalogVc showInController:self];
}


- (void)dealloc
{
    
}
@end
