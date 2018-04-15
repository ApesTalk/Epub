//
//  YLXMLManager.h
//  YLEpubReader
//
//  Created by lumin on 2018/4/15.
//  Copyright © 2018年 https://github.com/lqcjdx. All rights reserved.
//  解析xml

#import <Foundation/Foundation.h>

@class YLXMLManager;
@class YLEpub;
@protocol YLXMLManagerDelegate <NSObject>
- (void)xmlManager:(YLXMLManager *)manager didFoundFullPath:(NSString *)fullPath;
- (void)xmlManager:(YLXMLManager *)manager failedParseWithError:(NSError *)error;
- (void)xmlManager:(YLXMLManager *)manager didFinishParsing:(YLEpub *)epub;
@end


@interface YLXMLManager : NSObject
@property (nonatomic, weak) id<YLXMLManagerDelegate> delegate;
- (void)parseXMLAtPath:(NSString *)xmlPath;
@end
