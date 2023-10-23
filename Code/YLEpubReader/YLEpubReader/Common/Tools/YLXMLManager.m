//
//  YLXMLManager.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLXMLManager.h"
#import "YLEpub.h"
#import "YLEpubChapter.h"

static NSString *package = @"package";

@interface NavPoint : NSObject
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *navLabel;
@property (nonatomic, copy) NSString *content;
@end

@implementation NavPoint

@end

@interface YLXMLManager () <NSXMLParserDelegate>
@property (nonatomic, copy) NSString *xmlPath;
@property (nonatomic, strong) NSXMLParser *parser;
@property (nonatomic, assign, readwrite) ParseType parseType;
@property (nonatomic, strong, readwrite) NSString *opfPath;
@property (nonatomic, strong, readwrite) NSString *ncxPath;
@property (nonatomic, strong, readwrite) YLEpub *epub;
@property (nonatomic, strong) NSMutableDictionary *metadata;///< 元数据
@property (nonatomic, strong) NSMutableString *valueString;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *manifest;///< 包含ncx路径
@property (nonatomic, strong) NSMutableArray<NSString*> *spine;///< 书脊 读者线性阅读顺序
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*> *guide;///< 包含guide信息
//ncx
@property (nonatomic, strong) NSMutableArray<NavPoint*> *navMap;
@property (nonatomic, strong) NavPoint *navPoint;
@end

@implementation YLXMLManager
- (void)parseXMLAtPath:(NSString *)xmlPath
{
    self.xmlPath = xmlPath;
    if([self.xmlPath hasSuffix:@"container.xml"]){
        self.parseType = ParseTypeContainer;
    }else if ([self.xmlPath hasSuffix:@".opf"]){
        self.parseType = ParseTypeOPF;
    }else if ([self.xmlPath hasSuffix:@".ncx"]){
        self.parseType = ParseTypeNCX;
    }
    
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
        NSURL *path = [NSURL fileURLWithPath:xmlPath];
        self.parser = [[NSXMLParser alloc]initWithContentsOfURL:path];
        self.parser.delegate = self;
        self.parser.shouldProcessNamespaces = YES;
        [self.parser parse];
    });
    dispatch_sync(reentrantAvoidanceQueue, ^{});
}

#pragma mark---NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    //从contianer.xml中拿到xxx.opf
    if(self.parseType == ParseTypeContainer){
        if([elementName isEqualToString:@"rootfile"]){
            self.parser = nil;
            self.opfPath = [attributeDict valueForKey:@"full-path"];
            if([self.delegate respondsToSelector:@selector(xmlManagerFinishParse:)]){
                [self.delegate xmlManagerFinishParse:self];
            }
        }
        return;
    }
    
    if(self.parseType == ParseTypeOPF){
        if ([elementName isEqualToString:@"package"]){
            //开始解析opf
            self.epub = [[YLEpub alloc] init];
        }else if ([elementName isEqualToString:@"metadata"]){
            //开始解析元数据
            self.metadata = [NSMutableDictionary dictionary];
        }else if ([qName hasPrefix:@"dc:"]){
            //qName=dc:title时 elementName=title
            self.valueString = [[NSMutableString alloc] init];
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
        }else if ([elementName isEqualToString:@"guide"]){
            //有些电子书没有把这个放在阅读目录中
            self.guide = [NSMutableDictionary dictionary];
        }else if ([elementName isEqualToString:@"reference"]){
            [self.guide addEntriesFromDictionary:attributeDict];
        }
        return;
    }
    
    if(self.parseType == ParseTypeNCX){
        if ([elementName isEqualToString:@"navMap"]){
            self.navMap = [NSMutableArray array];
        }else if ([elementName isEqualToString:@"navPoint"]){
            self.navPoint = [NavPoint new];
            self.navPoint.Id = [attributeDict objectForKey:@"id"];//还有 playOrder
        }else if ([elementName isEqualToString:@"text"]){//navLabel中包含<text>标签
            self.valueString = [[NSMutableString alloc] init];
        }else if ([elementName isEqualToString:@"content"]){
            self.navPoint.content = [attributeDict objectForKey:@"src"];
        }
        return;
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
    if(self.parseType == ParseTypeOPF){
        if([qName hasPrefix:@"dc:"]){
            //qName=dc:title时 elementName=title
            [self.metadata setValue:self.valueString forKey:elementName];
        }else if ([elementName isEqualToString:@"metadata"]){
            //metadata解析完成
            [self.epub setMetadata:self.metadata];
        }else if ([elementName isEqualToString:@"manifest"]){
            //manifest解析完成
            self.epub.manifest = self.manifest;
        }else if ([elementName isEqualToString:@"spine"]){
            //spine解析完成
            self.epub.spine = self.spine;
        }else if ([elementName isEqualToString:@"package"]){
            self.parser = nil;
            NSString *folderName = [self.opfPath stringByDeletingLastPathComponent];
            self.ncxPath = [NSString stringWithFormat:@"%@/%@", folderName, [self.manifest objectForKey:@"ncx"]];
            if([self.delegate respondsToSelector:@selector(xmlManagerFinishParse:)]){
                [self.delegate xmlManagerFinishParse:self];
            }
        }
        return;
    }
    
    if(self.parseType == ParseTypeNCX){
        if ([elementName isEqualToString:@"navLabel"]){
            self.navPoint.navLabel = self.valueString;
        }else if ([elementName isEqualToString:@"navPoint"]){
            if(!self.navPoint) return;
            [self.navMap addObject:self.navPoint];
        }else if ([elementName isEqualToString:@"navMap"]){
            //目录全部解析完成
            self.parser = nil;
            //opt: 判断是否包含了 guide 补偿
            NavPoint *firstPoint = self.navMap.firstObject;
            if(![firstPoint.navLabel isEqualToString:[self.guide objectForKey:@"title"]] && ![firstPoint.content isEqualToString:[self.guide objectForKey:@"href"]]){
                NavPoint *coverPoint = [NavPoint new];
                coverPoint.navLabel = [self.guide objectForKey:@"title"];
                coverPoint.content = [self.guide objectForKey:@"href"];
                [self.navMap insertObject:coverPoint atIndex:0];
            }

            NSMutableArray<YLEpubChapter*> *chapters = [NSMutableArray arrayWithCapacity:self.navMap.count];
            for(NSUInteger i = 0; i < self.navMap.count; i++){
                NavPoint *point = self.navMap[i];
                YLEpubChapter *chapter = [[YLEpubChapter alloc] init];
                chapter.index = i;
                chapter.title = point.navLabel;
                //TODO:1.html#nav_point_1
                chapter.path = [point.content componentsSeparatedByString:@"#"].firstObject;
                if(i > 0){
                    YLEpubChapter *preChapter = chapters[i - 1];
                    preChapter.nextChapter = chapter;
                    chapter.preChapter = preChapter;
                }
                [chapters addObject:chapter];
            }
            self.epub.chapters = chapters;

            if([self.delegate respondsToSelector:@selector(xmlManagerFinishParse:)]){
                [self.delegate xmlManagerFinishParse:self];
            }
        }
        return;
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if([self.delegate respondsToSelector:@selector(xmlManager:failedParseWithError:)]){
        [self.delegate xmlManager:self failedParseWithError:parseError];
    }
}
@end
