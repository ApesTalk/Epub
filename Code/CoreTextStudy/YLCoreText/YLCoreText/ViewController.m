//
//  ViewController.m
//  YLCoreText
//
//  Created by ApesTalk on 16/4/28.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *sectionList;
    NSArray *dataList1;
    NSArray *controllers1;
    NSArray *dataList2;
    NSArray *controllers2;
    UITableView *table;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"CoreText";
    sectionList = @[@"唐巧iOS进阶及其他学习",@"苹果官方教程学习"];
    dataList1 = @[@"绘制文本",@"图文混排",@"绘制图片",@"绘制视频"];
    controllers1 = @[@"YLDrawTextViewController",@"YLDrawTextPicViewController",@"YLDrawPicViewController",@"YLDrawVedioViewController"];
    dataList2 = @[@"Laying Out a Paragraph",@"Simple Text Label",@"Columnar Layout",@"Manual Line Breaking",@"Applying a Paragraph Style",@"Display Text in a Nonrectangular Region"];
    controllers2 = @[@"YLParagraphViewController",@"YLTextLabelViewController",@"YLColumarLayoutViewController",@"YLManualLineBreakingController",@"YLApplyParagraphStyleViewController",@"YLDisplayInNonrectViewController"];
    table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    table.dataSource = self;
    table.delegate = self;
    [self.view addSubview:table];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark---UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectionList.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sectionList[section];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return dataList1.count;
    }else{
        return dataList2.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(indexPath.section == 0){
        cell.textLabel.text = dataList1[indexPath.row];
    }else{
        cell.textLabel.text = dataList2[indexPath.row];
    }
    return cell;
}

#pragma mark---UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class className;
    if(indexPath.section == 0){
        className = NSClassFromString(controllers1[indexPath.row]);
    }else{
        className = NSClassFromString(controllers2[indexPath.row]);
    }
    UIViewController *vc = [[className alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
