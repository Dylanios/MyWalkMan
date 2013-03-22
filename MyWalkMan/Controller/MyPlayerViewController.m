//
//  MyPlayerViewController.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ASIHTTPRequest.h"
#import "QQMusicDataManager.h"
#import "MyWalkManDownLoadEngine.h"
#import "DownloadListViewController.h"
#import "FMDatabase.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+MD5.h"

@interface MyPlayerViewController ()

@end

@implementation MyPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.controlScrollView.contentSize = CGSizeMake(320, 86);
    
    [self.playingtimeSlider setThumbImage:[UIImage imageNamed:@"playing_slider_thumb.png"] forState:UIControlStateNormal];
    
    [self.volumnSlider setThumbImage:[UIImage imageNamed:@"playing_volumn_slide_sound_icon.png"] forState:UIControlStateNormal];
    UIImage* resizeMinImage = [[UIImage imageNamed:@"playing_volumn_slide_foreground.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 8, 3, 8)];
    [self.volumnSlider setMinimumTrackImage:resizeMinImage forState:UIControlStateNormal];
    UIImage* resizeMaxImage = [[UIImage imageNamed:@"playing_volumn_slide_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 8, 3, 8)];
    [self.volumnSlider setMaximumTrackImage:resizeMaxImage forState:UIControlStateNormal];
    
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    self.info = [engine.dataArray objectAtIndex:engine.nowPlayingRow];
    
    self.titleLabel.text = self.info.songName;
    self.singerNameLabel.text = self.info.singerName;
    self.albumNameLabel.text = self.info.albumName;
    self.beginTimeLabel.text = [engine currentTime];
    self.endTimeLabel.text = self.info.playTimeSwitchedStr;
    
    [self.albumImageView setImageWithURL:[NSURL URLWithString:self.info.albumURLStr]
                        placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                            [self addReflectionLayerInView:self.albumImageView];
                        }];
    
    CALayer* reflectionLayer = [CALayer layer];
    reflectionLayer.contents = [self.albumImageView layer].contents;
    reflectionLayer.opacity = 0.5;
    reflectionLayer.frame = CGRectMake(0, 0, self.albumImageView.frame.size.width, self.albumImageView.frame.size.height);
    CATransform3D stransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
    CATransform3D transform = CATransform3DTranslate(stransform, 0, -self.albumImageView.frame.size.height, 0);
    reflectionLayer.transform = transform;
    reflectionLayer.sublayerTransform = reflectionLayer.transform;
    [[self.albumImageView layer] addSublayer:reflectionLayer];
    
    //加载在底部播放按钮的View上的手势，以弹出工具View
    UISwipeGestureRecognizer* swipUp = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipUp:)] autorelease];
    swipUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self.controlScrollView addGestureRecognizer:swipUp];
    
    UISwipeGestureRecognizer* swipDown = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipDown:)] autorelease];
    swipDown.direction = UISwipeGestureRecognizerDirectionDown;
    [self.controlScrollView addGestureRecognizer:swipDown];
    
    //弹出歌词View的手势
    UISwipeGestureRecognizer* swipLeftToLrc = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipLeftToLrc:)] autorelease];
    swipLeftToLrc.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.albumImageView addGestureRecognizer:swipLeftToLrc];
    
    UISwipeGestureRecognizer* swipRightToLrc = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipRightToLrc:)] autorelease];
    swipRightToLrc.direction = UISwipeGestureRecognizerDirectionRight;
    [self.lrcBgScrollView addGestureRecognizer:swipRightToLrc];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadStateChanged:)
                                                 name:YSDownloadStateChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NextSongStart"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      offset = 0.0f;
                                                      self.pauseBtn.hidden = NO;
                                                      self.playBtn.hidden = YES;
                                                      self.lrcMaskImageView.hidden = YES;
                                                      self.lrcBgScrollView.hidden = YES;
                                                      isExitLrcView = NO;
                                                      isLrcViewShow = NO;
                                                      
                                                      MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
                                                      
                                                      self.info = [engine.dataArray objectAtIndex:engine.toPlayingRow];
                                                      
                                                      [self.albumImageView setImageWithURL:[NSURL URLWithString:self.info.albumURLStr] placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                                          
                                                          CATransition* animation = [CATransition animation];
                                                          animation.duration = 0.5f;
                                                          animation.timingFunction = UIViewAnimationCurveEaseInOut;
                                                          animation.type = kCATransitionFade;
                                                          animation.subtype = kCATransitionFromRight;
                                                          
                                                          [self addReflectionLayerInView:self.albumImageView];
                                                          
                                                          [[self.albumImageView layer] addAnimation:animation forKey:@"animation"];
                                                      }];
                                                      
                                                      [self addReflectionLayerInView:self.albumImageView];
                                                      
                                                      self.singerNameLabel.text = self.info.singerName;
                                                      self.albumNameLabel.text = self.info.albumName;
                                                      self.titleLabel.text = self.info.songName;
                                                      self.endTimeLabel.text = self.info.playTimeSwitchedStr;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RefreshCurrentTime" object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      self.beginTimeLabel.text = [[MyWalkManSoundEngine shareEngine] currentTime];
                                                      self.playingtimeSlider.value = [[MyWalkManSoundEngine shareEngine] getProgress];
                                                      if (isExitLrcView)
                                                      {
                                                          if ([MyWalkManSoundEngine shareEngine].isLocale)
                                                          {
                                                              [self musicDuration:[MyWalkManSoundEngine shareEngine].avAudioPlayer.duration currentTime:[MyWalkManSoundEngine shareEngine].avAudioPlayer.currentTime];
                                                          }
                                                          else
                                                          {
                                                              [self musicDuration:[MyWalkManSoundEngine shareEngine].streamerEngine.duration currentTime:[MyWalkManSoundEngine shareEngine].streamerEngine.progress];
                                                          }
                                                      }
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(simplifyUI) withObject:nil afterDelay:5.0f];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{NSLog(@"124");
    if (event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype)
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self pauseBtnAction:nil];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self preBtnAction:nil];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self nextBtnAction:nil];
                break;
            default:
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_albumImageView release];
    [_playBtn release];
    [_preBtn release];
    [_nextBtn release];
    [_pauseBtn release];
    [_volumnSlider release];
    [_albumNameLabel release];
    [_singerNameLabel release];
    [_favBtn release];
    [_controlScrollView release];
    [_toolView release];
    [_downloadBtn release];
    [_moreBtn release];
    [_addtoBtn release];
    [_circleBtn release];
    [_tipsView release];
    [_imageBgView release];
    [_titleView release];
    [_titleLabel release];
    [_beginTimeLabel release];
    [_endTimeLabel release];
    [_lrcBgScrollView release];
    [_lrcLabel release];
    [_selectedLrcLabel release];
    [_lrcMaskImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setAlbumImageView:nil];
    [self setPlayBtn:nil];
    [self setPreBtn:nil];
    [self setNextBtn:nil];
    [self setPauseBtn:nil];
    [self setVolumnSlider:nil];
    [self setAlbumNameLabel:nil];
    [self setSingerNameLabel:nil];
    [self setFavBtn:nil];
    [self setControlScrollView:nil];
    [self setToolView:nil];
    [self setDownloadBtn:nil];
    [self setMoreBtn:nil];
    [self setAddtoBtn:nil];
    [self setCircleBtn:nil];
    [self setTipsView:nil];
    [self setImageBgView:nil];
    [self setTitleView:nil];
    [self setTitleLabel:nil];
    [self setBeginTimeLabel:nil];
    [self setEndTimeLabel:nil];
    [self setLrcBgScrollView:nil];
    [self setLrcLabel:nil];
    [self setSelectedLrcLabel:nil];
    [self setLrcMaskImageView:nil];
    [super viewDidUnload];
}

