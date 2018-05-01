//
//  YLBookReadController.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLBookReadController.h"
#import "YLBookContentController.h"
#import "YLEpub.h"
#import "YLStatics.h"

static NSString *cellIdentifier = @"cell";

@interface YLBookReadController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) YLEpub *epub;
@property (nonatomic, assign) BOOL spineIsShow;
@property (nonatomic, strong) UIButton *coverView;
@property (nonatomic, strong) UITableView *spineTable;
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
    
    [_pageViewController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
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

- (UIButton *)coverView
{
    if(!_coverView){
        _coverView = [UIButton buttonWithType:UIButtonTypeCustom];
        _coverView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        _coverView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        [_coverView addTarget:self action:@selector(tapCover) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coverView;
}

- (UITableView *)spineTable
{
    if(!_spineTable){
        _spineTable = [[UITableView alloc]initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth * 0.5, kScreenHeight) style:UITableViewStylePlain];
        [_spineTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        _spineTable.dataSource = self;
        _spineTable.delegate = self;
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth * 0.5, kStatusAndNavigationBarHeight)];
        header.backgroundColor = [UIColor whiteColor];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kStatusBarHeight, kScreenWidth * 0.5, kNavigationBarHeight)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"目录";
        [header addSubview:titleLabel];
        _spineTable.tableHeaderView = header;
        _spineTable.tableFooterView = [UIView new];
    }
    return _spineTable;
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

#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _epub.spine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    YLBookContentController *currentChapterVc = (YLBookContentController *)[self.pageViewController.viewControllers firstObject];
    NSInteger chaterIndex = currentChapterVc.chapterIndex;
    cell.textLabel.textColor = indexPath.row == chaterIndex ? self.navigationController.navigationBar.tintColor : [UIColor darkGrayColor];
    cell.textLabel.text = [_epub.spine objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark---UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    YLBookContentController *currentChapterVc = (YLBookContentController *)[[self.pageViewController viewControllers]firstObject];
    NSInteger index = currentChapterVc.chapterIndex;
    if(index == indexPath.row){
        [currentChapterVc scrollToPageIndex:0];
        return;
    }
    YLBookContentController *targetVc = [self controllerForIndex:indexPath.row];
    UIPageViewControllerNavigationDirection direction = index < indexPath.row ?  UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageViewController setViewControllers:@[targetVc] direction:direction animated:YES completion:nil];
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
    
    if(_spineTable){
        [_spineTable reloadData];
    }
    
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

- (void)tapCover
{
    _spineIsShow = NO;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.spineTable.frame;
        frame.origin.x = kScreenWidth;
        _spineTable.frame = frame;
    }completion:^(BOOL finished) {
        [_coverView removeFromSuperview];
    }];
}

- (void)checkSpine
{
    if(_spineIsShow){
        [self coverView];
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        _spineIsShow = YES;
        [self.view addSubview:self.coverView];
        [self.coverView addSubview:self.spineTable];
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.spineTable.frame;
            frame.origin.x = kScreenWidth * 0.5;
            _spineTable.frame = frame;
        }completion:^(BOOL finished) {
        }];
    }
}

@end
