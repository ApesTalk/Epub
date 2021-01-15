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
@property (nonatomic, strong) NSMutableDictionary<NSString* , NSString*> *manifest;
@property (nonatomic, strong) NSMutableArray<NSString*> *spine;
@end

@implementation YLXMLManager
- (void)parseXMLAtPath:(NSString *)xmlPath
{
    if(!xmlPath || ![[NSFileManager defaultManager] fileExistsAtPath:xmlPath]){
        if([self.delegate respondsToSelector:@selector(xmlManager:failedParseWithError:)]){
            NSError *error = [[NSError alloc]initWithDomain:NSCocoaErrorDomain code:0 userInfo:@{NSFilePathErrorKey: @"XML路径异常"}];
            [self.delegate xmlManager:self failedParseWithError:error];
        }
        return;
    }
    //error: NSXMLParser does not support reentrant parsing
    dispatch_queue_t reentrantAvoidanceQueue = dispatch_queue_create("reentrantAvoidanceQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(reentrantAvoidanceQueue, ^{
        NSURL *folderPath = [NSURL fileURLWithPath:xmlPath];
        self.parser = [[NSXMLParser alloc]initWithContentsOfURL:folderPath];
        self.parser.delegate = self;
        self.parser.shouldProcessNamespaces = YES;
        [self.parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{});
}

#pragma mark---NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if([elementName isEqualToString:@"rootfile"]){
        NSString *fullPath = [attributeDict valueForKey:@"full-path"];
        if([self.delegate respondsToSelector:@selector(xmlManager:didFoundFullPath:)]){
            [self.delegate xmlManager:self didFoundFullPath:fullPath];
        }
        self.parser = nil;
    }else if ([elementName isEqualToString:@"package"]){
        //开始解析
        self.epub = [[YLEpub alloc]init];
    }else if ([elementName isEqualToString:@"metadata"]){
        //开始解析元数据
        self.metadata = [NSMutableDictionary dictionary];
    }else if ([qName hasPrefix:@"dc:"]){
        //qName=dc:title时 elementName=title
        self.valueString = [[NSMutableString alloc]init];
    }else if ([elementName isEqualToString:@"manifest"]){
        self.manifest = [NSMutableDictionary dictionary];
    }else if ([elementName isEqualToString:@"item"]){
        NSString *key = [attributeDict objectForKey:@"id"];
        NSString *value = [attributeDict objectForKey:@"href"];
        [self.manifest setValue:value forKey:key];
    }else if([elementName isEqualToString:@"spine"]){
        self.spine = [NSMutableArray array];
    }else if ([elementName isEqualToString:@"itemref"]){
        NSString *idref = [attributeDict objectForKey:@"idref"];
        [self.spine addObject:idref];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(self.valueString){
        [self.valueString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([qName hasPrefix:@"dc:"]){
        //qName=dc:title时 elementName=title
        [self.metadata setValue:self.valueString forKey:elementName];
    }else if ([elementName isEqualToString:@"metadata"]){
        //metadata解析完成
        [self.epub setMetadata:self.metadata];
    }else if ([elementName isEqualToString:@"manifest"]){
        //manifest解析完成
        self.epub.manifest = self.manifest.copy;
    }else if ([elementName isEqualToString:@"spine"]){
        //spine解析完成
        self.epub.spine = self.spine.copy;
    }else if ([elementName isEqualToString:@"package"]){
        //全部解析完成
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.spine.count];
        for(NSUInteger i = 0; i < self.spine.count; i++){
            NSString *idf = self.spine[i];
            NSString *href = [self.manifest objectForKey:idf];

            YLEpubChapter *chapter = [[YLEpubChapter alloc]init];
            chapter.index = i;
            chapter.title = idf;
            chapter.path = href;
            if(i > 0){
                YLEpubChapter *preChapter = arr[i - 1];
                preChapter.nextChapter = chapter;
                chapter.preChapter = preChapter;
            }
            [arr addObject:chapter];
        }
        self.epub.chapters = arr.copy;
        
        if([self.delegate respondsToSelector:@selector(xmlManager:didFinishParsing:)]){
            [self.delegate xmlManager:self didFinishParsing:self.epub];
        }
        self.parser = nil;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([self.delegate respondsToSelector:@selector(xmlManager:failedParseWithError:)]){
        [self.delegate xmlManager:self failedParseWithError:parseError];
    }
}
@end
