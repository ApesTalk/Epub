//
//  YLEpubManager.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLEpubManager.h"
#import "YLEpub.h"

@implementation YLEpubManager
+ (NSString *)docPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.count > 0 ? [paths firstObject] : nil;
}

+ (NSString *)epubFolderPath
{
    return [NSString stringWithFormat:@"%@/UnZipedEpubs", [self docPath]];
}

+ (BOOL)unZipEpubWithPath:(NSString *)path delegate:(id<SSZipArchiveDelegate>)delegate
{
    if(path.length == 0){
        return NO;
    }
    NSString *lastPathComponent = [path lastPathComponent];
    if(![lastPathComponent hasSuffix:@"epub"]){
        return NO;
    }else{
        NSString *fileName = [lastPathComponent stringByReplacingOccurrencesOfString:@".epub" withString:@""];
        if(fileName.length == 0){
            return NO;
        }
        NSString *toPath = [NSString stringWithFormat:@"%@/%@", [self epubFolderPath], fileName];
        if([[NSFileManager defaultManager]fileExistsAtPath:toPath]){
            //already unziped
            if(delegate){
                [delegate zipArchiveProgressEvent:1 total:1];
            }
            return YES;
        }
        BOOL ret = [SSZipArchive unzipFileAtPath:path toDestination:toPath delegate:delegate];
        return ret;
    }
    return NO;
}

+ (NSString *)unZipedFolderPathForEpubName:(NSString *)name
{
    //here use name indicate the folder
    NSString *toPath = [NSString stringWithFormat:@"%@/%@", [self epubFolderPath], name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:toPath]){
        return toPath;
    }
    return nil;
}

+ (NSString *)contaierXmlPathForEpubName:(NSString *)name
{
    NSString *folderPath = [self unZipedFolderPathForEpubName:name];
    if(!folderPath){
        return nil;
    }
    NSString *path = [NSString stringWithFormat:@"%@/META-INF/container.xml", folderPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        return path;
    }
    return nil;
}
@end
