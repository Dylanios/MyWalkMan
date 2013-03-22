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
#import "MyWalkManDownLoadEngine.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadStateChanged:)
                                                 name:YSDownloadStateChangedNotification
                                               object:nil];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    YSLog(@"%d", self.listFlag);
    if (self.listFlag == 8 || self.listFlag == 9)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    if (![db open])
    {
        NSLog(@"db open error: %s", __func__);
    }
    else
    {
        QQMusicSongInfo* info = [self.dataArray objectAtIndex:indexPath.row];
        NSString* toDeleteFilePath = nil;
        
        if ([MyWalkManSoundEngine shareEngine].isPlaying)
        {
            if ([MyWalkManSoundEngine shareEngine].dataArray.count == 1)
            {
                [[MyWalkManSoundEngine shareEngine] destroyStreamerEngine];
            }
            else
            {
                [[MyWalkManSoundEngine shareEngine] playingSongChangeIsNext:YES];
            }
        }
        
        if (self.listFlag == 8)
        {
            toDeleteFilePath = [db stringForQuery:@"select path from localmusic where idStr = ?", info.idStr];
            [db executeUpdate:@"delete from localmusic where idStr = ?", info.idStr];
        }
        else
        {
            toDeleteFilePath = [db stringForQuery:@"select path from localstream where idStr = ?", info.idStr];
            [db executeUpdate:@"delete from localstream where idStr = ?", info.idStr];
        }
        [db close];
        [[NSFileManager defaultManager] removeItemAtPath:toDeleteFilePath error:nil];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [MyWalkManSoundEngine shareEngine].dataArray = self.dataArray;
        --[MyWalkManSoundEngine shareEngine].nowPlayingRow;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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

- (void)downloadStateChanged: (NSNotification* )notification
{
    switch ([MyWalkManDownLoadEngine shareEngine].state)
    {
        case YSSuccess:
        {
            if (self.listFlag == 8)
            {
                NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
                FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
                if (![db open])
                {
                    YSLog(@"db open error");
                }
                else
                {
                    FMResultSet* result = [db executeQuery:@"select * from localmusic"];
                    
                    NSMutableArray* localMusicArray = [NSMutableArray array];
                    while ([result next])
                    {
                        @autoreleasepool {
                            QQMusicSongInfo* info = [[[QQMusicSongInfo alloc] initWithFMResultSet:result] autorelease];
                            [localMusicArray addObject:info];
                        }
                    }
                    [db close];
                    self.dataArray = localMusicArray;
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
            break;
        }
        case YSFailed:
        {
            PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"下载中的“歌歌”貌似被手雷炸掉了，啦啦啦～～～"
                                                             Duration:1.5f] autorelease];
            [self.view addSubview:tipsView];
            [tipsView animationBeginAndEnd];
            break;
        }
        default:
            break;
    }
}

@end
