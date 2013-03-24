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
#import "MyWalkManDownLoadEngine.h"

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

- (void)dealloc
{
    RELEASE_SAFELY(cacheDict);
    RELEASE_SAFELY(urlArray);
    RELEASE_SAFELY(_homeBtn);
    RELEASE_SAFELY(_mainScrollView);
    RELEASE_SAFELY(_pageCtrl);
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
        MyPlayerViewController* childVC = segue.destinationViewController;
        childVC.segueParent = @"Home";
        return;
    }
    
    if ([segue.identifier isEqualToString:@"HomeVCToMusicListTableSegue"])
    {
        MusicListTableViewController* childVC = segue.destinationViewController;
        childVC.dataArray = [NSMutableArray arrayWithArray:self.dataArray];
        childVC.listFlag = listFlag;
    }
}

- (IBAction)homeBtnAction:(UIButton *)sender
{
    int flag = sender.tag % 100;
    listFlag = flag;
    int btnType = sender.tag / 100;
    
    switch (flag)
    {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        {
            // 判断播放列表是否存在缓存
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
            
            LoadingView* loadView = [[[LoadingView alloc] init] autorelease];
            [self.view addSubview:loadView];
            [loadView.activityIndicator startAnimating];
            
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:url];
            
            [request setCompletionBlock:^{
                
                [loadView.activityIndicator stopAnimating];
                [loadView removeFromSuperview];
                
                [cacheDict setObject:request.responseData forKey:keyURLString];
                self.dataArray = [QQMusicDataManager handleWithData:request.responseData];
                if (btnType == 1)
                {
                    [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue"
                                              sender:self];
                }
                else
                {
                    [MyWalkManSoundEngine shareEngine].dataArray = [NSMutableArray arrayWithArray:self.dataArray];
                    [MyWalkManSoundEngine shareEngine].toPlayingRow = 0;
                    [[MyWalkManSoundEngine shareEngine] engineStart];
                }
            }];
            [request setFailedBlock:^{
                
                [loadView.activityIndicator stopAnimating];
                [loadView removeFromSuperview];
                
                PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"网络君貌似又在玩着抽风，您抽它几下吧。。。" Duration:1.5f] autorelease];
                [self.view addSubview:tipsView];
                [tipsView animationBeginAndEnd];
            }];
            
            [request startAsynchronous];
            break;
        }
        case 8:
        case 9:
        {
            NSMutableDictionary* paramDict = [NSMutableDictionary dictionary];
            if (flag == 8)
                [paramDict setValue:@"1" forKey:@"isDown"];
            else
                [paramDict setValue:@"0" forKey:@"isDown"];
            
            self.dataArray = [[YSDatabaseManager shareDatabaseManager] localCacheInfoInDatabase:paramDict];
            
            if (btnType == 1)
            {
                [self performSegueWithIdentifier:@"HomeVCToMusicListTableSegue"
                                          sender:self];
            }
            else
            {
                [MyWalkManSoundEngine shareEngine].dataArray = [NSMutableArray arrayWithArray:self.dataArray];
                [MyWalkManSoundEngine shareEngine].toPlayingRow = 0;
                [[MyWalkManSoundEngine shareEngine] engineStart];
            }
            break;
        }
        case 10:
        {
            [self performSegueWithIdentifier:@"HomeToDownload"
                                      sender:self];
            break;
        }
        case 11:
        {
            [self performSegueWithIdentifier:@"HomeToAbout" sender:self];
            break;
        }
        default:
            break;
    }
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

- (void)downloadStateChanged: (NSNotification* )notification
{
    switch ([MyWalkManDownLoadEngine shareEngine].state)
    {
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
