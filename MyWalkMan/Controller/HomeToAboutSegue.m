//
//  HomeToAboutSegue.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "HomeToAboutSegue.h"
#import "HomeViewController.h"
#import "RegardToViewController.h"

@implementation HomeToAboutSegue

- (UIImage* )createImageFromView: (UIView* )view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)perform
{
    UIViewController* currentVC = self.sourceViewController;
    UIViewController* nextVC = self.destinationViewController;
    
    int style = arc4random() % 2;
    UIImage* currentImg = [self createImageFromView:[[UIApplication sharedApplication].delegate window]];
    UIImage* nextImg = [self createImageFromView:nextVC.view];
    UIView* maskView= [[[UIView alloc] initWithFrame:CGRectMake(0, 0, currentImg.size.width, [UIScreen mainScreen].bounds.size.height)] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication].delegate window] addSubview:maskView];
    
    int addtionOffset = 20;
    if (nextImg.size.height == [UIScreen mainScreen].bounds.size.height)
    {
        addtionOffset = 0;
    }
    
    float offset = [UIScreen mainScreen].bounds.size.width * 0.1;
    
    UIImageView* nextImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(offset, offset + addtionOffset, nextImg.size.width - offset * 2, nextImg.size.height - offset * 2 - 20)] autorelease];
    nextImgView.image = nextImg;
    nextImgView.alpha = 0.4f;
    [maskView addSubview:nextImgView];
    
    UIImageView* leftCurtain = [[[UIImageView alloc] initWithFrame:CGRectNull] autorelease];
    leftCurtain.image = currentImg;
    leftCurtain.clipsToBounds = YES;
    [maskView addSubview:leftCurtain];
    
    UIImageView* rightCurtain = [[[UIImageView alloc] initWithFrame:CGRectNull] autorelease];
    rightCurtain.image = currentImg;
    rightCurtain.clipsToBounds = YES;
    [maskView addSubview:rightCurtain];
    
    if (style == 0)
    {
        leftCurtain.contentMode = UIViewContentModeLeft;
        leftCurtain.frame = CGRectMake(0, 0, currentImg.size.width / 2, currentImg.size.height);
        rightCurtain.contentMode = UIViewContentModeRight;
        rightCurtain.frame = CGRectMake(currentImg.size.width / 2, 0, currentImg.size.width / 2, currentImg.size.height);
    }
    else
    {
        leftCurtain.contentMode = UIViewContentModeTop;
        leftCurtain.frame = CGRectMake(0, 0, currentImg.size.width, currentImg.size.height / 2);
        rightCurtain.contentMode = UIViewContentModeBottom;
        rightCurtain.frame = CGRectMake(0, currentImg.size.height / 2, currentImg.size.width, currentImg.size.height / 2);
    }
    
    [UIView animateWithDuration:0.7 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (style == 0)
        {
            leftCurtain.frame = CGRectMake(- currentImg.size.width / 2, 0, currentImg.size.width / 2, currentImg.size.height);
            rightCurtain.frame = CGRectMake(currentImg.size.width, 0, currentImg.size.width / 2, currentImg.size.height);
        }
        else
        {
            leftCurtain.frame = CGRectMake(0, - currentImg.size.height / 2, currentImg.size.width, currentImg.size.height / 2);
            rightCurtain.frame = CGRectMake(0, currentImg.size.height, currentImg.size.width, currentImg.size.height / 2);
        }
    } completion:nil];
    
    [UIView animateWithDuration:0.3f delay:0.4f options:UIViewAnimationOptionCurveEaseIn animations:^{
        nextImgView.frame = CGRectMake(0, addtionOffset, nextImg.size.width, nextImg.size.height);
        nextImgView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        if ([currentVC isKindOfClass:[HomeViewController class]])
            [currentVC presentModalViewController:nextVC animated:NO];
        else
            [currentVC dismissModalViewControllerAnimated:NO];
        
        [leftCurtain removeFromSuperview];
        [rightCurtain removeFromSuperview];
        [nextImgView removeFromSuperview];
        [maskView removeFromSuperview];
    }];
}

@end
