//
//  UIView+AOP.m
//  testPubb
//
//  Created by lumin on 2018/4/21.
//

#import "UIView+AOP.h"
#import <objc/runtime.h>

@implementation UIView (AOP)
void swizzleMethod(Class class,SEL originalSelector,SEL swizzledSelector){
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    //注意class_addMethod会覆盖父类方法的实现，但是不会替换父类已经存在的方法实现。如果要改变已经存在的方法实现，使用method_setImplementation。
    //这里只是尝试覆盖父类方法的实现，如果父类没有对应方法的实现，则覆盖成功，否则覆盖失败。
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if(didAddMethod){
        //如果要替换的方法存在，它调用的是class_addMethod。如果要替换的方法不存在，它调用的是method_setImplementation。
        //这里在覆盖父类方法成功的情况下，尝试用父类原有的方法的实现替换新增方法的实现。
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        //这里在覆盖父类方法失败的情况下，交换两个两个方法的实现。
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //When Swizzling a instance method,use the following:
        Class class = [self class];
        //When Swizzling a class method, use the following:
        //        Class class = object_getClass((id)self);
        swizzleMethod(class, @selector(setBackgroundColor:), @selector(aop_setBackgroundColor:));
        swizzleMethod(class, @selector(willMoveToSuperview:), @selector(aop_willMoveToSuperview:));
    });
}

- (void)aop_setBackgroundColor:(UIColor *)color
{
    if([NSStringFromClass([self.superview.superview class])isEqualToString:@"UITextRangeView"]){
        [self aop_setBackgroundColor:[UIColor colorWithRed:194/255.0 green:228/255.0 blue:193/255.0 alpha:0.5]];
    }else{
        [self aop_setBackgroundColor:color];
    }
}

- (void)aop_willMoveToSuperview:(UIView *)view
{
    NSString *className = NSStringFromClass([self class]);
    if([className isEqualToString:@"UISelectionGrabber"] || [className isEqualToString:@"UISelectionGrabberDot"]){
        UIView *coverView = [self viewWithTag:10000];
        if(!coverView){
            coverView = [[UIView alloc]initWithFrame:self.bounds];
            coverView.tag = 10000;
            [self addSubview:coverView];
        }
        if([className isEqualToString:@"UISelectionGrabberDot"]){
            coverView.layer.cornerRadius = self.bounds.size.width * 0.5;
            coverView.layer.masksToBounds = YES;
        }
        coverView.backgroundColor = [UIColor colorWithRed:194/255.0 green:228/255.0 blue:193/255.0 alpha:1.0];
    }
    [self aop_willMoveToSuperview:view];
}

@end
