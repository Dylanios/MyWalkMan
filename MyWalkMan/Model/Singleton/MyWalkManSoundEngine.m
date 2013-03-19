//
//  MyWalkManSoundEngine.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyWalkManSoundEngine.h"

static MyWalkManSoundEngine* Engine = nil;

@implementation MyWalkManSoundEngine

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [Engine release], Engine = nil;
    [_streamerEngine release], _streamerEngine = nil;
    [_dataArray release], _dataArray = nil;
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
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@"cacheLrc"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            self.cacheLrcDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        }
        else
        {
            self.cacheLrcDict = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)engineStart
{
    QQMusicSongInfo* newInfo = [self.dataArray objectAtIndex:self.toPlayingRow];

    if (self.nowPlayingSongId == newInfo.idInt)
    {
        return;
    }
    
    if (self.isPlaying)
    {
        [self destroyStreamerEngine];
    }
    NSLog(@"%@", newInfo.songURLStr);
    self.streamerEngine = [[[AudioStreamer alloc] initWithURL:[NSURL URLWithString:newInfo.songURLStr]] autorelease];
    
    self.currentTimerProgress = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                 target:self
                                                               selector:@selector(refreshCurrentTime)
                                                               userInfo:nil
                                                                repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playingStateChanged:)
                                                 name:ASStatusChangedNotification
                                               object:_streamerEngine];
    self.nowPlayingSongId = newInfo.idInt;
    self.nowPlayingRow = self.toPlayingRow;
    self.isPlaying = YES;
    [self.streamerEngine start];
}

- (void)destroyStreamerEngine
{
    [self.currentTimerProgress invalidate];
    self.currentTimerProgress = nil;
    self.nowPlayingSongId = -1;
    self.nowPlayingRow = -1;    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isPlaying = NO;
    [self.streamerEngine stop];
    [_streamerEngine release];
    _streamerEngine = nil;
}

- (void)playingStateChanged: (NSNotification* )note
{
    NSLog(@"%d", self.streamerEngine.state);
    switch (self.streamerEngine.state)
    {
        case AS_STOPPING:
        {
            NSLog(@"stopping huadong");
            break;
        }
        case AS_STOPPED:
        {
            NSLog(@"stopped");
            self.toPlayingRow = self.nowPlayingRow + 1;
            if (self.toPlayingRow >= self.dataArray.count)
                self.toPlayingRow = 0;
            [self engineStart];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NextSongStart"
                                                                object:self.streamerEngine];
            break;
        }
        default:
            break;
    }
}

- (void)resumePlay
{
    [self.streamerEngine start];
}

- (void)pause
{
    [self.streamerEngine pause];
}

- (void)playingSongChange: (BOOL)isNext
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
    
    [self engineStart];
}

- (double)getProgress
{
    QQMusicSongInfo* info = [self.dataArray objectAtIndex:self.nowPlayingRow];
    return self.streamerEngine.progress / info.playTimeInt;
}

- (NSString* )currentTime
{
    int progress = (int)self.streamerEngine.progress;
    
    return [NSString stringWithFormat:@"%02d:%02d", progress / 60, progress % 60];
}

- (void)refreshCurrentTime
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCurrentTime" object:nil];
}

- (void)Tryagain: (NSNotificationCenter *)note
{
    static NSInteger repeatTimes = 0;
    NSLog(@"repeatTimes::::%d", repeatTimes);
    if (repeatTimes == 3)
    {
        repeatTimes = 0;
        return;
    }
    self.nowPlayingSongId = -1;
    ++repeatTimes;
}

@end
