//
//  YSViewTransitionSegue.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSViewTransitionSegue.h"
#import "YSViewTransition.h"

@implementation YSViewTransitionSegue

- (void)perform
{
    [YSViewTransition YSPushViewController:self.destinationViewController FromViewController:self.sourceViewController];
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
}

@end
