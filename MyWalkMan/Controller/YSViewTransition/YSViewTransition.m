//
//  YSViewTransition.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSViewTransition.h"

@implementation YSViewTransition

#pragma mark - Public
+ (void)YSPushViewController: (UIViewController* )destinaionViewController FromViewController: (UIViewController* )sourceViewController
{
    int flag = arc4random() % 2;
    if (flag == 0)
        [self pushFromViewController:sourceViewController ToViewController:destinaionViewController];
    else
        [self curtainFromViewController:sourceViewController ToViewController:destinaionViewController];
}

+ (void)YSPopViewController: (UIViewController* )sourceViewController ToViewController: (UIViewController* )destinaionViewController
{
    int flag = arc4random() % 2;
    if (flag == 0)
        [self popFromViewController:sourceViewController ToViewController:destinaionViewController];
    else
        [self curtainFromViewController:sourceViewController ToViewController:destinaionViewController];
}

#pragma mark - Private
+ (UIImage* )createImageFromView: (UIView* )view
{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (void) pushFromViewController: (UIViewController* )sourceViewController ToViewController: (UIViewController* )destinationViewController
{
    NSInteger offset = [UIScreen mainScreen].bounds.size.width * 0.1;
    
    UIImage* sourceImage = [self createImageFromView:sourceViewController.view];
    UIImage* nextImage = [self createImageFromView:destinationViewController.view];
    
    UIView* maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 568)] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication].delegate window] addSubview:maskView];
    
    UIImageView* sourceImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height)] autorelease];
    sourceImgView.image = sourceImage;
    [maskView addSubview:sourceImgView];
    
    UIImageView* nextImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(320, 20, 320, nextImage.size.height)] autorelease];
    nextImgView.image = nextImage;
    [[[UIApplication sharedApplication].delegate window] addSubview:nextImgView];
    
    [UIView animateWithDuration:.5f delay:.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sourceImgView.alpha = .0f;
        CGRect frame = sourceImgView.frame;
        frame.origin.x = offset;
        frame.origin.y = offset;
        frame.size.width -= offset * 2;
        frame.size.height -= offset * 2;
        sourceImgView.frame = frame;
    } completion:nil];
    
    [UIView animateWithDuration:.3f delay:.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        nextImgView.frame = CGRectMake(0, 20, 320, nextImage.size.height);
    } completion:^(BOOL finished) {
        [nextImgView removeFromSuperview];
        [sourceImgView removeFromSuperview];
        [maskView removeFromSuperview];
    }];
}

+ (void) popFromViewController: (UIViewController* )sourceViewController ToViewController: (UIViewController* )destinationViewController
{
    NSInteger offset = [UIScreen mainScreen].bounds.size.width * 0.1;
    
    UIImage* sourceImage = [self createImageFromView:sourceViewController.view];
    UIImage* nextImage = [self createImageFromView:destinationViewController.view];
    
    UIView* maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 568)] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication].delegate window] addSubview:maskView];
    
    UIImageView* nextImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(offset, 20 + offset, 320 - offset * 2, nextImage.size.height - offset * 2 - 20)] autorelease];
    nextImgView.image = nextImage;
    nextImgView.alpha = 0.4f;
    [maskView addSubview:nextImgView];
    
    UIImageView* sourceImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, sourceImage.size.width, sourceImage.size.height)] autorelease];
    sourceImgView.image = sourceImage;
    [[[UIApplication sharedApplication].delegate window] addSubview:sourceImgView];
    
    [UIView animateWithDuration:.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        sourceImgView.frame = CGRectMake(320, 20, 320, sourceImage.size.height);
    } completion:nil];
    
    [UIView animateWithDuration:.3f delay:.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        nextImgView.alpha = 1.0f;
        nextImgView.frame = CGRectMake(0, 0, 320, nextImage.size.height);
    } completion:^(BOOL finished) {
        [nextImgView removeFromSuperview];
        [sourceImgView removeFromSuperview];
        [maskView removeFromSuperview];
    }];
}

+ (void) curtainFromViewController: (UIViewController* )sourceViewController ToViewController: (UIViewController* )destinationViewController
{
    int style = arc4random() % 2;
    UIImage* currentImg = [self createImageFromView:[[UIApplication sharedApplication].delegate window]];
    UIImage* nextImg = [self createImageFromView:destinationViewController.view];
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
        [leftCurtain removeFromSuperview];
        [rightCurtain removeFromSuperview];
        [nextImgView removeFromSuperview];
        [maskView removeFromSuperview];
    }];
}
@end
