//
//  YLEpubManager.h
//  YLEpubReader
//
//  Created by lumin on 2018/4/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZipArchive.h"

@interface YLEpubManager : NSObject
+ (NSString *)docPath;
+ (NSString *)epubFolderPath;
+ (BOOL)unZipEpubWithPath:(NSString *)path delegate:(id<SSZipArchiveDelegate>)delegate;
+ (NSString *)unZipedFolderPathForEpubName:(NSString *)name;
+ (NSString *)contaierXmlPathForEpubName:(NSString *)name;///< return contaier.xml path
@end
