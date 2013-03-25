//
//  MusicListTableViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MusicListTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "QQMusicSongInfo.h"
#import "MusicListCell.h"
#import <AVFoundation/AVFoundation.h>
#import "YSViewTransition.h"
#import "MyPlayerViewController.h"

@interface MusicListTableViewController ()

@end

@implementation MusicListTableViewController

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MyPlayerViewController* destinationVC = segue.destinationViewController;
    destinationVC.delegate = self;
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
//    UISwipeGestureRecognizer* swipRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self
//                                                                                     action:@selector(swipRightAction:)] autorelease];
//    [cell addGestureRecognizer:swipRight];
    
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
    if (self.listFlag == 8 || self.listFlag == 9)
        return YES;
    else
        return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:indexPath.row];
    
    if ([MyWalkManSoundEngine shareEngine].nowPlayingRow == indexPath.row)
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
    
    [[YSDatabaseManager shareDatabaseManager] deleteWithMusicInfo:info Param:nil];
    [[NSFileManager defaultManager] removeItemAtPath:info.musicPath error:nil];
    [self.dataArray removeObjectAtIndex:indexPath.row];
    [MyWalkManSoundEngine shareEngine].dataArray = self.dataArray;
    --[MyWalkManSoundEngine shareEngine].nowPlayingRow;
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [MyWalkManSoundEngine shareEngine].toPlayingRow = indexPath.row;
    [MyWalkManSoundEngine shareEngine].dataArray = [NSMutableArray arrayWithArray:self.dataArray];
    [[MyWalkManSoundEngine shareEngine] engineStart];
    [self performSegueWithIdentifier:@"MusicListToPlayer" sender:self];
}

- (IBAction)dismissBtnAction:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(controllerShouldDismiss:)])
    {
        [_delegate controllerShouldDismiss:self];
    }
}

- (void)downloadStateChanged: (NSNotification* )notification
{
    switch ([MyWalkManDownLoadEngine shareEngine].state)
    {
        case YSSuccess:
        {
            if (self.listFlag == 8)
            {
                NSDictionary* paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"isDown", nil];
                self.dataArray = [[YSDatabaseManager shareDatabaseManager] localCacheInfoInDatabase:paramDict];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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

#pragma mark MyPlayerViewControllerDelegate
- (void)controllerShouldDismiss:(id)controller
{
    [YSViewTransition YSPopViewController:controller ToViewController:self];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)swipRightAction: (UISwipeGestureRecognizer* )gesture
{
    YSLog(@"1234567890");
    
    MusicListCell* cell = (MusicListCell* )[gesture view];
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:indexPath.row];
    UIImageView* imageView = [self createSwippedCellImageView:info];
    CGFloat pointY = cell.frame.origin.y - self.tableView.contentOffset.y + 64;
    CGRect frame = imageView.frame;
    frame.origin.y = pointY;
    imageView.frame = frame;
    [[[UIApplication sharedApplication].delegate window] addSubview:imageView];

    /*
    CATransition* animation = [CATransition animation];
    animation.duration = 5.f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = @"genieEffect";
    animation.subtype = kCATransitionFromTop;
    imageView.frame = CGRectMake(320, 480, 0, 0);
    [imageView.layer addAnimation:animation forKey:@"animation"];
    */
    return;
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    NSLog(@"%d", engine.nowPlayingRow);
    [engine.dataArray insertObject:info atIndex:(engine.nowPlayingRow > -1 ? engine.nowPlayingRow + 1 : 0)];
}

- (UIImageView* )createSwippedCellImageView: (QQMusicSongInfo* )info
{
    UIImageView* cellImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 100)] autorelease];
    
    UIImageView* albumImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)] autorelease];
    [albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr]
                   placeholderImage:[UIImage imageNamed:@"channel_first_release_default_image_small.png"]];
    [cellImageView addSubview:albumImageView];
    
    UILabel* songLabel = [[[UILabel alloc] initWithFrame:CGRectMake(95, 20, 200, 21)] autorelease];
    songLabel.text = info.songName;
    songLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    songLabel.backgroundColor = [UIColor clearColor];
    [cellImageView addSubview:songLabel];
    
    UILabel* singerAndAlbumLabel = [[[UILabel alloc] initWithFrame:CGRectMake(95, 65, 200, 21)] autorelease];
    singerAndAlbumLabel.text = [NSString stringWithFormat:@"%@ ● %@", info.singerName, info.albumName];
    singerAndAlbumLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    singerAndAlbumLabel.backgroundColor = [UIColor clearColor];
    [cellImageView addSubview:singerAndAlbumLabel];
    
    UILabel* timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(258, 39, 42, 21)] autorelease];
    timeLabel.text = info.playTimeSwitchedStr;
    timeLabel.textAlignment = UITextAlignmentCenter;
    timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
    timeLabel.backgroundColor = [UIColor clearColor];
    [cellImageView addSubview:timeLabel];
    
    
    return cellImageView;
}

@end
