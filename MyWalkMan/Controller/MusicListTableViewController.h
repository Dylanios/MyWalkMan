//
//  MusicListTableViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListTableViewController : UITableViewController

@property (nonatomic, retain) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger listFlag;

- (IBAction)dismissBarBtnAction:(id)sender;

@end
