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
#import "YLBookShelfController.h"
#import "YLBookReadController.h"

@implementation YLNavigationDelegate
#pragma mark ---UINavigationControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if(operation == UINavigationControllerOperationPush &&
       [fromVC isKindOfClass:[YLBookShelfController class]] &&
       [toVC isKindOfClass:[YLBookReadController class]]){
        YLFlipPushTransition *transition = [[YLFlipPushTransition alloc]initWithFromView:((YLBookShelfController*)fromVC).transitionView toView:((YLBookReadController*)toVC).transitionView];
        return transition;
    }else if(operation == UINavigationControllerOperationPop &&
             [fromVC isKindOfClass:[YLBookReadController class]] &&
             [toVC isKindOfClass:[YLBookShelfController class]]){
        YLFlipPopTransition *transition = [[YLFlipPopTransition alloc]initWithFromView:((YLBookReadController*)fromVC).transitionView toView:((YLBookShelfController*)toVC).transitionView];
        return transition;
    }
    return nil;
}

@end
