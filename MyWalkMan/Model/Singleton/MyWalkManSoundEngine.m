//
//  MyWalkManSoundEngine.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyWalkManSoundEngine.h"
#import "NSString+MD5.h"

static MyWalkManSoundEngine* Engine = nil;
NSString* const YSWalkManPlayStateNotification = @"YSWalkManPlayStateNotification";

@implementation MyWalkManSoundEngine

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE_SAFELY(Engine);
    RELEASE_SAFELY(_avAudioPlayer)
    RELEASE_SAFELY(_streamerEngine);
    RELEASE_SAFELY(_dataArray);
    RELEASE_SAFELY(_cacheStreamLocation);
    RELEASE_SAFELY(_lrc);
    [super dealloc];
}

+ (MyWalkManSoundEngine* )shareEngine
{
    @synchronized(self)
    {
        if (nil == Engine)
        {
            Engine =[[MyWalkManSoundEngine alloc] init];
        }
        return Engine;
    }
}

- (id)init
{
    if (self = [super init])
    {
        self.nowPlayingRow = -1;
    }
    return self;
}

#pragma mark - AvAudioPlayer Delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        self.toPlayingRow = self.nowPlayingRow + 1;
        if (self.toPlayingRow >= self.dataArray.count)
            self.toPlayingRow = 0;
        [self engineStart];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NextSongStart"
                                                            object:self.avAudioPlayer];
    }
    else
    {
        YSLog(@"本地播放器自动切换下一首时出错");
    }
}

- (void)engineStart
{
    if (!self.dataArray.count)
    {
        return;
    }
    
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:self.toPlayingRow];

    if (self.nowPlayingSongId == info.idInt)
    {
        return;
    }
    
    if (self.isPlaying)
    {
        [self destroyStreamerEngine];
    }
    //判断将要播放的歌曲是否有本地缓存
    if ([[YSDatabaseManager shareDatabaseManager] isInDatabase:info])
    {
        [MyWalkManSoundEngine shareEngine].isLocale = YES;
    }
    else
    {
        [MyWalkManSoundEngine shareEngine].isLocale = NO;
    }

    if (self.isLocale)
    {
        YSLog(@"%@", info.musicPath);
        NSError* error = nil;
        self.avAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:info.musicPath]
                                                                     error:&error] autorelease];
        self.avAudioPlayer.delegate = self;
        if (error)
        {
            YSLog(@"%@", [error description]);
        }
        [self.avAudioPlayer prepareToPlay];
        [self.avAudioPlayer play];
    }
    else
    {
        NSString* tmpPath = NSTemporaryDirectory();
        tmpPath = [tmpPath stringByAppendingFormat:@"/%@.mp3", info.md5];
        [[NSFileManager defaultManager] createFileAtPath:tmpPath contents:nil attributes:nil];
        self.cacheStreamLocation = tmpPath;
        
        self.streamerEngine = [[[AudioStreamer alloc] initWithURL:[NSURL URLWithString:info.songURLStr]] autorelease];
    }
    
    self.currentTimerProgress = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                 target:self
                                                               selector:@selector(refreshCurrentTime)
                                                               userInfo:nil
                                                                repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playingStateChanged:)
                                                 name:ASStatusChangedNotification
                                               object:_streamerEngine];
    self.nowPlayingSongId = info.idInt;
    self.nowPlayingRow = self.toPlayingRow;
    self.isPlaying = YES;
    [self.streamerEngine start];
}

- (void)destroyStreamerEngine
{
    INVALIDATE_TIMER(_currentTimerProgress);
    self.nowPlayingSongId = -1;
    self.nowPlayingRow = -1;    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isPlaying = NO;
    if (self.isLocale)
    {
        [self.avAudioPlayer stop];
        RELEASE_SAFELY(_avAudioPlayer);
    }
    else
    {
        [self.streamerEngine stop];
        RELEASE_SAFELY(_streamerEngine);
    }
}

- (void)playingStateChanged: (NSNotification* )note
{
    YSLog(@"self.streamerEngine.state:::%d", self.streamerEngine.state);
    switch (self.streamerEngine.state)
    {
        case AS_STOPPING:
        {
            YSLog(@"stopping huadong");
            break;
        }
        case AS_STOPPED:
        {
            YSLog(@"self.streamerEngine.stopReason：：：：%d", self.streamerEngine.stopReason);
            self.toPlayingRow = self.nowPlayingRow + 1;
            if (self.toPlayingRow >= self.dataArray.count)
                self.toPlayingRow = 0;
            
            //如果音频正常播放完毕，则将其写入localmusic表中
            if (self.streamerEngine.stopReason == AS_STOPPING_EOF)
            {
                QQMusicSongInfo* info = [self.dataArray objectAtIndex:self.nowPlayingRow];
                NSString* tmpPath = NSTemporaryDirectory();
                tmpPath = [tmpPath stringByAppendingFormat:@"/%@.mp3", info.md5];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
                {
                    [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:info.musicPath error:nil];
                    NSDictionary* paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"0", @"isDown", nil];
                    [[YSDatabaseManager shareDatabaseManager] insertWithMusicInfo:info Param:paramDict];
                }
            }
            
            [self engineStart];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NextSongStart"
                                                                object:self.streamerEngine];
            break;
        }
        default:
            break;
    }
}

- (void)playingSongChangeIsNext: (BOOL)isNext
{
    if (!isNext)
    {
        self.toPlayingRow = self.nowPlayingRow - 1;
        if (self.toPlayingRow < 0)
        {
            self.toPlayingRow = self.dataArray.count - 1;
        }
    }
    else
    {
        self.toPlayingRow = self.nowPlayingRow + 1;
        if (self.toPlayingRow >= self.dataArray.count)
        {
            self.toPlayingRow = 0;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NextSongStart"
                                                        object:self.streamerEngine];
    [self engineStart];
}

- (double)getProgress
{
    double progress = 0;
    if (self.isLocale)
    {
        progress = self.avAudioPlayer.currentTime;
    }
    else
    {
        progress = self.streamerEngine.progress;
    }
    
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:self.nowPlayingRow];
    return progress / info.playTimeInt;
}

- (NSString* )currentTime
{
    int progress = 0;
    if (self.isLocale)
    {
        progress = (int)self.avAudioPlayer.currentTime;
    }
    else
    {
        progress = (int)self.streamerEngine.progress;
    }

    
    return [NSString stringWithFormat:@"%02d:%02d", progress / 60, progress % 60];
}

- (void)refreshCurrentTime
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCurrentTime" object:nil];
}

- (void)Tryagain: (NSNotificationCenter *)note
{
    static NSInteger repeatTimes = 0;
    YSLog(@"repeatTimes::::%d", repeatTimes);
    if (repeatTimes == 3)
    {
        repeatTimes = 0;
        return;
    }
    self.nowPlayingSongId = -1;
    ++repeatTimes;
}

@end
