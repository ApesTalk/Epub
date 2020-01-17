//
//  YLBookContentController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBookContentController.h"
#import <WebKit/WebKit.h>
#import "YLEpubManager.h"
#import "YLStatics.h"

@interface YLBookContentController () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *chapterTitle;

@property (nonatomic, strong) UILabel *chapterTitleLabel;
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UILabel *indexsLabel;

@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign, readwrite) NSInteger currentColumnIndex;
@property (nonatomic, assign, readwrite) NSInteger maxColumnIndex;
@property (nonatomic, assign, readwrite) ChapterLoadStatus loadStatus;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation YLBookContentController
- (instancetype)initWithHtmlPath:(NSString *)path title:(NSString *)title
{
    if(self = [super init]){
        self.loadStatus = ChapterLoadStatusIdle;
        self.path = path;
        self.chapterTitle = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.chapterTitleLabel];
    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.indexsLabel];
    [self.view addSubview:self.indicator];
    
    self.chapterTitleLabel.text = self.chapterTitle;

    [self loadHtmlWithPath:self.path];
    
    //UIPanGestureRecognizer：多列的情况下响应，单列的情况下不响应
    for(UIGestureRecognizer *ges in self.wkWebView.scrollView.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [ges addTarget:self action:@selector(handlePan:)];
        }
    }

//    UIScrollViewPagingSwipeGestureRecognizer
    /*
     
     
     <UIScrollViewDelayedTouchesBeganGestureRecognizer: 0x600003f82600; state = Possible; delaysTouchesBegan = YES; view = <WKScrollView 0x7ff4cc033200>; target= <(action=delayed:, target=<WKScrollView 0x7ff4cc033200>)>>
    
     <UIScrollViewPanGestureRecognizer: 0x7ff4cb527810; state = Possible; delaysTouchesEnded = NO; view = <WKScrollView 0x7ff4cc033200>; target= <(action=handlePan:, target=<WKScrollView 0x7ff4cc033200>)>; must-fail = {
             <UIScrollViewPagingSwipeGestureRecognizer: 0x7ff4cb404270; state = Possible; view = <WKScrollView 0x7ff4cc033200>; target= <(action=_handleSwipe:, target=<WKScrollView 0x7ff4cc033200>)>>
         }>
     
     <UIScrollViewKnobLongPressGestureRecognizer: 0x7ff4cb527e80; state = Possible; view = <WKScrollView 0x7ff4cc033200>; target= <(action=_handleKnobLongPressGesture:, target=<WKScrollView 0x7ff4cc033200>)>>
     
     <_UIDragAutoScrollGestureRecognizer: 0x600003ab87e0; state = Possible; cancelsTouchesInView = NO; delaysTouchesEnded = NO; view = <WKScrollView 0x7ff4cc033200>; target= <(action=_handleAutoScroll:, target=<WKScrollView 0x7ff4cc033200>)>>
     
     <UIScrollViewPagingSwipeGestureRecognizer: 0x7ff4cb404270; state = Possible; view = <WKScrollView 0x7ff4cc033200>; target= <(action=_handleSwipe:, target=<WKScrollView 0x7ff4cc033200>)>; must-fail-for = {
             <UIScrollViewPanGestureRecognizer: 0x7ff4cb527810; state = Possible; delaysTouchesEnded = NO; view = <WKScrollView 0x7ff4cc033200>; target= <(action=handlePan:, target=<WKScrollView 0x7ff4cc033200>)>>
         }>
     */
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [[UIApplication sharedApplication]setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (UILabel *)chapterTitleLabel
{
    if(!_chapterTitleLabel){
        _chapterTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCSSPaddingLeft, kStatusBarHeight, kEpubViewWidth - kCSSPaddingLeft - kCSSPaddingRight, kNavigationBarHeight)];
        _chapterTitleLabel.backgroundColor = [UIColor whiteColor];
        _chapterTitleLabel.font = [UIFont boldSystemFontOfSize:20];
        _chapterTitleLabel.textColor = [UIColor blackColor];
        _chapterTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _chapterTitleLabel;
}

