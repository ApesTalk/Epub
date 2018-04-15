//
//  YLBookContentController.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLBookContentController.h"
#import <WebKit/WebKit.h>

@interface YLBookContentController () <WKUIDelegate,WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation YLBookContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
}

- (WKWebView *)webView
{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        _webView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (void)loadHtmlWithPath:(NSString *)path
{
    NSMutableString *htmlStr = [NSMutableString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSInteger bodyStartIndex = [htmlStr rangeOfString:@"<body>"].location;
    NSString *script = @"<script type='text/javascript'>"
                            "window.onload = function(){"
                            "document.body.margin = 0px;"
                            "document.body.height = 568px;"
                            "document.body.column-width = 280px;"
                            "document.body.column-gap = 0px;"
                            "document.body.text-align = justify;"
                        "</script>";///< 图片元素宽度等于屏幕宽度，高度自适应
    [htmlStr insertString:script atIndex:bodyStartIndex + 6];
    if(bodyStartIndex != NSNotFound){
        
    }
    NSInteger bodyEndIndex = [htmlStr rangeOfString:@"</body>"].location;
    [self.webView loadHTMLString:htmlStr baseURL:[NSURL URLWithString:path]];
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
    CGSize contentSize = webView.scrollView.contentSize;
    contentSize.height = self.view.bounds.size.height;
    webView.scrollView.contentSize = contentSize;
}
@end
