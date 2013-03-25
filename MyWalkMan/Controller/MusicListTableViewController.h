//
//  MusicListTableViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSViewTransitionProtocol.h"

@interface MusicListTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, YSViewTransitionProtocol>

@property (nonatomic, assign) id<YSViewTransitionProtocol> delegate;
@property (nonatomic, retain) NSMutableArray* dataArray;
@property (nonatomic, assign) NSInteger listFlag;
@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (IBAction)dismissBtnAction:(UIButton *)sender;

@end
