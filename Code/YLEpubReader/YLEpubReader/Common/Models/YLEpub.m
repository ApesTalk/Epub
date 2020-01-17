//
//  YLEpub.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/14.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLEpub.h"
#import "YLEpubManager.h"
#import "YLStatics.h"
#import <UIKit/UIKit.h>

@implementation YLEpub
- (instancetype)initWithName:(NSString *)name filePath:(NSString *)path
{
    if(self = [super init]){
        self.name = name;
        self.filePath = path;
    }
    return self;
}

- (void)setMetadata:(NSDictionary *)metadata
{
    for(NSString *key in metadata.allKeys){
        NSString *value = [metadata valueForKey:key];
        if([key isEqualToString:@"title"]){
            self.title = value;
        }else if ([key isEqualToString:@"identifier"]){
            self.identifier = value;
        }else if([key isEqualToString:@"language"]){
            self.language = value;
        }else if ([key isEqualToString:@"creator"]){
            self.creator = value;
        }else if([key isEqualToString:@"publisher"]){
            self.publisher = value;
        }else if ([key isEqualToString:@"description"]){
            self.descript = value;
        }else if([key isEqualToString:@"coverage"]){
            self.coverage = value;
        }else if ([key isEqualToString:@"source"]){
            self.source = value;
        }else if([key isEqualToString:@"date"]){
            self.date = value;
        }else if ([key isEqualToString:@"rights"]){
            self.rights = value;
        }else if([key isEqualToString:@"subject"]){
            self.subject = value;
        }else if ([key isEqualToString:@"contributor"]){
            self.contributor = value;
        }else if([key isEqualToString:@"type"]){
            self.type = value;
        }else if ([key isEqualToString:@"format"]){
            self.format = value;
        }else if([key isEqualToString:@"relation"]){
            self.relation = value;
        }else if ([key isEqualToString:@"builder"]){
            self.builder = value;
        }else if([key isEqualToString:@"builder_version"]){
            self.builderVersion = value;
        }
    }
}

- (NSString *)coverPath
{
    NSString *coverImage = [self.mainifest objectForKey:@"cover-image"];
    if(coverImage && self.opsPath){
        NSString *path = [NSString stringWithFormat:@"%@%@", self.opsPath, coverImage];
        return path;
    }
    return nil;
}

- (NSString *)localBookContentPath
{
    return self.opsPath;
    return [YLEpubManager unZipedFolderPathForEpubName:self.name?:@""];
}

- (void)modifyCss
{
    //修改body样式，添加bookcontent样式
    if(self.opsPath && self.mainifest && [self.mainifest objectForKey:@"css"]){
        NSString *cssPath = [NSString stringWithFormat:@"%@%@", self.opsPath, [self.mainifest objectForKey:@"css"]];
        NSError *error;
        NSString *cssStr = [[NSString alloc]initWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:&error];
        if(error || [cssStr containsString:kBookContentDiv]){
            NSLog(@"cssStr=%@", cssStr);
            return;
        }
        NSInteger bodyIndex = [cssStr rangeOfString:@"body"].location;
        NSString *marigin = @"margin:0px";
        NSString *width = [NSString stringWithFormat:@"width:%.0fpx", kEpubViewWidth];
        NSString *height = [NSString stringWithFormat:@"height:%.0fpx", kEpubViewHeight];
        NSString *columnWidth = [NSString stringWithFormat:@"column-width:%.0fpx", kEpubViewWidth - kCSSPaddingLeft - kCSSPaddingRight];
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
                }
            }
        }
        //设置封面全屏
//        NSString *cover = [NSString stringWithFormat:@".cover,cover {\n height:100%%; padding-left:-%dpx; padding-right:-%dpx; \n}\n", 2*kCSSPaddingLeft,2*kCSSPaddingRight];//
        //设置div样式以及图片样式（不跨栏展示）.cover,cover,
        NSString *bookContent = [NSString stringWithFormat:@".%@ {\n"
                                                                    "padding-left: %dpx;\n"
                                                                    "padding-right: %dpx;\n"
                                                                    "img,h1,h2,h3,h4,h5,h6{\n"
                                                                            "display: block;\n"
                                                                            "column-span: 1;\n"
                                                                            "width: auto;\n"
                                                                            "height: auto;\n"
                                                                            "max-width: %.0fpx;\n"
                                                                            "max-height: %.0fpx;\n"
                                                                "}}\n", kBookContentDiv, kCSSPaddingLeft, kCSSPaddingRight, kEpubViewWidth, kEpubViewHeight];
        NSString *img = [NSString stringWithFormat:@".%@ img {\n"
                                                                "display: block;\n"
                                                                "column-span: 1;\n"
                                                                "width: auto;\n"
                                                                "height: auto;\n"
                                                                "max-width: %.0fpx;\n"
                                                                "max-height: %.0fpx;\n"
                                                            "}\n", kBookContentDiv, kEpubViewWidth, kEpubViewHeight];
        
//        cssStr = [cssStr stringByAppendingString:cover];
        cssStr = [cssStr stringByAppendingString:bookContent];
//        cssStr = [cssStr stringByAppendingString:img];
        //修改body样式
        [cssStr writeToFile:cssPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSLog(@"cssStr=%@", cssStr);
        NSLog(@"error=%@", error);
    }
}
@end
