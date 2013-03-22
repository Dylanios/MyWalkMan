//
//  HomeToAboutSegue.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "HomeToAboutSegue.h"

@implementation HomeToAboutSegue

- (void)perform
{
    UIViewController* current = self.sourceViewController;
    UIViewController* next = self.destinationViewController;
    [current presentModalViewController:next animated:YES];
}

@end