#pragma mark - IBAction Methods
- (IBAction)playBtnAction:(UIButton *)sender
{
    self.playBtn.hidden = YES;
    self.pauseBtn.hidden = NO;
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    if (engine.isLocale)
    {
        [engine.avAudioPlayer play];
    }
    else
    {
        [engine.streamerEngine start];
    }
}

- (IBAction)pauseBtnAction:(UIButton *)sender
{
    self.playBtn.hidden = NO;
    self.pauseBtn.hidden = YES;
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    if (engine.isLocale)
    {
        [engine.avAudioPlayer pause];
    }
    else
    {
        [engine.streamerEngine pause];
    }
}

- (IBAction)preBtnAction:(UIButton *)sender
{
//    self.preBtn.enabled = NO;
    offset = 0.0f;
    self.lrcMaskImageView.hidden = YES;
    self.lrcBgScrollView.hidden = YES;
    isExitLrcView = NO;
    isLrcViewShow = NO;
    
    [[MyWalkManSoundEngine shareEngine] playingSongChangeIsNext:NO];
    
}

- (IBAction)nextBtnAction:(UIButton *)sender
{
    offset = 0.0f;
    self.lrcMaskImageView.hidden = YES;
    self.lrcBgScrollView.hidden = YES;
    isExitLrcView = NO;
    isLrcViewShow = NO;
    
    [[MyWalkManSoundEngine shareEngine] playingSongChangeIsNext:YES];
}

