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

@interface YLBookContentController () <WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) WKWebView *webView;
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
    [self.view addSubview:self.webView];
    [self loadHtmlWithPath:_path];
}

- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.pagingEnabled = YES;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.tintColor = [UIColor redColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)loadHtmlWithPath:(NSString *)path
{
    if(!path || ![[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSLog(@"chapter.html path not exists");
        return;
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
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error:%@", error);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.body.scrollWidth"completionHandler:^(id _Nullable result,NSError *_Nullable error) {
        CGFloat width = [result floatValue];
        NSLog(@"scrollWidth=%f", width);
    }];
}
@end
