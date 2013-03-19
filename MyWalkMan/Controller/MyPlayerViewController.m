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
#import "LoadingView.h"
#import "PromptView.h"

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
                        placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"]];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NextSongStart"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      offset = 0.0f;
                                                      self.lrcMaskImageView.hidden = YES;
                                                      self.lrcBgScrollView.hidden = YES;
                                                      isExitLrcView = NO;
                                                      isLrcViewShow = NO;
                                                      
                                                      MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
                                                      
                                                      QQMusicSongInfo* info = [engine.dataArray objectAtIndex:engine.toPlayingRow];
                                                      
                                                      [self.albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr] placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                                          
                                                          CATransition* animation = [CATransition animation];
                                                          animation.duration = 0.5f;
                                                          animation.timingFunction = UIViewAnimationCurveEaseInOut;
                                                          animation.type = kCATransitionFade;
                                                          animation.subtype = kCATransitionFromRight;
                                                          
                                                          [self addReflectionLayerInView:self.albumImageView];
                                                          
                                                          [[self.albumImageView layer] addAnimation:animation forKey:@"animation"];
                                                      }];
                                                      
                                                      [self addReflectionLayerInView:self.albumImageView];
                                                      
                                                      self.singerNameLabel.text = info.singerName;
                                                      self.albumNameLabel.text = info.albumName;
                                                      self.titleLabel.text = info.songName;
                                                      self.endTimeLabel.text = info.playTimeSwitchedStr;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"RefreshCurrentTime" object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      self.beginTimeLabel.text = [[MyWalkManSoundEngine shareEngine] currentTime];
                                                      self.playingtimeSlider.value = [[MyWalkManSoundEngine shareEngine] getProgress];
                                                      if (isExitLrcView)
                                                      {
                                                          [self totalTimeInterval:[MyWalkManSoundEngine shareEngine].streamerEngine.duration
                                                              currentTimeInterval:[MyWalkManSoundEngine shareEngine].streamerEngine.progress];
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
    [[MyWalkManSoundEngine shareEngine] resumePlay];
}

- (IBAction)pauseBtnAction:(UIButton *)sender
{
    self.playBtn.hidden = NO;
    self.pauseBtn.hidden = YES;
    [[MyWalkManSoundEngine shareEngine] pause];
}

- (IBAction)preBtnAction:(UIButton *)sender
{
    offset = 0.0f;
    self.lrcMaskImageView.hidden = YES;
    self.lrcBgScrollView.hidden = YES;
    isExitLrcView = NO;
    isLrcViewShow = NO;
    
    [[MyWalkManSoundEngine shareEngine] playingSongChange:NO];
    
    QQMusicSongInfo* info = [[MyWalkManSoundEngine shareEngine].dataArray objectAtIndex:[MyWalkManSoundEngine shareEngine].toPlayingRow];
    
    CATransition* animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromLeft;
    
    [self.albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr] placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [self addReflectionLayerInView:self.albumImageView];
    }];
    [self addReflectionLayerInView:self.albumImageView];
    
    self.singerNameLabel.text = info.singerName;
    self.albumNameLabel.text = info.albumName;
    self.titleLabel.text = info.songName;
    
    [[self.albumImageView layer] addAnimation:animation forKey:@"animation"];
}

- (IBAction)nextBtnAction:(UIButton *)sender
{
    offset = 0.0f;
    self.lrcMaskImageView.hidden = YES;
    self.lrcBgScrollView.hidden = YES;
    isExitLrcView = NO;
    isLrcViewShow = NO;
    
    [[MyWalkManSoundEngine shareEngine] playingSongChange:YES];
    
    QQMusicSongInfo* info = [[MyWalkManSoundEngine shareEngine].dataArray objectAtIndex:[MyWalkManSoundEngine shareEngine].toPlayingRow];
    
    CATransition* animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromRight;
    
    [self.albumImageView setImageWithURL:[NSURL URLWithString:info.albumURLStr] placeholderImage:[UIImage imageNamed:@"playing_album_default.jpg"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [self addReflectionLayerInView:self.albumImageView];
    }];
    [self addReflectionLayerInView:self.albumImageView];
    self.singerNameLabel.text = info.singerName;
    self.albumNameLabel.text = info.albumName;
    self.titleLabel.text = info.songName;
    
    [[self.albumImageView layer] addAnimation:animation forKey:@"animation"];
}

- (IBAction)playingtimeSliderChanged:(UISlider *)sender
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    QQMusicSongInfo* info = [engine.dataArray objectAtIndex:engine.nowPlayingRow];
    double destinationTime = sender.value * info.playTimeInt;
    self.beginTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)destinationTime / 60, (int)destinationTime % 60];
    [engine.streamerEngine seekToTime:destinationTime];
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

- (IBAction)downloadBtnAction:(UIButton *)sender {
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
    ASIHTTPRequest* requset = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:info.songLrcURLStr]];
    [requset setCompletionBlock:^{
        [QQMusicDataManager handleLrcWithData:requset.responseData];
        [self showLrcView];
    }];
    [requset startAsynchronous];
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

- (void)totalTimeInterval:(NSTimeInterval)total currentTimeInterval:(NSTimeInterval)timeInterval
{
    if ([[MyWalkManSoundEngine shareEngine].lrc.lrcKeys count] > index)
    {
        if ([[[MyWalkManSoundEngine shareEngine].lrc.lrcKeys objectAtIndex:index] doubleValue] <= timeInterval)
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
    self.lrcLabel.frame = CGRectMake(0, 120, 320, size.height);
    
    self.lrcBgScrollView.contentSize = CGSizeMake(size.width, size.height);
    self.selectedLrcLabel.frame = CGRectMake(0, 0, 320, self.lrcLabel.font.lineHeight);
    [self.lrcLabel addSubview:self.selectedLrcLabel];
    
    NSInteger currentTime = (int)[MyWalkManSoundEngine shareEngine].streamerEngine.progress;
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

@end
