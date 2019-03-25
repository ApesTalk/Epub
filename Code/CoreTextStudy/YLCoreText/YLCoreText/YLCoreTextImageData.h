//
//  YLCoreTextImageData.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface YLCoreTextImageData : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSInteger position;

@property(nonatomic,assign)CGRect imagePosition;//CoreText的坐标系，而不是UIKit的坐标系

@end
//用于记录图片信息
