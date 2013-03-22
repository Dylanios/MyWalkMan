//
//  DownloadListViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIProgressDelegate.h"

@interface DownloadListViewController : UITableViewController<ASIProgressDelegate>

@property (nonatomic, retain) NSTimer* updateProgressTimer;

- (IBAction)dismissBtnAction:(UIButton *)sender;
@end
