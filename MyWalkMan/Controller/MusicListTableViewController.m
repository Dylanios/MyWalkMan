//
//  MusicListTableViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MusicListTableViewController.h"
#import "MusicListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "QQMusicSongInfo.h"
#import "MyWalkManSoundEngine.h"
#import "MyPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FMDatabase.h"
#import <CommonCrypto/CommonDigest.h>
#import "FMDatabaseAdditions.h"

@interface MusicListTableViewController ()

@end

@implementation MusicListTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    MusicListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MusicListCell"];
    
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell.albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr]
                        placeholderImage:[UIImage imageNamed:@"channel_first_release_default_image_small.png"]];
    cell.songNameLabel.text = info.songName;
    cell.singerNameLabel.text = [NSString stringWithFormat:@"%@ ● %@", info.singerName, info.albumName];
    cell.playTimeLabel.text = info.playTimeSwitchedStr;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [MyWalkManSoundEngine shareEngine].toPlayingRow = indexPath.row;
    [MyWalkManSoundEngine shareEngine].dataArray = self.dataArray;
    [[MyWalkManSoundEngine shareEngine] engineStart];
    [self performSegueWithIdentifier:@"MusicListToPlayer" sender:self];
}

- (IBAction)dismissBarBtnAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
