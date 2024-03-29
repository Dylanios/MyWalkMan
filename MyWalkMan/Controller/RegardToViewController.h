//
//  RegardToViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSViewTransitionProtocol.h"

@interface RegardToViewController : UIViewController

@property (assign, nonatomic) id<YSViewTransitionProtocol> delegate;

@property (retain, nonatomic) IBOutlet UILabel *tipsLabel;
@property (retain, nonatomic) IBOutlet UIButton *affirmBtn;

- (IBAction)affirmBtnAction:(UIButton *)sender;

@end
