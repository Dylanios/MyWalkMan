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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_affirmBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAffirmBtn:nil];
    [super viewDidUnload];
}
- (IBAction)affirmBtnAction:(UIButton *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
