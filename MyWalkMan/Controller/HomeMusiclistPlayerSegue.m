//
//  HomeMusiclistPlayerSegue.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-24.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "HomeMusiclistPlayerSegue.h"
#import "MyPlayerViewController.h"

@implementation HomeMusiclistPlayerSegue

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
    NSInteger offset = [UIScreen mainScreen].bounds.size.width * 0.1;
    
    UIViewController* sourceVC = self.sourceViewController;
    UIViewController* nextVC = self.destinationViewController;
    
    UIImage* sourceImage = [self createImageFromView:[[UIApplication sharedApplication].delegate window]];
    UIImage* nextImage = [self createImageFromView:nextVC.view];
    
    UIView* maskView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, sourceImage.size.height)] autorelease];
    maskView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication].delegate window] addSubview:maskView];
    
    if ([sourceVC isKindOfClass:[MyPlayerViewController class]])
    {
        UIImageView* sourceImgView = [[[UIImageView alloc] initWithFrame:maskView.frame] autorelease];
        sourceImgView.image = sourceImage;
        [[[UIApplication sharedApplication].delegate window] addSubview:sourceImgView];
        
        UIImageView* nextImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(offset, 20 + offset, 320 - offset * 2, nextImage.size.height - offset * 2 - 44 - 20)] autorelease];
        nextImgView.image = nextImage;
        nextImgView.alpha = 0.4f;
        [maskView addSubview:nextImgView];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sourceImgView.alpha = 0.0f;
            sourceImgView.frame = CGRectMake(320, 20, 320, maskView.frame.size.height);
        } completion:nil];
        
        [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            nextImgView.alpha = 1.0f;
            nextImgView.frame = CGRectMake(0, 64, 320, nextImage.size.height);
        } completion:^(BOOL finished) {
            [sourceVC dismissModalViewControllerAnimated:NO];
            [nextImgView removeFromSuperview];
            [sourceImgView removeFromSuperview];
            [maskView removeFromSuperview];
        }];
    }
    else
    {
        UIImageView* sourceImgView = [[[UIImageView alloc] initWithFrame:maskView.frame] autorelease];
        sourceImgView.image = sourceImage;
        [maskView addSubview:sourceImgView];
        
        UIImageView* nextImgView = [[[UIImageView alloc] initWithFrame:CGRectMake(320, 20, 320, nextVC.view.frame.size.height)] autorelease];
        nextImgView.image = nextImage;
        [[[UIApplication sharedApplication].delegate window] addSubview:nextImgView];
        
        [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sourceImgView.alpha = 0.0f;
            CGRect frame = maskView.frame;
            frame.origin.x = offset;
            frame.origin.y = offset;
            frame.size.width -= offset * 2;
            frame.size.height -= offset * 2;
            sourceImgView.frame = frame;
        } completion:nil];
        
        [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            nextImgView.frame = CGRectMake(0, 20, 320, nextVC.view.frame.size.height);
        } completion:^(BOOL finished) {
            [sourceVC presentModalViewController:nextVC animated:NO];
            [nextImgView removeFromSuperview];
            [sourceImgView removeFromSuperview];
            [maskView removeFromSuperview];
        }];
    }
}
@end
