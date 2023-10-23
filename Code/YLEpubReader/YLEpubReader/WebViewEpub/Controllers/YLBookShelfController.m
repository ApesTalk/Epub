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

#import "YLCoreTextReadController.h"
#import "YLReadManager.h"

typedef NS_ENUM(NSInteger, ReadStyle) {
    ReadStyleWebKit,
    ReadStyleWechat,
    ReadStyleDeDao
};

static NSString *cellIdentifiler = @"YLBookShelfCell";

@interface YLBookShelfController () <UICollectionViewDataSource, UICollectionViewDelegate, SSZipArchiveDelegate, YLXMLManagerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *bookNames;
@property (nonatomic, strong) NSMutableArray *eBooks;
@property (nonatomic, assign) NSInteger currentUnZipIndex;
@property (nonatomic, strong) YLXMLManager *xmlManager;
@property (nonatomic, copy) NSString *opsFolderPath;
@property (nonatomic, assign) ReadStyle readStyle;
@end

@implementation YLBookShelfController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"书架";
    self.readStyle = ReadStyleWechat;
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
//    YLBookReadController *readVc = [[YLBookReadController alloc]initWithEpub:epub];
//    [self.navigationController pushViewController:readVc animated:YES];
    
    //coretext
    [YLReadManager shareManager].bookModel = epub;
    YLCoreTextReadController *readVc = [[YLCoreTextReadController alloc] init];
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
- (void)xmlManagerFinishParse:(YLXMLManager *)manager
{
    if(manager.parseType == ParseTypeContainer){
        //拿到opf文件路径，开始解析opf
        NSString *name = [self.bookNames objectAtIndex:self.currentUnZipIndex];
        NSString *unZipedFolderPath = [YLEpubManager unZipedFolderPathForEpubName:name];
        self.opsFolderPath = [NSString stringWithFormat:@"%@/%@", unZipedFolderPath, [manager.opfPath stringByReplacingOccurrencesOfString:[manager.opfPath lastPathComponent] withString:@""]];
        NSString *opfFilePath = [NSString stringWithFormat:@"%@/%@", unZipedFolderPath, manager.opfPath];
        [self.xmlManager parseXMLAtPath:opfFilePath];
        return;
    }
    if(manager.parseType == ParseTypeOPF){
        NSString *name = [self.bookNames objectAtIndex:self.currentUnZipIndex];
        NSString *unZipedFolderPath = [YLEpubManager unZipedFolderPathForEpubName:name];
        NSString *ncxFilePath = [NSString stringWithFormat:@"%@/%@", unZipedFolderPath, manager.ncxPath];
        [self.xmlManager parseXMLAtPath:ncxFilePath];
        return;
    }
    if(manager.parseType == ParseTypeNCX){
        manager.epub.opsFolderPath = self.opsFolderPath;
        if(self.readStyle == ReadStyleWebKit){
            [manager.epub modifyCss];
        }
        if(manager.epub){
            [self.eBooks addObject:manager.epub];
        }
        if(self.currentUnZipIndex == self.bookNames.count - 1){
            [SVProgressHUD showSuccessWithStatus:@"解析成功"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        return;
    }
    
    
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
    [self.bookNames addObject:@"算法图解"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSInteger i = 0; i < self.bookNames.count; i++){
            self.currentUnZipIndex = i;
            NSString *path = [[NSBundle mainBundle] pathForResource:self.bookNames[i] ofType:@"epub"];
            [YLEpubManager unZipEpubWithPath:path delegate:self];
        }
    });
}

@end
