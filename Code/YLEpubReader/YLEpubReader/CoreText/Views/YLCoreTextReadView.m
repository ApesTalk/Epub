//
//  YLCoreTextReadView.m
//  YLEpubReader
//
//  Created by lumin on 2023/8/17.
//  Copyright © 2023 https://github.com/ApesTalk. All rights reserved.
//

#import "YLCoreTextReadView.h"
#import <DTCoreText/DTCoreText.h>
#import "YLReadManager.h"
#import "YLStatics.h"
#import "YLEpub.h"
#import "YLEpubChapter.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>

@interface YLCoreTextReadView ()<DTAttributedTextContentViewDelegate>
@property (nonatomic, strong) DTAttributedTextView *textView;
@property (nonatomic, strong) NSMutableAttributedString *readAttributedContent;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) NSInteger chapterNum;
@property (nonatomic, assign) NSInteger pageNum;

@property (nonatomic, strong) YLEpubChapter *chapterModel;
@end

@implementation YLCoreTextReadView
- (instancetype)initWithFrame:(CGRect)frame chapterNum:(NSInteger)chapterNum pageNum:(NSInteger)pageNum {
    if (self = [super initWithFrame:frame]) {
        self.chapterNum = chapterNum;
        self.pageNum = pageNum;
        self.chapterModel = CurrentReadBook.chapters[self.chapterNum];
        NSMutableAttributedString *pageAttributeString = self.chapterModel.pageAttributeStrings[self.pageNum];
        _readAttributedContent = pageAttributeString;
        self.content = pageAttributeString.string;
        
        [self createUI];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//
//    CGRect leftDot,rightDot = CGRectZero;
//    _menuRect = CGRectZero;
//
//    //绘制选中区域的背景色
//    [self drawSelectedPath:_pathArray leftDot:&leftDot rightDot:&rightDot];
//
//    //绘制选中区域前后的大头针
//    [self drawDotWithLeft:leftDot right:rightDot];
//}

- (void)createUI{
    [self setBackgroundColor:[UIColor whiteColor]];
//    [self addGestureRecognizer:({
//        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//        longPress;
//    })];
//    [self addGestureRecognizer:({
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//        pan.enabled = NO;
//        _pan = pan;
//        pan;
//    })];
    
    
    CGRect frame = self.bounds;
    _textView = [[DTAttributedTextView alloc] initWithFrame:frame];
    _textView.shouldDrawImages = YES;
    _textView.shouldDrawLinks = YES;
    _textView.textDelegate = self; // delegate for custom sub views
    _textView.backgroundColor = [UIColor clearColor];
    _textView.attributedTextContentView.edgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    //新版本
//    _textView.contentInset = UIEdgeInsetsMake(20, 20, 20, 20);
    [self addSubview:_textView];
    _textView.attributedString = self.readAttributedContent;

    UIView *backView = [[UIView alloc] initWithFrame:_textView.bounds];
//    backView.backgroundColor = [UIColor redColor];
    _textView.backgroundView = backView;
}

// DTAttributedTextContentViewDelegate
- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
              viewForAttributedString:(NSAttributedString *)string
                                frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    
    DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                    viewForAttachment:(DTTextAttachment *)attachment
                                frame:(CGRect)frame{
    
    if ([attachment isKindOfClass:[DTImageTextAttachment class]])
    {
        
        // if the attachment has a hyperlinkURL then this is currently ignored
        DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
        //        imageView.delegate = self;
        imageView.userInteractionEnabled = YES;
        // sets the image if there is one
        imageView.image = [(DTImageTextAttachment *)attachment image];
        // url for deferred loading
        imageView.url = attachment.contentURL;
        if (attachment.contentURL || attachment.hyperLinkURL) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
            [imageView addGestureRecognizer:tap];
        }
        
//        if (attachment.hyperLinkURL) {
//            imageView.hyperLinkURL = attachment.hyperLinkURL;// if there is a hyperlink
//        }
        
        return imageView;
    }else if ([attachment isKindOfClass:[DTObjectTextAttachment class]]) {
        // somecolorparameter has a HTML color
        NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
        UIColor *someColor = DTColorCreateWithHTMLName(colorName);
        
        UIView *someView = [[UIView alloc] initWithFrame:frame];
        someView.backgroundColor = someColor;
        someView.layer.borderWidth = 1;
        someView.layer.borderColor = [UIColor blackColor].CGColor;
        
        someView.accessibilityLabel = colorName;
        someView.isAccessibilityElement = YES;
        
        return someView;
    }
    
    return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
 shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock
                            frame:(CGRect)frame
                          context:(CGContextRef)context
                   forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame {
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
    //    CGColorRef color = [textBlock.backgroundColor CGColor];
    CGColorRef color = [[UIColor groupTableViewBackgroundColor] CGColor];
    if (color) {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES;
}

- (void)handleImageTap:(UITapGestureRecognizer *)ges {
    DTLazyImageView *imageView = (DTLazyImageView *)ges.view;
    if (imageView.url){
        MWPhoto *photo = [[MWPhoto alloc] initWithURL:imageView.url];
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:@[photo]];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:browser animated:YES completion:^{
                    
        }];
    }
}

- (void)linkPushed:(UIControl *)sender {
    //TODO:超链接 目录
}

@end
