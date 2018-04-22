//
//  YLBookContentController.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLBookContentController.h"
#import <WebKit/WebKit.h>
#import "YLEpubManager.h"
#import "YLStatics.h"

@interface YLBookContentController () <WKUIDelegate,WKNavigationDelegate,UIScrollViewDelegate,CAAnimationDelegate>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign, readwrite) NSInteger currentColumnIndex;
@property (nonatomic, assign, readwrite) NSInteger maxColumnIndex;
@property (nonatomic, assign, readwrite) YLWebLoadStatus loadStatus;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation YLBookContentController
- (instancetype)initWithHtmlPath:(NSString *)path
{
    if(self = [super init]){
        _path = path;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loadStatus = YLWebLoadStatusIdle;
    [self.view addSubview:self.webView];
//    [self loadHtmlWithPath:_path];
}

- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) configuration:config];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.pagingEnabled = YES;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.bounces = NO;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        _webView.scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _webView;
}

- (UIActivityIndicatorView *)indicator
{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = self.view.center;
    }
    return _indicator;
}

- (void)loadHtmlWithPath:(NSString *)path
{
    if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"chapter.html path not exists");
        return;
    }
    _path = path;
    if(self.webView.isLoading){
        [self.webView stopLoading];
    }
    NSMutableString *htmlStr = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSInteger headEndIndex = [htmlStr rangeOfString:@"<head>"].location + 6;
    [htmlStr insertString:@"<meta name='viewport' content='initial-scale=1.0, minimum-scale=1.0, maximum-scale = 1.0,user-scalable=no' />" atIndex:headEndIndex];
    NSInteger bodyStartIndex = [htmlStr rangeOfString:@"<body>"].location;
    if(bodyStartIndex != NSNotFound){
        [htmlStr insertString:[NSString stringWithFormat:@"<div class='%@'>", kBookContentDiv] atIndex:bodyStartIndex + 6];
    }
    NSInteger bodyEndIndex = [htmlStr rangeOfString:@"</body>"].location;
    if(bodyEndIndex != NSNotFound){
        [htmlStr insertString:@"</div>" atIndex:bodyEndIndex];
    }
    NSLog(@"html:%@", htmlStr);
    [self.webView loadHTMLString:htmlStr baseURL:[NSURL fileURLWithPath:path]];
}

#pragma mark---WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    _loadStatus = YLWebLoadStatusLoading;
    [self.view addSubview:self.indicator];
    [self.indicator startAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error:%@", error);
    _loadStatus = YLWebLoadStatusLoadFinish;
    [self.indicator stopAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.body.scrollWidth"completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        _contentWidth = [result floatValue];
        _maxColumnIndex = MAX(0, _contentWidth / kScreenWidth - 1);
        NSLog(@"scrollWidth=%f", _contentWidth);
        if(_goLastPageWhenFinishLoad){
            [webView.scrollView setContentOffset:CGPointMake(_maxColumnIndex * kScreenWidth, 0) animated:NO];
            _goLastPageWhenFinishLoad = NO;
        }
        _loadStatus = YLWebLoadStatusLoadFinish;
        [self.indicator stopAnimating];
    }];
}

#pragma mark---UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    self.currentColumnIndex = offsetX / kScreenWidth;
    NSLog(@"_currentColumnIndex=%li", _currentColumnIndex);
}

@end
