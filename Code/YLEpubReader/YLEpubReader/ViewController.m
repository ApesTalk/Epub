//
//  ViewController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/1.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "ViewController.h"
#import "YLTestViewController.h"
#import "ZipArchive.h"
#import "YLEpubManager.h"
#import "YLEpub.h"
#import "YLXMLManager.h"

@interface ViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,UIWebViewDelegate,SSZipArchiveDelegate,YLXMLManagerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, copy) NSArray *colorsArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UITextView *textView = [[UITextView alloc]initWithFrame:self.view.bounds];
//    textView.font = [UIFont systemFontOfSize:20];
//    textView.textColor = [UIColor blackColor];
//    textView.text = @"陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生陈二狗的妖孽人生";
//    [self.view addSubview:textView];
//    return;
    

    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.backgroundColor = [UIColor whiteColor];
    webView.delegate = self;
    webView.scrollView.pagingEnabled = YES;
    webView.scrollView.showsVerticalScrollIndicator = NO;
    webView.scrollView.showsHorizontalScrollIndicator = NO;
    webView.scrollView.bounces = NO;
    webView.scrollView.tintColor = [UIColor redColor];
    [self.view addSubview:webView];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"chapter_269231114" ofType:@"xhtml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    return;
    
    //测试矢量图
//    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.width * 48 / 40)];
//    icon.image = [UIImage imageNamed:@"Image"];
//    [self.view addSubview:icon];
    
    
//    return;
    
    //注意_pageViewController.viewControllers不包含所有它能展示的控制器，不拥有，只会拥有setViewControllers和当前展示的controller
    
    _colorsArray = [[NSArray alloc]initWithObjects:[UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor purpleColor], nil];
    
    YLTestViewController *firstVc = [[YLTestViewController alloc]init];
    firstVc.bgColor = [_colorsArray objectAtIndex:0];
    YLTestViewController *secondVc = [[YLTestViewController alloc]init];
    secondVc.bgColor = [_colorsArray objectAtIndex:1];
    NSArray *controllers = @[firstVc];//, secondVc
    
    //UIPageViewControllerOptionSpineLocationKey 书脊位置
    //UIPageViewControllerOptionInterPageSpacingKey 针对水平滚动时页面之间的间距
//    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey:@(UIPageViewControllerSpineLocationMax),
//                              UIPageViewControllerOptionInterPageSpacingKey:@(10),
//                              };
    NSDictionary *options = nil;
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [_pageViewController setViewControllers:controllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark---SSZipArchiveDelegate
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total
{
    NSLog(@"zip loaded=%llu ,total=%llu",loaded, total);
    //这里处理进度
}

#pragma mark---UIPageViewControllerDataSource
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [_colorsArray indexOfObject:((YLTestViewController *)viewController).bgColor];
    if(index != NSNotFound && index - 1 >= 0){
        return [self controllerForIndex:index - 1];
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [_colorsArray indexOfObject:((YLTestViewController *)viewController).bgColor];
    if(index != NSNotFound && index + 1 < _colorsArray.count){
        return [self controllerForIndex:index + 1];
    }
    return nil;
}

//水平滚动且同时实现以下方法才会显示一个页码
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return _colorsArray.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    YLTestViewController *vc = (YLTestViewController *)[pageViewController.viewControllers firstObject];
    return [_colorsArray indexOfObject:vc];
}

#pragma mark---UIPageViewControllerDelegate


#pragma mark---UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize contentSize = webView.scrollView.contentSize;
//    contentSize.width += 10;
    contentSize.height = self.view.bounds.size.height;
    webView.scrollView.contentSize = contentSize;
}

#pragma mark---UIScrollViewDelegate


#pragma mark---other methods
- (UIViewController *)controllerForIndex:(NSInteger)index
{
    if(index < 0 || index > _colorsArray.count){
        return nil;
    }
    //create a new vc
    YLTestViewController *vc = [[YLTestViewController alloc]init];
    vc.bgColor = [_colorsArray objectAtIndex:index];
    return vc;
}

@end
