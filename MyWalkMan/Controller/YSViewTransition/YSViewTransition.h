//
//  YSViewTransition.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    push = 0,
    curtainPush
}YS_PUSH;

typedef enum
{
    pop = 0,
    curtainPop
}YS_POP;


@interface YSViewTransition : NSObject

+ (void)YSPushViewController: (UIViewController* )destinaionViewController FromViewController: (UIViewController* )sourceViewController;
+ (void)YSPopViewController: (UIViewController* )sourceViewController ToViewController: (UIViewController* )destinaionViewController;

@end
