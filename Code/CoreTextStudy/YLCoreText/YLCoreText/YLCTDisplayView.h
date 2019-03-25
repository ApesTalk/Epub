//
//  YLCTDisplayView.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/21.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLCoreTextData.h"

@interface YLCTDisplayView : UIView
@property(nonatomic,strong)YLCoreTextData *data;

@end
//持有CoreText类的实例，负责将CTFrameRef实例绘制到界面上
