//
//  DownloadListViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadListViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray* dataArray;
@property (nonatomic, retain) NSMutableArray* downloadQueue;

- (IBAction)dismissBtnAction:(UIButton *)sender;
@end