- (IBAction)playingtimeSliderChanged:(UISlider *)sender
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    QQMusicSongInfo* info = [engine.dataArray objectAtIndex:engine.nowPlayingRow];
    double destinationTime = sender.value * info.playTimeInt;
    self.beginTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)destinationTime / 60, (int)destinationTime % 60];
    if (engine.isLocale)
    {
        [engine.avAudioPlayer stop];
        [engine.avAudioPlayer setCurrentTime:destinationTime];
        [engine.avAudioPlayer prepareToPlay];
        [engine.avAudioPlayer play];
    }
    else
    {
        [engine.streamerEngine pause];
        [engine.streamerEngine seekToTime:destinationTime];
        [engine.streamerEngine start];
    }
}

- (IBAction)popBackBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)musicListBtnAction:(UIButton *)sender
{
}

- (IBAction)volumnSliderAction:(UISlider *)sender
{
    NSUInteger value = (int)roundf(sender.value);
    NSLog(@"%d", value);
}

- (IBAction)favBtnAction:(UIButton *)sender {
}

- (IBAction)circleBtnAction:(UIButton *)sender {
}

- (IBAction)addtoBtnAction:(UIButton *)sender {
}

- (IBAction)downloadBtnAction:(UIButton *)sender
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    QQMusicSongInfo* nowPlayingInfo = [engine.dataArray objectAtIndex:engine.nowPlayingRow];
    
    /*
     *  下载触发时，先判断localmusic中是否存在这首歌：
     *  1.存在这首歌：直接跳转提示动画，告知用户本地乐库中已有这首歌
     *  2.不存在这首歌：再判断localstream中是否存在这首歌：
     *                                              a.存在这首歌：将这首歌从相应的文件夹复制到对应的文件夹中后，删除原文件夹中的歌
     *                                                          曲，并更新相应表的相应数据
     *                                              b.不存在这首歌：启动ASIHTTPRequest进行下载
     *
     */
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    if (![db open])
    {
        NSLog(@"%s-----db open error", __func__);
    }
    FMResultSet* resultFMSetInMusic = [db executeQuery:@"select * from localmusic where idStr = ?", nowPlayingInfo.idStr];
    if (resultFMSetInMusic.next)
    {
        PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"这位“歌歌”已经在后宫了哦！" Duration:1.5f] autorelease];
        [self.view addSubview:tipsView];
        [tipsView animationBeginAndEnd];
        [db close];
        [self swipDown:nil];
        return;
    }
    else
    {
        FMResultSet* resultInStream = [db executeQuery:@"select * from localstream where idStr = ?", nowPlayingInfo.idStr];
        if (resultInStream.next)
        {
            NSString* cache = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            // 判断localmusic文件夹是否存在，不存在则创建
            NSString* docFilePath = [cache stringByAppendingString:@"/com.youngsing.cachemusic"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:docFilePath])
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:docFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            // 获取保存路径，并进行相应的复制、删除操作
            NSString* filePathInMusic = [cache stringByAppendingFormat:@"/com.youngsing.cachemusic/%@.mp3", [resultInStream stringForColumn:@"md5"]];
            [[NSFileManager defaultManager] copyItemAtPath:[resultInStream stringForColumn:@"path"]
                                                    toPath:filePathInMusic
                                                     error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[resultInStream stringForColumn:@"path"]
                                                       error:nil];
            QQMusicSongInfo* cutInfo = [[[QQMusicSongInfo alloc] initWithFMResultSet:resultInStream] autorelease];
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:cutInfo.infoDict];
            [dict setValue:filePathInMusic forKey:@"path"];
            [db executeUpdate:InsertIntoLocalMusicDatebase withParameterDictionary:dict];
            [db executeUpdate:@"delete from localstream where idStr = ?", [resultInStream stringForColumn:@"idStr"]];
            
            SystemSoundID soundID;
            NSURL* soundURL = [[NSBundle mainBundle] URLForResource:@"success" withExtension:@"caf"];
            AudioServicesCreateSystemSoundID((CFURLRef)soundURL, &soundID);
            AudioServicesPlaySystemSound(soundID);
            [db close];
            [self swipDown:nil];
            return;
        }
    }
    
    for (ASIHTTPRequest* request in [MyWalkManDownLoadEngine shareEngine].requestArray)
    {
        if ([request.originalURL.absoluteString isEqualToString:nowPlayingInfo.songURLStr]
            || [request.url.absoluteString isEqualToString:nowPlayingInfo.songURLStr])
        {
            PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"这位“歌歌”已经在入宫的队列中了，啦啦啦～～～"
                                                             Duration:1.5f] autorelease];
            [self.view addSubview:tipsView];
            [tipsView animationBeginAndEnd];
            [self swipDown:nil];
            return;
        }
    }
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:nowPlayingInfo.songURLStr]];
    YSLog(@"%@", self.info.songName);
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.info, @"info", nil];
    [[MyWalkManDownLoadEngine shareEngine] addRequest:request];
    
    [self swipDown:nil];
    [self performSegueWithIdentifier:@"PlayerToDownload" sender:self];
}

