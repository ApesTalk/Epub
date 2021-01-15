//
//  YLEpub.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/14.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//  电子书

#import <Foundation/Foundation.h>

@interface YLEpubChapter : NSObject
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *path;///< 非完整路径，完整路径需在前面拼接opsPath
@property (nonatomic, strong) YLEpubChapter *preChapter;
@property (nonatomic, strong) YLEpubChapter *nextChapter;
@end


@interface YLEpub : NSObject
@property (nonatomic, copy) NSString *fileId;
@property (nonatomic, copy) NSString *name;
//以下是metadata中的数据
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *descript;
@property (nonatomic, copy) NSString *coverage;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *rights;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *contributor;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, copy) NSString *relation;
@property (nonatomic, copy) NSString *builder;
@property (nonatomic, copy) NSString *builderVersion;

@property (nonatomic, copy) NSString *filePath;///< 本地文件路径
@property (nonatomic, copy) NSString *unZipedPath;///< 解压后的路径
@property (nonatomic, copy) NSString *opsPath;///< ops文件夹路径，以'/'结尾。 ex:xxx/xxx/OPS/
@property (nonatomic, copy) NSDictionary<NSString* , NSString*> *manifest;///< 清单
@property (nonatomic, copy) NSArray<NSString*> *spine;///< 书脊

@property (nonatomic, copy) NSArray<YLEpubChapter*> *chapters;

//@property (nonatomic, copy) NSString *localBookContentPath;

- (instancetype)initWithName:(NSString *)name filePath:(NSString *)path;
- (void)setMetadata:(NSDictionary *)metadata;
- (NSString *)coverPath;///< 封面图路径
- (void)modifyCss;///< 修改css样式
@end
