//
//  YLCoreTextLinkData.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/22.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YLCoreTextLinkData : NSObject
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,assign)NSRange range;

@end
//用于记录链接信息
