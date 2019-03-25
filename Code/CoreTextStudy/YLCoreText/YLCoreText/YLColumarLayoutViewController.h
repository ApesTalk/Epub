//
//  YLColumarLayoutViewController.h
//  YLCoreText
//
//  Created by ApesTalk on 16/7/26.
//  Copyright © 2016年 https://github.com/ApesTalk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLColumarLayoutViewController : UIViewController

@end
//将文本绘制在不同的列
/*
 严格来讲，Core Text本身在同一时刻只绘制一列并且不计算列的大小和位置。
 做这些操作之前调用Core Text将文本绘制到你计算的路径区域。
 
 */

/* [利用CGRectDivide进行布局](http://lldong.github.io/2014/06/12/cgrectdivide.html)
 void CGRectDivide (
 CGRect rect,
 CGRect *slice,
 CGRect *remainder,
 CGFloat amount,
 CGRectEdge edge
 );
 这个函数的功能很简单，就是将一个 CGRect 切割成两个 CGRect；其中，rect 参数是你要切分的对象；slice 是一个指向切出的 CGRect 的指针；remainder 是指向切割后剩下的 CGRect 的指针；amount 是你要切割的大小；最后一个参数 edge 是一个枚举值，代表 amount 开始计算的方向，假设 amount 为 10.0 那么：
 
 CGRectMinXEdge 代表在 rect 从左往右数 10 个单位开始切割
 CGRectMaxXEdge 代表在 rect 从右往左数 10 个单位开始切割
 CGRectMinYEdge 代表在 rect 从上往下数 10 个单位开始切割
 CGRectMaxYEdge 代表在 rect 从下往上数 10 个单位开始切割
 */
