//
//  YLFlipPopTransition.m
//  YLEpubReader
//
//  Created by ApesTalk on 2020/6/10.
//  Copyright © 2020 https://github.com/ApesTalk. All rights reserved.
//

#import "YLFlipPopTransition.h"

@interface YLFlipPopTransition()
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toView;
@end


@implementation YLFlipPopTransition
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
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.hidden = YES;
    
    //动画发生的容器
    UIView *containerView = [transitionContext containerView];
    UIView *superView = containerView.superview;
    [[UIApplication sharedApplication].keyWindow addSubview:containerView];
    
    //获得移动之前的视图的截图，将之前的视图隐藏
    UIView *snapShotView = [self.fromView snapshotViewAfterScreenUpdates:YES];
    snapShotView.frame = [containerView convertRect:self.fromView.frame fromView:self.fromView.superview];
        
    //设置第二个控制器的位置，透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    
    //把动画前后的两个UIViewController加到容器中  snapShotView在上方
    [containerView addSubview:toVC.view];
    [containerView addSubview:snapShotView];
    
    //每次改了AnchorPoint， frame 都会改变，所以要重置frame
    CGRect oldFrame = snapShotView.frame;
    snapShotView.layer.anchorPoint = CGPointMake(0.0, 0.5);
    snapShotView.frame = oldFrame;
    snapShotView.transform = CGAffineTransformScale(self.fromView.transform, -0.5, 1.0);

    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        snapShotView.transform = CGAffineTransformScale(self.fromView.transform, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.toView.hidden = NO;
        self.fromView.hidden = NO;
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            toVC.view.alpha = 1;
            snapShotView.frame = [containerView convertRect:self.toView.frame fromView:self.toView.superview];
        } completion:^(BOOL finished) {
            [snapShotView removeFromSuperview];
            [superView addSubview:containerView];

            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}
@end
