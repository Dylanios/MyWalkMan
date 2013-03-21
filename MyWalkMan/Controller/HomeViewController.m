//
//  HomeViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "HomeViewController.h"
#import "URLEncode.h"
#import "ASIHTTPRequest.h"
#import "QQMusicDataManager.h"
#import "MusicListTableViewController.h"
#import "MyWalkManSoundEngine.h"
#import "MyPlayerViewController.h"
#import "FMDatabase.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 20 - 44 - 44;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        self.pageCtrl.center = CGPointMake(160, height - 50);
    }
    self.mainScrollView.contentSize = CGSizeMake(640, height);
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    urlArray = [[NSArray alloc] initWithObjects:
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_newsong.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_classic.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_movie.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_eu.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_cartoon.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_game.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_net.js",
                @"http://music.qq.com/musicbox/shop/v3/data/hit/hit_soft.js",
                nil];
    cacheDict = [[NSMutableDictionary alloc] initWithCapacity:8];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [cacheDict release], cacheDict = nil;
    [urlArray release], urlArray = nil;
    [_homeBtn release];
    [_mainScrollView release];
    [_pageCtrl release];
    [super dealloc];
}

- (void)viewDidUnload
{
    cacheDict = nil;
    urlArray = nil;
    [self setHomeBtn:nil];
    [self setMainScrollView:nil];
    [self setPageCtrl:nil];
    [super viewDidUnload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageCtrl.currentPage = scrollView.contentOffset.x / 320;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (isNowPlayingBtnAction)
    {
        isNowPlayingBtnAction = NO;
        return;
    }
    
    MusicListTableViewController* childVC = segue.destinationViewController;
    childVC.dataArray = [NSMutableArray arrayWithArray:self.dataArray];
}

- (IBAction)homeBtnAction:(UIButton *)sender
{
    int flag = sender.tag - 100;
    //本地播放直接跳转
    if (flag == 8 || flag == 9)
    {
        NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
        FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
        [db open];
        FMResultSet* result = nil;
        if (flag == 8)
            result = [db executeQuery:@"select * from localmusic"];
        else
            result = [db executeQuery:@"select * from localstream"];
        
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
        [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue" sender:self];
        return;
    }
    
    NSString* keyURLString = [urlArray objectAtIndex:flag];
    NSData* cacheData = [cacheDict objectForKey:keyURLString];
    if (cacheData != nil)
    {
        self.dataArray = [QQMusicDataManager handleWithData:cacheData];
        [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue"
                                  sender:self];
        return;
    }
    
    NSURL* url = [NSURL URLWithString:keyURLString];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        [cacheDict setObject:request.responseData forKey:keyURLString];
        self.dataArray = [QQMusicDataManager handleWithData:request.responseData];
        [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue"
                                  sender:self];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@", [request.error description]);
    }];
    
    [request startAsynchronous];
}

- (IBAction)homePlayBtnAction:(UIButton *)sender
{
    int flag = sender.tag - 100;
    
    if (flag == 8 || flag == 9)
    {
        NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
        FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
        [db open];
        FMResultSet* result = nil;
        if (flag == 8)
            result = [db executeQuery:@"select * from localmusic"];
        else
            result = [db executeQuery:@"select * from localstream"];
        
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
        [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue" sender:self];
        return;
    }
    
    NSString* keyURLString = [urlArray objectAtIndex:flag];
    NSData* cacheData = [cacheDict objectForKey:keyURLString];
    if (cacheData != nil)
    {
        self.dataArray = [QQMusicDataManager handleWithData:cacheData];
        [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue" sender:self];
        return;
    }
    
    NSLog(@"%@", [urlArray objectAtIndex:flag]);
    NSURL* url = [NSURL URLWithString:[urlArray objectAtIndex:flag]];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
    
    [request setCompletionBlock:^{
        [cacheDict setObject:request.responseData forKey:keyURLString];
        self.dataArray = [QQMusicDataManager handleWithData:request.responseData];
        [MyWalkManSoundEngine shareEngine].dataArray = [NSMutableArray arrayWithArray:self.dataArray];
        [MyWalkManSoundEngine shareEngine].toPlayingRow = 0;
        [[MyWalkManSoundEngine shareEngine] engineStart];
    }];
    [request setFailedBlock:^{
        NSLog(@"%@", [request.error description]);
    }];
    
    [request startAsynchronous];
}

- (IBAction)nowPlayingBtnAction:(UIButton *)sender
{
    isNowPlayingBtnAction = YES;
    [self performSegueWithIdentifier:@"HomeVCToPlayer" sender:self];
}

- (IBAction)pageCtrlValueChangedAction:(UIPageControl *)sender
{
    [self.mainScrollView setContentOffset:CGPointMake(sender.currentPage * 320, 0)
                                 animated:YES];
}
@end
