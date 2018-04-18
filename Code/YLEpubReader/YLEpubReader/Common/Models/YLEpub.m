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
#import <UIKit/UIKit.h>

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
        NSInteger bodyIndex = [cssStr rangeOfString:@"body"].location;
        NSString *marigin = @"margin:0px";
        NSString *width = [NSString stringWithFormat:@"width:%.0fpx", kScreenWidth];
        NSString *height = [NSString stringWithFormat:@"height:%.0fpx", kScreenHeight];
        NSString *columnWidth = [NSString stringWithFormat:@"column-width:%.0fpx", kScreenWidth - kCSSPaddingLeft - kCSSPaddingRight];
        NSString *columnGap = @"column-gap:0px";
        NSString *textAlign = @"text-align:justify";
        NSString *wordBreak = @"word-wrap:break-word";
        NSString *cssAttributes = [NSString stringWithFormat:@"%@;\n%@;\n%@;\n%@;\n%@;\n%@;\n%@;", marigin, width, height, columnWidth, columnGap, textAlign, wordBreak];
        if(bodyIndex == NSNotFound){
            //新增body样式font-size: 1.0em;
            NSString *bodyCss = [NSString stringWithFormat:@"body {\n%@\n}", cssAttributes];
            cssStr = [cssStr stringByAppendingString:bodyCss];
        }else{
            //修改body样式
            NSString *subStr = [cssStr substringFromIndex:bodyIndex + 4];
            NSInteger beginIndex = [subStr rangeOfString:@"{"].location;
            if(beginIndex != NSNotFound){
                NSInteger endIndex = [subStr rangeOfString:@"}"].location;
                if(endIndex != NSNotFound){
                    NSMutableArray *newCssKeyValues = [NSMutableArray arrayWithObjects:marigin, width, height, columnWidth, columnGap, textAlign, wordBreak, nil];
                    NSString *bodyCss = [subStr substringWithRange:NSMakeRange(beginIndex + 1, endIndex - 2)];
                    NSRange bodyCssRange = [cssStr rangeOfString:bodyCss];
                    NSArray *keyValues = [bodyCss componentsSeparatedByString:@";"];
                    for(NSString *keyValueStr in keyValues){
                        NSArray *components = [keyValueStr componentsSeparatedByString:@":"];
                        if(components.count == 2){
                            NSString *key = [components[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                            //移除margin-top/left/right/bottom等属性
                            if(!([key hasPrefix:@"margin"] || [key hasPrefix:@"padding"] || [key hasPrefix:@"height"] || [key hasPrefix:@"column"] || [key hasPrefix:@"text-align"] || [key hasPrefix:@"word-wrap"]) && keyValueStr.length > 0){
                                [newCssKeyValues addObject:keyValueStr];
                            }
                        }
                    }
                    //组合字符串
                    NSString *joinedStr = [newCssKeyValues componentsJoinedByString:@";\n"];
                    NSString *newBodyCss = [NSString stringWithFormat:@"\n%@;\n", joinedStr];
                    cssStr = [cssStr stringByReplacingCharactersInRange:bodyCssRange withString:newBodyCss];
                    NSLog(@"");
                }
            }
        }
        //设置div样式以及图片样式（不跨栏展示）
        NSString *bookContent = [NSString stringWithFormat:@".%@ {\n"
                                                                    "padding-left: %dpx;\n"
                                                                    "padding-right: %dpx;\n"
                                                                    "img,.cover,cover,h1,h2,h3,h4,h5,h6{\n"
                                                                            "display: block;\n"
                                                                            "column-span: 1;\n"
                                                                            "width: auto;\n"
                                                                            "height: auto;\n"
                                                                            "max-width: %.0fpx;\n"
                                                                            "max-height: %.0fpx;\n"
                                                                "}\n", kBookContentDiv, kCSSPaddingLeft, kCSSPaddingRight,kScreenWidth,kScreenHeight];
        NSString *img = [NSString stringWithFormat:@".%@ img {\n"
                                                                "display: block;\n"
                                                                "column-span: 1;\n"
                                                                "width: auto;\n"
                                                                "height: auto;\n"
                                                                "max-width: %.0fpx;\n"
                                                                "max-height: %.0fpx;\n"
                                                            "}\n", kBookContentDiv, kScreenWidth, kScreenHeight];
        cssStr = [cssStr stringByAppendingString:bookContent];
//        cssStr = [cssStr stringByAppendingString:img];
        //修改body样式
        [cssStr writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"error=%@", error);
    }
}
@end
