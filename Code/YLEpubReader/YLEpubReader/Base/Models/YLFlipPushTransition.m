//
//  YLFlipPushTransition.m
//  YLEpubReader
//
//  Created by ApesTalk on 2020/6/10.
//  Copyright © 2020 https://github.com/ApesTalk. All rights reserved.
//

#import "YLFlipPushTransition.h"

@interface YLFlipPushTransition()
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, strong) UIView *toView;
@end

@implementation YLFlipPushTransition
- (instancetype)initWithFromView:(UIView *)fromView toView:(UIView *)toView;
{
    if(self = [super init]){
        self.fromView = fromView;
        self.toView = toView;
    }
    return self;
}

//动画过渡时间
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}
//动画效果实现
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    //动画过渡的两个UIViewController
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //动画发生的容器
    UIView *containerView = [transitionContext containerView];
    UIView *superView = containerView.superview;
    
    //获得移动之前的视图的截图，将之前的视图隐藏
    UIView *snapShotView = [self.fromView snapshotViewAfterScreenUpdates:NO];
    snapShotView.frame = [containerView convertRect:self.fromView.frame fromView:self.fromView.superview];
    self.fromView.hidden = YES;
        
    //设置第二个控制器的位置，透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    //把动画前后的两个UIViewController加到容器中  snapShotView在上方
    [[UIApplication sharedApplication].delegate.window addSubview:containerView];
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        toVC.view.alpha = 1.0;
        snapShotView.frame = [UIScreen mainScreen].bounds;
    } completion:^(BOOL finished) {
        self.toView.hidden = NO;
        self.fromView.hidden = NO;
        
        //每次改了AnchorPoint， frame 都会改变，所以要重置frame
        CGRect oldFrame = snapShotView.frame;
        snapShotView.layer.anchorPoint = CGPointMake(0.0, 0.5);
        snapShotView.frame = oldFrame;

        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            snapShotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, -0.5, 1.0);
        } completion:^(BOOL finished) {
            [snapShotView removeFromSuperview];
            [superView addSubview:containerView];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}
@end
