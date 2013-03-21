//
//  DownloadListViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "DownloadListViewController.h"
#import "DownloadListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DownloadListViewController ()

@end

@implementation DownloadListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListCell"];
//    cell.imageView setImageWithURL:<#(NSURL *)#> placeholderImage:<#(UIImage *)#>
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBAction Methods
- (IBAction)dismissBtnAction:(UIButton *)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
