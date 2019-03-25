//
//  YLBookReadController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBookReadController.h"
#import "YLBookContentController.h"
#import "YLEpub.h"
#import "YLStatics.h"
#import "YLCatalogController.h"


@interface YLBookReadController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) YLEpub *epub;
@property (nonatomic, assign) NSUInteger currentChapterIndex;
@end

@implementation YLBookReadController
- (instancetype)initWithEpub:(YLEpub *)epub
{
    if(self = [super init]){
        _epub = epub;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(checkSpine)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    NSArray *controllers = @[[self controllerForIndex:0]];
    
    //UIPageViewControllerOptionSpineLocationKey 书脊位置
    //UIPageViewControllerOptionInterPageSpacingKey 针对水平滚动时页面之间的间距
    //    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMax),
    //                              UIPageViewControllerOptionInterPageSpacingKey:@(10),
    //                              };
    NSDictionary *options = nil;
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];

//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.backgroundColor = [UIColor redColor];
//    leftBtn.frame = CGRectMake(0, (kScreenHeight - 50) * 0.5, 50, 50);
//    [leftBtn addTarget:self action:@selector(pre) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:leftBtn];
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.backgroundColor = [UIColor redColor];
//    rightBtn.frame = CGRectMake(kScreenWidth - 50, (kScreenHeight - 50) * 0.5, 50, 50);
//    [rightBtn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:rightBtn];
    
    //UIPageViewController重置数据源animated必须传NO才能清除缓存
    [_pageViewController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //UIPageViewControllerTransitionStyleScroll类型的无手势，UIPageViewControllerTransitionStylePageCurl类型的有pan和tap手势
    if(_pageViewController.transitionStyle == UIPageViewControllerTransitionStylePageCurl){
        for(UIGestureRecognizer *gesture in _pageViewController.gestureRecognizers){
            gesture.delegate = self;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)pre
{
    YLBookContentController *currentChapterVc = (YLBookContentController *)_pageViewController.viewControllers[0];
    NSInteger index = currentChapterVc.chapterIndex;
    if(index != NSNotFound && index - 1 >= 0){
        YLBookContentController *preChapterVc = [self controllerForIndex:index - 1];
        preChapterVc.goLastPageWhenFinishLoad = YES;
        [_pageViewController setViewControllers:@[preChapterVc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
}

- (void)next
{
    YLBookContentController *currentChapterVc = (YLBookContentController *)_pageViewController.viewControllers[0];
    NSInteger index = currentChapterVc.chapterIndex;
    if(index != NSNotFound && index + 1 < _epub.spine.count){
        YLBookContentController *nextChapterVC = [self controllerForIndex:index + 1];
        [_pageViewController setViewControllers:@[nextChapterVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
}


#pragma mark---UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    YLBookContentController *currentChapterVc = (YLBookContentController *)viewController;
    if(currentChapterVc.currentColumnIndex == 0){
        NSInteger index = currentChapterVc.chapterIndex;
        if(index != NSNotFound && index - 1 >= 0){
            YLBookContentController *preChapterVc = [self controllerForIndex:index - 1];
            preChapterVc.goLastPageWhenFinishLoad = YES;
            return preChapterVc;
        }
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    YLBookContentController *currentChapterVc = (YLBookContentController *)viewController;
    if(currentChapterVc.currentColumnIndex == currentChapterVc.maxColumnIndex){
        NSInteger index = currentChapterVc.chapterIndex;
        if(index != NSNotFound && index + 1 < _epub.spine.count){
            return [self controllerForIndex:index + 1];
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if(finished){
        YLBookContentController *vc = (YLBookContentController *)[pageViewController.viewControllers firstObject];
        _currentChapterIndex = vc.chapterIndex;
    }
}

#pragma mark---other methods
- (YLBookContentController *)controllerForIndex:(NSInteger)index
{
    if(index < 0 || index > _epub.spine.count){
        return nil;
    }
    //create a new vc
    NSString *idref = [_epub.spine objectAtIndex:index];
    NSString *href = [_epub.mainifest objectForKey:idref];
    self.title = href;
    NSString *htmlPath = [NSString stringWithFormat:@"%@%@", _epub.opsPath, href];
//    YLBookContentController *contentVc = [[YLBookContentController alloc]initWithHtmlPath:htmlPath];
    YLBookContentController *contentVc = [[YLBookContentController alloc]init];
    [contentVc loadHtmlWithPath:htmlPath];
    contentVc.chapterIndex = index;
    
    return contentVc;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    YLBookContentController *currentChapterVc = (YLBookContentController *)[_pageViewController viewControllers][0];
    NSInteger currentIndex = currentChapterVc.currentColumnIndex;
    NSInteger maxIndex = currentChapterVc.maxColumnIndex;
    YLWebLoadStatus status = currentChapterVc.loadStatus;
    if(status != YLWebLoadStatusLoadFinish){
        currentChapterVc.view.userInteractionEnabled = NO;
        return NO;
    }
    if(currentIndex == 0){
        //left Reverse
        if(currentChapterVc.chapterIndex > 0 && [touch locationInView:self.view].x < kScreenWidth * 0.5){
            currentChapterVc.view.userInteractionEnabled = NO;
            return YES;
        }
    }
    if (currentChapterVc.chapterIndex < _epub.spine.count - 1 && currentIndex == maxIndex){
        //right Forward
        if([touch locationInView:self.view].x >= kScreenWidth * 0.5){
            currentChapterVc.view.userInteractionEnabled = NO;
            return YES;
        }
    }
    currentChapterVc.view.userInteractionEnabled = YES;
    return NO;
}

- (void)checkSpine
{
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    YLCatalogController *catalogVc = [[YLCatalogController alloc]initWithEpub:_epub currentCatalogIndex:_currentChapterIndex];
    __weak typeof(self) weakSelf = self;
    catalogVc.didSelectCatalog = ^(YLEpub *epub, NSUInteger cIndex) {
        if(weakSelf.currentChapterIndex < cIndex){
            YLBookContentController *chapterVc = [weakSelf controllerForIndex:cIndex];
            [weakSelf.pageViewController setViewControllers:@[chapterVc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }else if (weakSelf.currentChapterIndex > cIndex){
            YLBookContentController *chapterVc = [weakSelf controllerForIndex:cIndex];
            [weakSelf.pageViewController setViewControllers:@[chapterVc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        }
    };
    [catalogVc showInController:self];
}

@end
