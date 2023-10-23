//
//  YLNavigationDelegate.m
//  YLEpubReader
//
//  Created by ApesTalk on 2020/6/10.
//  Copyright © 2020 https://github.com/ApesTalk. All rights reserved.
//

#import "YLNavigationDelegate.h"
#import "YLFlipPushTransition.h"
#import "YLFlipPopTransition.h"
#import "YLBaseViewController.h"

@implementation YLNavigationDelegate
#pragma mark ---UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if(![fromVC conformsToProtocol:@protocol(CustomTransitionController)] || ![toVC conformsToProtocol:@protocol(CustomTransitionController)]) return nil;
    UIView *fromView = [fromVC performSelector:@selector(transitionView)];
    UIView *toView = [toVC performSelector:@selector(transitionView)];
    if(operation == UINavigationControllerOperationPush){
        YLFlipPushTransition *transition = [[YLFlipPushTransition alloc] initWithFromView:fromView toView:toView];
        return transition;
    }else if(operation == UINavigationControllerOperationPop){
        YLFlipPopTransition *transition = [[YLFlipPopTransition alloc] initWithFromView:fromView toView:toView];
        return transition;
    }
    return nil;
}

@end
