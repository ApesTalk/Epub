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
@property (nonatomic, assign) ChapterLoadStatus loadStatus;
@end

@implementation YLBookReadController
- (instancetype)initWithEpub:(YLEpub *)epub
{
    if(self = [super init]){
        self.epub = epub;
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
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    for(UIView *subView in self.pageViewController.view.subviews){
        if([subView isKindOfClass:[UIScrollView class]]){
            ((UIScrollView *)subView).bounces = NO;
        }
    }

    UIButton *preBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    preBtn.backgroundColor = [UIColor redColor];
    preBtn.frame = CGRectMake(0, (kScreenHeight - 50) * 0.5, 50, 50);
    preBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [preBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [preBtn setTitle:@"<" forState:UIControlStateNormal];
    [preBtn addTarget:self action:@selector(preAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:preBtn];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.backgroundColor = [UIColor redColor];
    nextBtn.frame = CGRectMake(kScreenWidth - 50, (kScreenHeight - 50) * 0.5, 50, 50);
    nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@">" forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    
    //UIPageViewController重置数据源animated必须传NO才能清除缓存
    [self.pageViewController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    //UIPageViewControllerTransitionStyleScroll类型的无手势，UIPageViewControllerTransitionStylePageCurl类型的有pan和tap手势
//    if(self.pageViewController.transitionStyle == UIPageViewControllerTransitionStylePageCurl){
//        for(UIGestureRecognizer *gesture in self.pageViewController.gestureRecognizers){
//            gesture.delegate = self;
//        }
//    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *preSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(preSwipeAction:)];
    preSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    preSwipe.delegate = self;
    [self.view addGestureRecognizer:preSwipe];
    
    UISwipeGestureRecognizer *nextSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(nextSwipeAction:)];
    nextSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    nextSwipe.delegate = self;
    [self.view addGestureRecognizer:nextSwipe];
    
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

- (void)preAction
{
    [self.navigationController setNavigationBarHidden:YES];

    YLBookContentController *currentChapterVc = (YLBookContentController *)self.pageViewController.viewControllers.firstObject;
    if(self.loadStatus == ChapterLoadStatusIdle || self.loadStatus == ChapterLoadStatusLoading){
        //防止快读点击->切换章节
        return;
    }
    
    if(currentChapterVc.currentColumnIndex > 0 ){
        [currentChapterVc scrollToPageIndex:currentChapterVc.currentColumnIndex - 1];
    }else{
        NSInteger index = currentChapterVc.chapterIndex;
        if(index != NSNotFound && index - 1 >= 0){
            YLBookContentController *preChapterVc = [self controllerForIndex:index - 1];
            preChapterVc.goLastPageWhenFinishLoad = YES;
            [self.pageViewController setViewControllers:@[preChapterVc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
        }
    }
}

- (void)nextAction
{
    [self.navigationController setNavigationBarHidden:YES];
    
    YLBookContentController *currentChapterVc = (YLBookContentController *)self.pageViewController.viewControllers.firstObject;
    if(self.loadStatus == ChapterLoadStatusIdle || self.loadStatus == ChapterLoadStatusLoading){
        //防止快读点击->切换章节
        return;
    }
    
    if(currentChapterVc.currentColumnIndex < currentChapterVc.maxColumnIndex){
        [currentChapterVc scrollToPageIndex:currentChapterVc.currentColumnIndex + 1];
    }else{
        NSInteger index = currentChapterVc.chapterIndex;
        if(index != NSNotFound && index + 1 < self.epub.spine.count){
            YLBookContentController *nextChapterVC = [self controllerForIndex:index + 1];
            [self.pageViewController setViewControllers:@[nextChapterVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        }
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
        if(index != NSNotFound && index + 1 < self.epub.spine.count){
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
        self.currentChapterIndex = vc.chapterIndex;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"loadStatus"]){
        NSLog(@"kvo loadStatus %@", change[NSKeyValueChangeNewKey]);
        self.loadStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
    }
}

#pragma mark---other methods
- (YLBookContentController *)controllerForIndex:(NSInteger)index
{
    if(index < 0 || index > self.epub.spine.count){
        return nil;
    }
    
    //create a new vc
    NSString *idref = [self.epub.spine objectAtIndex:index];
    NSString *href = [self.epub.mainifest objectForKey:idref];
    self.title = idref;
    NSString *htmlPath = [NSString stringWithFormat:@"%@%@", self.epub.opsPath, href];
    YLBookContentController *contentVc = [[YLBookContentController alloc] initWithHtmlPath:htmlPath title:idref];
    contentVc.chapterIndex = index;
    [contentVc addObserver:self forKeyPath:@"loadStatus" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    return contentVc;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)gesture
{
    gesture.enabled = NO;
    
    CGPoint point = [gesture locationInView:self.view];
    CGRect preRect = CGRectMake(0, kStatusAndNavigationBarHeight, kCSSPaddingLeft, kEpubViewHeight);
    CGRect nextRect = CGRectMake(kEpubViewWidth - kCSSPaddingRight, kStatusAndNavigationBarHeight, kCSSPaddingRight, kEpubViewHeight);
    if(CGRectContainsPoint(preRect, point)){
        [self preAction];
    }else if (CGRectContainsPoint(nextRect, point)){
        [self nextAction];
    }else {
        [self.navigationController setNavigationBarHidden:!self.navigationController.isNavigationBarHidden];
    }
    gesture.enabled = YES;
}

- (void)preSwipeAction:(UISwipeGestureRecognizer *)gesture
{
    gesture.enabled = NO;
    [self preAction];
    gesture.enabled = YES;
}

- (void)nextSwipeAction:(UISwipeGestureRecognizer *)gesture
{
    gesture.enabled = NO;
    [self nextAction];
    gesture.enabled = YES;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    YLBookContentController *currentChapterVc = (YLBookContentController *)[self.pageViewController viewControllers].firstObject;
//    NSInteger currentIndex = currentChapterVc.currentColumnIndex;
//    NSInteger maxIndex = currentChapterVc.maxColumnIndex;
//    ChapterLoadStatus status = currentChapterVc.loadStatus;
//    if(status != ChapterLoadStatusSuccess || status != ChapterLoadStatusError){
//        currentChapterVc.view.userInteractionEnabled = NO;
//        return NO;
//    }
//    if(currentIndex == 0){
//        //left Reverse
//        if(currentChapterVc.chapterIndex > 0 && [touch locationInView:self.view].x < kScreenWidth * 0.5){
//            currentChapterVc.view.userInteractionEnabled = NO;
//            return YES;
//        }
//    }
//    if (currentChapterVc.chapterIndex < self.epub.spine.count - 1 && currentIndex == maxIndex){
//        //right Forward
//        if([touch locationInView:self.view].x >= kScreenWidth * 0.5){
//            currentChapterVc.view.userInteractionEnabled = NO;
//            return YES;
//        }
//    }
//    currentChapterVc.view.userInteractionEnabled = YES;
//    return NO;
//}

- (void)checkSpine
{
//    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    YLCatalogController *catalogVc = [[YLCatalogController alloc]initWithEpub:self.epub currentCatalogIndex:self.currentChapterIndex];
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


- (void)dealloc
{
    
}
@end