- (WKWebView *)wkWebView
{
    if(!_wkWebView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, kStatusAndNavigationBarHeight, kEpubViewWidth, kEpubViewHeight) configuration:config];
        _wkWebView.backgroundColor = [UIColor whiteColor];
        _wkWebView.scrollView.pagingEnabled = YES;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        _wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.scrollView.delegate = self;
//        _wkWebView.scrollView.bounces = NO;
//        _wkWebView.scrollView.scrollEnabled = NO;
        if (@available(iOS 11.0, *)) {
            _wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _wkWebView;
}

- (UILabel *)indexsLabel
{
    if(!_indexsLabel){
        _indexsLabel = [[UILabel alloc]initWithFrame:CGRectMake(kCSSPaddingLeft, kScreenHeight -kHomeIndicatorHeight - kEpubViewBottomGap, kScreenWidth - kCSSPaddingLeft - kCSSPaddingRight, 20)];
        _indexsLabel.backgroundColor = [UIColor whiteColor];
        _indexsLabel.font = [UIFont systemFontOfSize:14];
        _indexsLabel.textColor = [UIColor lightGrayColor];
        _indexsLabel.textAlignment = NSTextAlignmentRight;
    }
    return _indexsLabel;
}


- (UIActivityIndicatorView *)indicator
{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = self.view.center;
    }
    return _indicator;
}


- (void)setCurrentColumnIndex:(NSInteger)currentColumnIndex
{
    _currentColumnIndex = currentColumnIndex;
    if(self.maxColumnIndex < 0) {
        self.indexsLabel.text = nil;
    } else {
        self.indexsLabel.text = [NSString stringWithFormat:@"%ld/%ld", self.currentColumnIndex + 1, self.maxColumnIndex + 1];
    }
}

- (void)loadHtmlWithPath:(NSString *)path
{
    if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"chapter.html path not exists");
        return;
    }
        
    if(self.wkWebView.isLoading){
        [self.wkWebView stopLoading];
    }

    self.loadStatus = ChapterLoadStatusLoading;
    [self.view bringSubviewToFront:self.wkWebView];
    [self.view bringSubviewToFront:self.indicator];
    [self.indicator startAnimating];
    
    
    NSMutableString *htmlStr = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(![htmlStr containsString:kBookContentDiv]){
        NSRange headRange = [htmlStr rangeOfString:@"<head>"];
        if(headRange.location != NSNotFound) {
            NSInteger headEndIndex = headRange.location + headRange.length;
            [htmlStr insertString:@"<meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale = 1.0, user-scalable=no' />" atIndex:headEndIndex];
        }

        NSRange bodyRange = [htmlStr rangeOfString:@"<body>"];
        if(bodyRange.location != NSNotFound){
            NSInteger bodyBeginIndex = bodyRange.location + bodyRange.length;
            [htmlStr insertString:[NSString stringWithFormat:@"<div class='%@'>", kBookContentDiv] atIndex:bodyBeginIndex];
        }

        NSInteger bodyEndIndex = [htmlStr rangeOfString:@"</body>"].location;
        if(bodyEndIndex != NSNotFound){
            [htmlStr insertString:@"</div>" atIndex:bodyEndIndex];
        }
        
        //!!!!:WKWebView
        [htmlStr writeToURL:[NSURL fileURLWithPath:path] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }

    
    NSLog(@"html:%@", htmlStr);
    //!!!!: 在加载本地资源（img\css）UIWebView比WKWebView优
    //WKWebView这种方式在模拟器上可以，在真机上不行！苹果的意思是这种方式不安全。。。 而UIWebView这种方式在模拟器和真机上都可以。
//    [self.wkWebView loadHTMLString:htmlStr.copy baseURL:[NSURL fileURLWithPath:self.bookPath isDirectory:YES]];

    //!!!!:WKWebView必须以这种方式才能正常读取到本地的img和css，主要是css才能生效！
    [self.wkWebView loadFileURL:[NSURL fileURLWithPath:path] allowingReadAccessToURL:[NSURL fileURLWithPath:self.bookPath isDirectory:YES]];
}