- (IBAction)moreBtnAction:(UIButton *)sender {
}

#pragma mark - Custom Methods
- (void)swipUp: (UIGestureRecognizer* )gesture
{
    if (isTipsViewShow)
    {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.playingtimeSlider.hidden = YES;
        CGRect frame = self.toolView.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 64 - 86 - 110;
        self.toolView.frame = frame;
        
        CGRect frame1 = self.tipsView.frame;
        frame1.origin.y -= 90;
        self.tipsView.frame = frame1;
        
        CGRect frame2 = self.imageBgView.frame;
        frame2.size.height -= 90;
        self.imageBgView.frame = frame2;
    }];
    isTipsViewShow = YES;
}

- (void)swipDown: (UIGestureRecognizer* )gesture
{
    if (!isTipsViewShow)
    {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        CGRect frame2 = self.imageBgView.frame;
        frame2.size.height += 90;
        self.imageBgView.frame = frame2;
        
        CGRect frame1 = self.tipsView.frame;
        frame1.origin.y += 90;
        self.tipsView.frame = frame1;
        
        CGRect frame = self.toolView.frame;
        frame.origin.y = 548;
        self.toolView.frame = frame;
        
        self.playingtimeSlider.hidden = NO;
    }];
    isTipsViewShow = NO;
}

