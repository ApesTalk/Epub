//
//  YLXMLManager.h
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//  解析xml

#import <Foundation/Foundation.h>

@class YLXMLManager;
@class YLEpub;
@protocol YLXMLManagerDelegate <NSObject>
- (void)xmlManager:(YLXMLManager *)manager failedParseWithError:(NSError *)error;
- (void)xmlManagerFinishParse:(YLXMLManager *)manager;
@end

typedef NS_ENUM(NSInteger, ParseType) {
    ParseTypeContainer,
    ParseTypeOPF,
    ParseTypeNCX
};

@interface YLXMLManager : NSObject
@property (nonatomic, assign, readonly) ParseType parseType;
@property (nonatomic, strong, readonly) NSString *opfPath;///< 相对路径
@property (nonatomic, strong, readonly) NSString *ncxPath;///< 相对路径
@property (nonatomic, strong, readonly) YLEpub *epub;
@property (nonatomic, weak) id<YLXMLManagerDelegate> delegate;
- (void)parseXMLAtPath:(NSString *)xmlPath;
@end