- (void)scrollToPageIndex:(NSInteger)page
{
    [self changeToPage:page animated:YES];
}

- (void)changeToPage:(NSInteger)page animated:(BOOL)animated
{
    self.currentColumnIndex = page;
    [self.wkWebView.scrollView setContentOffset:CGPointMake(kEpubViewWidth * page, self.wkWebView.scrollView.contentOffset.y) animated:animated];
}

#pragma mark---WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.loadStatus = ChapterLoadStatusLoading;
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error:%@", error);
    self.loadStatus = ChapterLoadStatusError;
    [self.indicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    //iOS13适配
    NSString *js = @"document.body.scrollWidth";
    if(@available(iOS 13.0,*)){
        js = @"document.documentElement.scrollWidth";
    }
    
    [webView evaluateJavaScript:js completionHandler:^(id result,NSError *_Nullable error) {
        self.contentWidth = [result floatValue];
        NSInteger totalPages = _contentWidth / kScreenWidth;
        self.maxColumnIndex = MAX(0, totalPages - 1);
//        NSLog(@"scrollWidth=%f", _contentWidth);
        self.loadStatus = ChapterLoadStatusSuccess;
        [self.indicator stopAnimating];
        
        if(self.goLastPageWhenFinishLoad){
            //滚到到指定位置
            //模拟器上直接 [self changeToPage:self.maxColumnIndex animated:NO];可以，真机上不行，得加个延迟。或用js实现滚动
//            NSString *script = [NSString stringWithFormat:@"scrollTo(%.0f, 0)", self.maxColumnIndex*kEpubViewWidth];
//            [self.wkWebView evaluateJavaScript:script completionHandler:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self changeToPage:self.maxColumnIndex animated:NO];
            });
            self.goLastPageWhenFinishLoad = NO;
        }else{
            [self changeToPage:0 animated:NO];
        }
    }];
    
    //change html document backgroudcolor
//    [webView evaluateJavaScript:@"document.body.bgColor='#C2E4C1'" completionHandler:^(id ruslt, NSError * _Nullable error) {
//
//    }];
}


#pragma mark---UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.wkWebView.scrollView){
        CGFloat offsetX = scrollView.contentOffset.x;
//        NSLog(@"offsetX=%f", offsetX);
        self.currentColumnIndex = offsetX / kScreenWidth;
//        NSLog(@"currentColumnIndex=%li", self.currentColumnIndex);
    }
}


- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
    if(self.loadStatus == ChapterLoadStatusIdle || self.loadStatus == ChapterLoadStatusLoading){
        return;
    }
    
    
    CGPoint point = [gesture translationInView:self.wkWebView.scrollView];
    CGFloat x = self.wkWebView.scrollView.contentOffset.x;
    NSLog(@"offsetX=%f", x);
    if(fabs(point.x) > fabs(point.y)){
        //left right
        if(point.x > 0 && self.currentColumnIndex == 0 && x <= 0){
            //right
            if(self.delegate && [self.delegate respondsToSelector:@selector(contentController:shouldDirect:)]){
                [self.delegate contentController:self shouldDirect:UIPageViewControllerNavigationDirectionReverse];
            }
        }else if (point.x < 0 && self.currentColumnIndex == self.maxColumnIndex && x >= kEpubViewWidth * self.maxColumnIndex){
            //left
            if(self.delegate && [self.delegate respondsToSelector:@selector(contentController:shouldDirect:)]){
                [self.delegate contentController:self shouldDirect:UIPageViewControllerNavigationDirectionForward];
            }
        }
    }else{
        //up down
    }
}


- (void)dealloc
{
//    _wkWebView.UIDelegate = nil;
//    _wkWebView.navigationDelegate = nil;
    self.wkWebView.scrollView.delegate = nil;
    for(UIGestureRecognizer *ges in self.wkWebView.scrollView.gestureRecognizers){
        if([ges isKindOfClass:[UIPanGestureRecognizer class]]){
            [ges removeTarget:self action:@selector(handlePan:)];
        }
    }
}
@end