- (void)swipLeftToLrc: (UIGestureRecognizer* )gesture
{
    if (isLrcViewShow)
    {
        return;
    }
    
    if (isExitLrcView)
    {
        isLrcViewShow = YES;
        self.lrcMaskImageView.hidden = NO;
        self.lrcBgScrollView.hidden = NO;
        return;
    }
    
    isExitLrcView = YES;
    self.lrcLabel.text = @"";
    self.selectedLrcLabel.text = @"";
    
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    QQMusicSongInfo* info = [engine.dataArray objectAtIndex:engine.nowPlayingRow];
    
    NSString* lrcString = [engine.cacheLrcDict objectForKey:info.idStr];
    
    if (lrcString.length)
    {
        [QQMusicDataManager handleLrcWithString:lrcString];
        [self showLrcView];
        return;
    }
    NSLog(@"%@", info.songLrcURLStr);
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:info.songLrcURLStr]];
    [request setCompletionBlock:^{
        [QQMusicDataManager handleLrcWithData:request.responseData];
        [self showLrcView];
    }];
    [request setFailedBlock:^{
        PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"网络君貌似又在玩着抽风，您抽它几下吧。。。" Duration:1.5f] autorelease];
        [self.view addSubview:tipsView];
        [tipsView animationBeginAndEnd];
    }];
    [request startAsynchronous];
}

- (void)swipRightToLrc: (UIGestureRecognizer* )gesture
{
    if (!isLrcViewShow)
    {
        return;
    }
    
    self.lrcMaskImageView.hidden = YES;
    self.lrcBgScrollView.hidden = YES;
    
    isLrcViewShow = NO;
}


- (void)musicDuration: (NSTimeInterval)duration currentTime: (NSTimeInterval)current
{
    if ([[MyWalkManSoundEngine shareEngine].lrc.lrcKeys count] > index)
    {
        if ([[[MyWalkManSoundEngine shareEngine].lrc.lrcKeys objectAtIndex:index] doubleValue] <= current)
        {
            [self refreshView];
        }
    }
}

- (void)showLrcView
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    
    if (!engine.isLrcExit)
    {
        PromptView* tipsView = [[[PromptView alloc] initWithTitle:@"Sorry，不知道这位调皮的“歌歌”把歌词藏哪了……" Duration:1.5f] autorelease];
        [self.view addSubview:tipsView];
        [tipsView animationBeginAndEnd];
        isExitLrcView = NO;
        return;
    }
    
    CATransition* animation = [CATransition animation];
    animation.duration = 0.7f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    animation.subtype = kCATransitionFromBottom;
    
    self.lrcMaskImageView.hidden = NO;
    self.lrcBgScrollView.alpha = 1.0f;
    self.lrcBgScrollView.hidden = NO;
    [[self.lrcBgScrollView layer] addAnimation:animation forKey:@"animation"];
    
    NSMutableString *lrcStr = [NSMutableString string];
    for (id key in engine.lrc.lrcKeys)
    {
        [lrcStr appendString:[engine.lrc.lyric objectForKey:key]];
        [lrcStr appendString:@"\n"];
    }
    
    self.lrcLabel.text = lrcStr;
    CGSize size = [lrcStr sizeWithFont:self.lrcLabel.font
                     constrainedToSize:CGSizeMake(self.lrcLabel.frame.size.width, NSIntegerMax)
                         lineBreakMode:self.lrcLabel.lineBreakMode];
    
    self.lrcLabel.frame = CGRectMake(0, 120, self.lrcLabel.frame.size.width, size.height);
    
    self.lrcBgScrollView.contentSize = CGSizeMake(size.width, size.height);
    self.selectedLrcLabel.frame = CGRectMake(0, 0, size.width, self.lrcLabel.font.lineHeight);
    [self.lrcLabel addSubview:self.selectedLrcLabel];
    
    NSInteger currentTime = 0;
    if ([MyWalkManSoundEngine shareEngine].isLocale)
    {
        currentTime = (int)[MyWalkManSoundEngine shareEngine].avAudioPlayer.currentTime;
    }
    else
    {
        currentTime = (int)[MyWalkManSoundEngine shareEngine].streamerEngine.progress;
    }
    NSArray* keyArray = [MyWalkManSoundEngine shareEngine].lrc.lrcKeys;
    for (int i = 0; i < keyArray.count; ++i)
    {
        NSInteger tagTime = [[keyArray objectAtIndex:i] intValue];
        if (tagTime >= currentTime)
        {
            if (i != 0)
            {
                index = i - 1;
                NSMutableString *lrcStr = [NSMutableString string];
                int j = 0;
                for (id key in engine.lrc.lrcKeys)
                {
                    [lrcStr appendString:[engine.lrc.lyric objectForKey:key]];
                    [lrcStr appendString:@"\n"];
                    ++j;
                    if (j == index)
                    {
                        CGSize offSize = [lrcStr sizeWithFont:self.lrcLabel.font
                                            constrainedToSize:CGSizeMake(self.lrcLabel.frame.size.width, NSIntegerMax)
                                                lineBreakMode:self.lrcLabel.lineBreakMode];
                        offset = offSize.height;
                        [self.lrcBgScrollView setContentOffset:CGPointMake(0, offset)];
                        break;
                    }
                }
            }
            else
            {
                index = 0;
                [self.lrcBgScrollView setContentOffset:CGPointMake(0, 0)];
            }
            break;
        }
    }
    
    isLrcViewShow = YES;
}

