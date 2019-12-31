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

@interface YLBookContentController () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *chapterTitle;

@property (nonatomic, strong) UILabel *chapterTitleLabel;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UILabel *indexsLabel;

@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign, readwrite) NSInteger currentColumnIndex;
@property (nonatomic, assign, readwrite) NSInteger maxColumnIndex;
@property (nonatomic, assign, readwrite) ChapterLoadStatus loadStatus;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL barIsShow;


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
    
    [self.view addSubview:self.chapterTitleLabel];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.indexsLabel];
    
    self.chapterTitleLabel.text = self.chapterTitle;
    
    [self loadHtmlWithPath:self.path];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//    tapGesture.delegate = self;
//    [self.webView addGestureRecognizer:tapGesture];

//    for(UIGestureRecognizer *gesture in self.webView.scrollView.gestureRecognizers){
//        if(gesture != tapGesture){
//            [gesture requireGestureRecognizerToFail:tapGesture];
//        }
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.barIsShow = NO;
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

- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, kStatusAndNavigationBarHeight, kEpubViewWidth, kEpubViewHeight) configuration:config];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.pagingEnabled = YES;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _webView;
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
    
    self.path = path;
    
    if(self.webView.isLoading){
        [self.webView stopLoading];
    }
    
    NSMutableString *htmlStr = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSRange headRange = [htmlStr rangeOfString:@"<head>"];
    if(headRange.location != NSNotFound) {
        NSInteger headEndIndex = headRange.location + headRange.length;
        [htmlStr insertString:@"<meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale = 1.0,user-scalable=no' />" atIndex:headEndIndex];

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
    
    NSLog(@"html:%@", htmlStr);
    [self.webView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:path]];
}

- (void)scrollToPageIndex:(NSInteger)page
{
    [self changeToPage:page animated:YES];
}

- (void)changeToPage:(NSInteger)page animated:(BOOL)animated
{
    self.currentColumnIndex = page;
    [self.webView.scrollView setContentOffset:CGPointMake(kScreenWidth * page, self.webView.scrollView.contentOffset.y) animated:animated];
}

#pragma mark---WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    self.loadStatus = ChapterLoadStatusLoading;
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
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
    
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        self.contentWidth = [result floatValue];
        NSInteger totalPages = _contentWidth / kScreenWidth;
        self.maxColumnIndex = MAX(0, totalPages - 1);
        NSLog(@"scrollWidth=%f", _contentWidth);
        if(self.goLastPageWhenFinishLoad){
            [self changeToPage:self.maxColumnIndex animated:NO];
            self.goLastPageWhenFinishLoad = NO;
        }else{
            [self changeToPage:0 animated:NO];
        }
        self.loadStatus = ChapterLoadStatusSuccess;
        [self.indicator stopAnimating];
    }];
}

#pragma mark---UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == self.webView.scrollView){
        CGFloat offsetX = scrollView.contentOffset.x;
        self.currentColumnIndex = offsetX / kScreenWidth;
        NSLog(@"_currentColumnIndex=%li", self.currentColumnIndex);
    }
}

#pragma mark---UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


#pragma mark---other methods

//- (void)tapAction:(UITapGestureRecognizer *)gesture
//{
//    CGPoint point = [gesture locationInView:self.view];
//    if(point.x >= 30 && point.x <= kScreenWidth - 30){
//        if(self.barIsShow){
//            self.barIsShow = NO;
//            [[UIApplication sharedApplication]setStatusBarHidden:YES];
////            [self.navigationController setNavigationBarHidden:YES animated:YES];
//        }else{
//            self.barIsShow = YES;
//            [[UIApplication sharedApplication]setStatusBarHidden:NO];
////            [self.navigationController setNavigationBarHidden:NO animated:YES];
//        }
//        [self setNeedsStatusBarAppearanceUpdate];
//    }
//}
@end
