//
//  PromptView.m
//  ZLZP_CJW
//
//  Created by youngsing on 13-3-4.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "PromptView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PromptView

- (id)initWithTitle:(NSString *)tips Duration:(CGFloat)time
{
    if (self = [super init])
    {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        duration = time;
        
        UIView* backView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 80)] autorelease];
        [self addSubview:backView];
        backView.backgroundColor = [UIColor blackColor];
        backView.center = CGPointMake(160, 180);
        backView.layer.cornerRadius = 10;
        backView.layer.shadowColor = [UIColor blackColor].CGColor;
        backView.layer.shadowOffset = CGSizeMake(0, 0);
        backView.layer.shadowOpacity = 1;
        backView.layer.shadowRadius = 10;
        
        UILabel* tipsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(40, 0, 180, 80)] autorelease];
        tipsLabel.backgroundColor = [UIColor clearColor];
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.text = tips;
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = FontOFHelvetica16;
        tipsLabel.numberOfLines = 0;
        [backView addSubview:tipsLabel];
    }
    return self;
}

- (void)animationBeginAndEnd
{
    [UIView animateWithDuration:duration animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        self.alpha = 1.0f;
        self.alpha = 0.9f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            self.alpha = 1.0f;
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}

@end
