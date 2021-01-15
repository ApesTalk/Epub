//
//  YLBookShelfController.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBookShelfController.h"
#import "YLBookShelfCell.h"
#import "YLEpub.h"
#import "SVProgressHUD.h"
#import "SSZipArchive.h"
#import "YLStatics.h"
#import "YLEpubManager.h"
#import "YLXMLManager.h"
#import "YLBookReadController.h"

static NSString *cellIdentifiler = @"YLBookShelfCell";

@interface YLBookShelfController () <UICollectionViewDataSource, UICollectionViewDelegate, SSZipArchiveDelegate, YLXMLManagerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *bookNames;
@property (nonatomic, strong) NSMutableArray *eBooks;
@property (nonatomic, assign) NSInteger currentUnZipIndex;
@property (nonatomic, strong) YLXMLManager *xmlManager;
@property (nonatomic, copy) NSString *opsPath;
@end

@implementation YLBookShelfController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"书架";
    self.currentUnZipIndex = 0;
    self.bookNames = [NSMutableArray array];
    self.eBooks = [NSMutableArray array];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake([YLBookShelfCell width], [YLBookShelfCell height]);
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = ([UIScreen mainScreen].bounds.size.width - 3 * [YLBookShelfCell width] - 20 * 2) / 2.0;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[YLBookShelfCell class] forCellWithReuseIdentifier:cellIdentifiler];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    
    [self readEpubs];
}

- (YLXMLManager *)xmlManager
{
    if(!_xmlManager){
        _xmlManager = [[YLXMLManager alloc]init];
        _xmlManager.delegate = self;
    }
    return _xmlManager;
}

#pragma mark---UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.eBooks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLBookShelfCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifiler forIndexPath:indexPath];
    [cell loadWithEpub:[self.eBooks objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark---UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    YLBookShelfCell *cell = (YLBookShelfCell*)[collectionView cellForItemAtIndexPath:indexPath];
    self.transitionView = cell.coverImg;
    
    YLEpub *epub = [self.eBooks objectAtIndex:indexPath.row];
    YLBookReadController *readVc = [[YLBookReadController alloc]initWithEpub:epub];
    [self.navigationController pushViewController:readVc animated:YES];
}

#pragma mark---SSZipArchiveDelegate
- (void)zipArchiveProgressEvent:(unsigned long long)loaded total:(unsigned long long)total
{
    //这里可以处理进度
    [SVProgressHUD showProgress:loaded / total status:loaded < total ? @"解压中" : @"解压完成"];
    if(loaded == total){
        //解压完成，解析container.xml
        [SVProgressHUD showWithStatus:@"解析中"];
        NSString *name = [self.bookNames objectAtIndex:self.currentUnZipIndex];
        [self.xmlManager parseXMLAtPath:[YLEpubManager contaierXmlPathForEpubName:name]];
    }
}

#pragma mark---YLXMLManagerDelegate
- (void)xmlManager:(YLXMLManager *)manager didFoundFullPath:(NSString *)fullPath
{
    NSString *name = [self.bookNames objectAtIndex:self.currentUnZipIndex];
    NSString *unZipedFolderPath = [YLEpubManager unZipedFolderPathForEpubName:name];
    self.opsPath = [NSString stringWithFormat:@"%@/%@", unZipedFolderPath, [fullPath stringByReplacingOccurrencesOfString:[fullPath lastPathComponent] withString:@""]];
    NSString *opfPath = [NSString stringWithFormat:@"%@/%@", unZipedFolderPath, fullPath];
    [self.xmlManager parseXMLAtPath:opfPath];
}

- (void)xmlManager:(YLXMLManager *)manager didFinishParsing:(YLEpub *)epub
{
    NSString *name = [_bookNames objectAtIndex:self.currentUnZipIndex];
    epub.name = name;
    epub.opsPath = self.opsPath;
    [epub modifyCss];
    [self.eBooks addObject:epub];
    [SVProgressHUD showSuccessWithStatus:@"解析成功"];
    [SVProgressHUD dismissWithDelay:1];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

- (void)xmlManager:(YLXMLManager *)manager failedParseWithError:(NSError *)error
{
    NSLog(@"error:%@", error);
    [SVProgressHUD showErrorWithStatus:@"解析失败"];
    [SVProgressHUD dismissWithDelay:1];
}

#pragma mark---other methods
- (void)readEpubs
{
    [SVProgressHUD showProgress:0.0 status:@"加载中"];
    [self.bookNames addObject:@"陈二狗的妖孽人生"];
    for(NSInteger i = 0; i < self.bookNames.count; i++){
        self.currentUnZipIndex = i;
        NSString *path = [[NSBundle mainBundle]pathForResource:self.bookNames[i] ofType:@"epub"];
        [YLEpubManager unZipEpubWithPath:path delegate:self];
    }
}

@end
