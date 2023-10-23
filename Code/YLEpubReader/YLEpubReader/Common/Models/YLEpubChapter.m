//
//  YLEpubChapter.m
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLEpubChapter.h"
#import <DTCoreText/DTCoreText.h>
#import "YLReadManager.h"
#import "YLStatics.h"
#import "YLEpub.h"

@interface YLEpubChapter ()
@property (nonatomic, assign) CGRect showBounds;

@property (nonatomic, strong, readwrite) NSAttributedString *chapterAttributeContent;///全章的富文本
@property (nonatomic, copy, readwrite) NSString *chapterContent;//全章的out文本
@property (nonatomic, copy, readwrite) NSArray *pageAttributeStrings;//每一页的富文本
@property (nonatomic, copy, readwrite) NSArray *pageStrings;//每一页的普通文本
@property (nonatomic, copy, readwrite) NSArray *pageLocations;//每一页在章节中的位置
@property (nonatomic, assign, readwrite) NSInteger pageCount;//章节总页数
@end

@implementation YLEpubChapter
- (void)paginateEpubWithBounds:(CGRect)bounds {
    @autoreleasepool {
        self.showBounds = bounds;
        // Load HTML data
        NSAttributedString *chapterAttributeContent = [self attributedStringForSnippet];
//        chapterAttributeContent = [self addLineForNotes:chapterAttributeContent];
        
        NSMutableArray *pageAttributeStrings = [NSMutableArray arrayWithCapacity:0];//每一页的富文本
        NSMutableArray *pageStrings = [NSMutableArray arrayWithCapacity:0];//每一页的普通文本
        NSMutableArray *pageLocations = [NSMutableArray arrayWithCapacity:0];//每一页在章节中的位置
        
        DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:chapterAttributeContent];
        NSRange visibleStringRang;
        DTCoreTextLayoutFrame *visibleframe;
        NSInteger rangeOffset = 0;
        do {
            @autoreleasepool {
                visibleframe = [layouter layoutFrameWithRect:bounds range:NSMakeRange(rangeOffset, 0)];
                visibleStringRang = [visibleframe visibleStringRange];
                NSAttributedString *subAttStr = [chapterAttributeContent attributedSubstringFromRange:NSMakeRange(visibleStringRang.location, visibleStringRang.length)];
                
                NSMutableAttributedString *mutableAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:subAttStr];
                [pageAttributeStrings addObject:mutableAttStr];
                
                if(subAttStr){
                    [pageStrings addObject:subAttStr.string];
                }
                [pageLocations addObject:@(visibleStringRang.location)];
                rangeOffset += visibleStringRang.length;
                
            }
            
        } while (visibleStringRang.location + visibleStringRang.length < chapterAttributeContent.string.length);
        
        visibleframe = nil;
        layouter = nil;
        
        self.chapterAttributeContent = chapterAttributeContent;
        self.chapterContent = chapterAttributeContent.string;
        self.pageAttributeStrings = pageAttributeStrings;
        self.pageStrings = pageStrings;
        self.pageLocations = pageLocations;
        self.pageCount = self.pageLocations.count;
        
    }
}

- (NSAttributedString *)attributedStringForSnippet {
    NSString *html = @"";
    NSString *readmePath = @"";
    if (self.path.length) {
        //load epub
        NSString *fileName = [NSString stringWithFormat:@"%@%@", CurrentReadBook.opsFolderPath, self.path];
        readmePath = fileName;
        
//        NSString *decodeURL = [readmePath stringByRemovingPercentEncoding];
//        NSString *encodeURL = [readmePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:decodeURL]) {
//            NSLog(@"======存在");
//            readmePath = decodeURL;
//        }
//
//        if ([[NSFileManager defaultManager] fileExistsAtPath:encodeURL]) {
//            NSLog(@"======存在");
//            readmePath = encodeURL;
//        }
//
        html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
//        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
//        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"<p></p>"];
//        html = [html stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
        
        
        
//        NSRange fileNameLastConR = [fileName rangeOfString:@"(/)([^/]+)$" options:NSRegularExpressionSearch];
//        NSString *imageRootPath = [fileName substringToIndex:fileNameLastConR.location];
//
//        NSString *imageSrcRegex = @"(src=)([\"'])((../)*)";
//
//        NSRange imageSrcRang = [html rangeOfString:imageSrcRegex options:NSRegularExpressionSearch];
//
//        if (imageSrcRang.location != NSNotFound) {
//
//        }
        
//        NSString *imagePath = [@"src=\"" stringByAppendingString:CurrentReadBook.opsFolderPath];
//        html = [html stringByReplacingOccurrencesOfString:@"src=\".." withString:imagePath];
    }
    
    //get image resources
//    [self separatePicturesFromHtml:html];
    
//    [self insertMarkForIdAttributeFromHtml:&html];
    
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    // Create attributed string from HTML
    // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
    void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        
        // the block is being called for an entire paragraph, so we check the individual elements
        
        for (DTHTMLElement *oneChildElement in element.childNodes) {
            // if an element is larger than twice the font size put it in it's own block
            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
            {
                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
            }
        }
    };
    
    
//    [self isReadConfigChanged];
//    XDSReadConfig *config = self.currentConfig;
//    CGFloat fontSize = (config.currentFontSize > 1)?config.currentFontSize:config.cachefontSize;
//    UIColor *textColor = config.currentTextColor?config.currentTextColor:config.cacheTextColor;
//    NSString *fontName = config.currentFontName?config.currentFontName:config.cacheFontName;

    CGFloat fontSize = kEpubFontSize;
    UIColor *textColor = kEpubFontColor;
    NSString *fontName = @"";
    //!!!!: 设置字体颜色图片大小
    CGSize maxImageSize = CGSizeMake(_showBounds.size.width - 20, _showBounds.size.height);
    
    NSDictionary *dic = @{NSTextSizeMultiplierDocumentOption:@(fontSize/11.0),
                          DTDefaultLineHeightMultiplier:@1.5,
                          DTMaxImageSize:[NSValue valueWithCGSize:maxImageSize],
                          DTDefaultLinkColor:@"purple",
                          DTDefaultLinkHighlightColor:@"red",
                          DTDefaultTextColor:textColor,
                          DTDefaultFontName:fontName,
//                          DTWillFlushBlockCallBack:callBackBlock,
                          DTDefaultTextAlignment:@(NSTextAlignmentJustified),
                          };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (readmePath.length) {
        [options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];
    }
    NSAttributedString *attString = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
//    [self getIdMarkLocationAndReplaceIt:&attString];
    return attString;
}
@end
