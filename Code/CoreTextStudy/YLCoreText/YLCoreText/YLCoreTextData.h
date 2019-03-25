//
//  YLCoreTextData.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface YLCoreTextData : NSObject
@property(nonatomic,assign)CTFrameRef ctFrame;
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,strong)NSArray *imageArray;
@property (nonatomic,strong) NSArray *linkArray;

@end
//用户保存由YLCTFrameParser生成的CTFrameRef实例，以及CTFrameRef实例绘制需要的高度
