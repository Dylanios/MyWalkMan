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
#import "QQMusicSongInfo.h"
#import "MyWalkManSoundEngine.h"
#import "ASIHTTPRequest.h"
#import "MyWalkManDownLoadEngine.h"

@interface DownloadListViewController ()

@end

@implementation DownloadListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

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
    
    self.updateProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                                  target:self
                                                                selector:@selector(updateProgressText:)
                                                                userInfo:nil
                                                                 repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadStateChanged:)
                                                 name:YSDownloadStateChangedNotification
                                               object:nil];
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
    return [MyWalkManDownLoadEngine shareEngine].requestArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DownloadListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadListCell"];

    ASIHTTPRequest* request = [[MyWalkManDownLoadEngine shareEngine].requestArray objectAtIndex:indexPath.row];
    request.downloadProgressDelegate = cell.progressView;
    QQMusicSongInfo* info = [request.userInfo objectForKey:@"info"];
    
    [cell.albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr]
                        placeholderImage:[UIImage imageNamed:@"channel_first_release_default_image_small.png"]];
    cell.songNameLabel.text = info.songName;
    cell.singerAndAlbumNameLabel.text = [NSString stringWithFormat:@"%@ ● %@", info.singerName, info.albumName];
    
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
    for (int i = 0; i != [MyWalkManDownLoadEngine shareEngine].queue.requestsCount; ++i)
    {
        ASIHTTPRequest* request = [[MyWalkManDownLoadEngine shareEngine].requestArray objectAtIndex:i];
        request.downloadProgressDelegate = nil;
    }
    INVALIDATE_TIMER(_updateProgressTimer);
    [self dismissModalViewControllerAnimated:YES];
}

- (void)downloadStateChanged: (NSNotification* )notification
{
    switch ([MyWalkManDownLoadEngine shareEngine].state)
    {
        case YSSuccess:
        {
            [self.updateProgressTimer setFireDate:[NSDate distantFuture]];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.updateProgressTimer setFireDate:[NSDate date]];
        }
            break;
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

- (void)updateProgressText: (NSNotification* )notification
{
    DownloadListCell* cell = (DownloadListCell* )[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.progressLabel.text = [NSString stringWithFormat:@"%.02f%%", cell.progressView.progress * 100];
}

@end
