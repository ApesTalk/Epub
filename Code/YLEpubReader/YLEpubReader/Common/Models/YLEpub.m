//
//  YLEpub.m
//  YLEpubReader
//
//  Created by lumin on 2018/4/14.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//

#import "YLEpub.h"
#import "YLEpubManager.h"
#import "YLStatics.h"

@implementation YLEpub
- (instancetype)initWithName:(NSString *)name filePath:(NSString *)path
{
    if(self = [super init]){
        _name = name;
        _filePath = path;
    }
    return self;
}

- (void)setMetadata:(NSDictionary *)metadata
{
    for(NSString *key in metadata.allKeys){
        NSString *value = [metadata valueForKey:key];
        if([key isEqualToString:@"title"]){
            _title = value;
        }else if ([key isEqualToString:@"identifier"]){
            _identifier = value;
        }else if([key isEqualToString:@"language"]){
            _language = value;
        }else if ([key isEqualToString:@"creator"]){
            _creator = value;
        }else if([key isEqualToString:@"publisher"]){
            _publisher = value;
        }else if ([key isEqualToString:@"description"]){
            _descript = value;
        }else if([key isEqualToString:@"coverage"]){
            _coverage = value;
        }else if ([key isEqualToString:@"source"]){
            _source = value;
        }else if([key isEqualToString:@"date"]){
            _date = value;
        }else if ([key isEqualToString:@"rights"]){
            _rights = value;
        }else if([key isEqualToString:@"subject"]){
            _subject = value;
        }else if ([key isEqualToString:@"contributor"]){
            _contributor = value;
        }else if([key isEqualToString:@"type"]){
            _type = value;
        }else if ([key isEqualToString:@"format"]){
            _format = value;
        }else if([key isEqualToString:@"relation"]){
            _relation = value;
        }else if ([key isEqualToString:@"builder"]){
            _builder = value;
        }else if([key isEqualToString:@"builder_version"]){
            _builderVersion = value;
        }
    }
}

- (NSString *)coverPath
{
    NSString *coverImage = [_mainifest objectForKey:@"cover-image"];
    if(coverImage && _opsPath){
        NSString *path = [NSString stringWithFormat:@"%@%@", _opsPath, coverImage];
        return path;
    }
    return nil;
}

- (void)modifyCss
{
    //修改body样式，添加bookcontent样式
    if(_opsPath && _mainifest && [_mainifest objectForKey:@"css"]){
        NSString *cssPath = [NSString stringWithFormat:@"%@%@", _opsPath, [_mainifest objectForKey:@"css"]];
        NSError *error;
        NSString *cssStr = [[NSString alloc]initWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:&error];
        if(error || [cssStr containsString:kBookContentDiv]){
            return;
        }
        NSString *bookcontent = [NSString stringWithFormat:@"%@ {padding-left: 20px;padding-right: 20px;}", kBookContentDiv];
        cssStr = [cssStr stringByAppendingString:bookcontent];
        //修改body样式
        [cssStr writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"error=%@", error);
    }
}
@end
