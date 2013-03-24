//
//  RegardToViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "RegardToViewController.h"

@interface RegardToViewController ()

@end

@implementation RegardToViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.affirmBtn.titleLabel.font = [UIFont fontWithName:@"YuppySC-Regular" size:18];
    self.tipsLabel.font = [UIFont fontWithName:@"YuppySC-Regular" size:18];
    self.tipsLabel.text = @"本程序中的图片，音乐等资源均来源于互联网,仅供测试网络和学习交流之用,请勿用作商业用途,否则后果自负.\n\n如果在线音乐播放不了，请尝试将DNS设置为114.114.114.114（或8.8.8.8)\n\n                youngsing@qq.com";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_affirmBtn release];
    [_tipsLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAffirmBtn:nil];
    [self setTipsLabel:nil];
    [super viewDidUnload];
}
- (IBAction)affirmBtnAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"AboutToHome" sender:self];
}
@end