- (void)refreshView
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    id key = [engine.lrc.lrcKeys objectAtIndex:index];
    CGPoint point = self.lrcBgScrollView.contentOffset;
    NSString *lrcStr = [engine.lrc.lyric objectForKey:key];
    CGSize size = [lrcStr sizeWithFont:self.lrcLabel.font
                     constrainedToSize:CGSizeMake(self.lrcLabel.frame.size.width, NSIntegerMax)
                    lineBreakMode:self.lrcLabel.lineBreakMode];
    self.selectedLrcLabel.text = nil;
    double duration = 0.0;
    if (index < [engine.lrc.lrcKeys count] - 1)
    {
        duration = [[engine.lrc.lrcKeys objectAtIndex:++index] doubleValue] - [key doubleValue];
    }
    
    [self.lrcBgScrollView setContentOffset:CGPointMake(0, point.y + size.height) animated:YES];
    self.selectedLrcLabel.text = lrcStr;
    self.selectedLrcLabel.frame = CGRectMake((320 - size.width) / 2, offset, 0, size.height);
    if (duration > 0.00001)
    {
        [UIView animateWithDuration:duration
                         animations:^{
                             self.selectedLrcLabel.frame = CGRectMake((320 - size.width) / 2, offset, size.width, size.height);
                         }];
    }
    else
    {
        self.selectedLrcLabel.frame = CGRectMake((320 - size.width) / 2, offset, size.width, size.height);
    }
    
    offset += size.height;
    if (size.height < 1)
    {
        offset += self.lrcLabel.font.lineHeight;
    }
}

- (void)simplifyUI
{
}

- (void)addReflectionLayerInView: (UIView *)view
{
    CALayer* reflectionLayer = [CALayer layer];
    reflectionLayer.contents = [view layer].contents;
    reflectionLayer.opacity = 0.5;
    reflectionLayer.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    CATransform3D stransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
    CATransform3D transform = CATransform3DTranslate(stransform, 0, -view.frame.size.height, 0);
    reflectionLayer.transform = transform;
    reflectionLayer.sublayerTransform = reflectionLayer.transform;
    [[view.layer.sublayers objectAtIndex:0] removeFromSuperlayer];
    [view.layer addSublayer:reflectionLayer];
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
