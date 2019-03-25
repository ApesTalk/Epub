//
//  YLXMLManager.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLXMLManager.h"
#import "YLEpub.h"

static NSString *package = @"package";


@interface YLXMLManager () <NSXMLParserDelegate>
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, strong) YLEpub *epub;
@property (nonatomic, strong) NSMutableDictionary *metadata;///< 元数据
@property (nonatomic, strong) NSMutableString *valueString;
@property (nonatomic, strong) NSMutableDictionary *manifest;
@property (nonatomic, strong) NSMutableArray *spine;
@end

@implementation YLXMLManager
- (void)parseXMLAtPath:(NSString *)xmlPath
{
    if(!xmlPath || ![[NSFileManager defaultManager] fileExistsAtPath:xmlPath]){
        if([_delegate respondsToSelector:@selector(xmlManager:failedParseWithError:)]){
            NSError *error = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSFilePathErrorKey: @"XML路径异常"}];
            [_delegate xmlManager:self failedParseWithError:error];
        }
        return;
    }
    //error: NSXMLParser does not support reentrant parsing
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        NSURL *folderPath = [NSURL fileURLWithPath:xmlPath];
        _parser = [[NSXMLParser alloc]initWithContentsOfURL:folderPath];
        _parser.delegate = self;
        _parser.shouldProcessNamespaces = YES;
        [_parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{});
}

#pragma mark---NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if([elementName isEqualToString:@"rootfile"]){
        NSString *fullPath = [attributeDict valueForKey:@"full-path"];
        if([_delegate respondsToSelector:@selector(xmlManager:didFoundFullPath:)]){
            [_delegate xmlManager:self didFoundFullPath:fullPath];
        }
        _parser = nil;
    }else if ([elementName isEqualToString:@"package"]){
        //开始解析
        _epub = [[YLEpub alloc]init];
    }else if ([elementName isEqualToString:@"metadata"]){
        //开始解析元数据
        _metadata = [NSMutableDictionary dictionary];
    }else if ([qName hasPrefix:@"dc:"]){
        //qName=dc:title时 elementName=title
        _valueString = [[NSMutableString alloc]init];
    }else if ([elementName isEqualToString:@"manifest"]){
        _manifest = [NSMutableDictionary dictionary];
    }else if ([elementName isEqualToString:@"item"]){
        NSString *key = [attributeDict objectForKey:@"id"];
        NSString *value = [attributeDict objectForKey:@"href"];
        [_manifest setValue:value forKey:key];
    }else if([elementName isEqualToString:@"spine"]){
        _spine = [NSMutableArray array];
    }else if ([elementName isEqualToString:@"itemref"]){
        NSString *idref = [attributeDict objectForKey:@"idref"];
        [_spine addObject:idref];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(_valueString){
        [_valueString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([qName hasPrefix:@"dc:"]){
        //qName=dc:title时 elementName=title
        [_metadata setValue:_valueString forKey:elementName];
    }else if ([elementName isEqualToString:@"metadata"]){
        //metadata解析完成
        [_epub setMetadata:_metadata];
    }else if ([elementName isEqualToString:@"manifest"]){
        //manifest解析完成
        _epub.mainifest = _manifest;
    }else if ([elementName isEqualToString:@"spine"]){
        //spine解析完成
        _epub.spine = _spine;
    }else if ([elementName isEqualToString:@"package"]){
        //全部解析完成
        if([_delegate respondsToSelector:@selector(xmlManager:didFinishParsing:)]){
            [_delegate xmlManager:self didFinishParsing:_epub];
        }
        _parser = nil;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([_delegate respondsToSelector:@selector(xmlManager:failedParseWithError:)]){
        [_delegate xmlManager:self failedParseWithError:parseError];
    }
}
@end
