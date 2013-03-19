//
//  LoadingView.m
//  ZLZP_CJW
//
//  Created by Ibokan on 13-2-25.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor clearColor];
        
        UIView* backView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 132, 132)] autorelease];
        backView.center = CGPointMake(160, 180);
        backView.layer.cornerRadius = 20;//colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8
        backView.layer.shadowColor = [UIColor blackColor].CGColor;
        backView.layer.shadowOffset = CGSizeMake(0, 0);
        backView.layer.shadowOpacity = 1;
        backView.layer.shadowRadius = 10;
        [self addSubview:backView];
        
        backView.backgroundColor = [UIColor  colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
        
        self.activityIndicator = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 130, 130)]autorelease];
        self.activityIndicator.center = CGPointMake(66, 60);
        [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置进度轮显示类型
        
        self.contentLable = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0,100, 30)]autorelease];
        self.contentLable.center = CGPointMake(80, 90);
        self.contentLable.textColor = [UIColor whiteColor];
        self.contentLable.backgroundColor = [UIColor clearColor];
        self.contentLable.text = @"载入中...";
        
        [backView addSubview:self.contentLable];
        [backView addSubview:self.activityIndicator];
    }
    return self;
}

@end
