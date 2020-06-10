//
//  YLCatalogController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2019/3/25.
//  Copyright © 2019年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCatalogController.h"
#import "YLStatics.h"
#import "YLEpub.h"

static NSString *cellIdentifier = @"cell";

@interface YLCatalogController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) YLEpub *epub;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) UITableView *spineTable;
@property (nonatomic, assign) BOOL spineIsVisible;
@end

@implementation YLCatalogController
- (instancetype)initWithEpub:(YLEpub *)epub currentCatalogIndex:(NSUInteger)cIndex{
    if(self = [super init]){
        _epub = epub;
        _currentIndex = cIndex;
    }
    return self;
}

- (void)showInController:(UIViewController *)controller{
    if(controller){
        [controller addChildViewController:self];
        [controller.view addSubview:self.view];
        _spineIsVisible = YES;
        
        self.view.alpha = 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 1.0;
            self.spineTable.frame = CGRectMake(kScreenWidth*0.5, 0, kScreenWidth*0.5, kScreenHeight);
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *cover = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:cover];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBack)];
    tap.delegate = self;
    [cover addGestureRecognizer:tap];
    
    self.view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
    [self.view addSubview:self.spineTable];
    self.spineTable.frame = CGRectMake(kScreenWidth, 0, kScreenWidth * 0.5, kScreenHeight);
    [self.spineTable reloadData];
    [self.spineTable setNeedsLayout];
    [self.spineTable layoutIfNeeded];
    if(_currentIndex < _epub.spine.count){
        [self.spineTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

- (UITableView *)spineTable
{
    if(!_spineTable){
        _spineTable = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
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

#pragma mark---UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _epub.spine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = indexPath.row == _currentIndex ? self.navigationController.navigationBar.tintColor : [UIColor darkGrayColor];
    cell.textLabel.text = [_epub.spine objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark---UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    !_didSelectCatalog?:_didSelectCatalog(_epub, indexPath.row);
    [self tapBack];
}

#pragma mark---UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view != self.spineTable;
}

#pragma mark---other methods
- (void)tapBack
{
    if(!_spineIsVisible){
        return;
    }
    _spineIsVisible = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.spineTable.frame = CGRectMake(kScreenWidth, 0, kScreenWidth * 0.5, kScreenHeight);
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
    !_dismissCatalog?:_dismissCatalog();
}

@end
