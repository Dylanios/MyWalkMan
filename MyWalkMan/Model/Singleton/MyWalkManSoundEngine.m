//
//  MyWalkManSoundEngine.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyWalkManSoundEngine.h"
#import "FMDatabase.h"
#import "NSString+MD5.h"

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
        NSLog(@"%s 本地播放器自动切换下一首时出错", __FUNCTION__);
    }
}

- (void)engineStart
{
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
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    if (![db open])
    {
        NSLog(@"db open error");
    }
    FMResultSet* resultFMSetInMusic = [db executeQuery:@"select * from localmusic where idStr = ?", info.idStr];
    if (resultFMSetInMusic.next)
    {
        QQMusicSongInfo* newInfo = [[[QQMusicSongInfo alloc] initWithFMResultSet:resultFMSetInMusic] autorelease];
        [self.dataArray replaceObjectAtIndex:self.toPlayingRow withObject:newInfo];
        info = [self.dataArray objectAtIndex:self.toPlayingRow];
        [MyWalkManSoundEngine shareEngine].isLocale = YES;
    }
    else
    {
        FMResultSet* resultFmSetInStream = [db executeQuery:@"select * from localstream where idStr = ?", info.idStr];
        if (resultFmSetInStream.next)
        {
            QQMusicSongInfo* newInfo = [[[QQMusicSongInfo alloc] initWithFMResultSet:resultFmSetInStream] autorelease];
            [self.dataArray replaceObjectAtIndex:self.toPlayingRow withObject:newInfo];
            info = [self.dataArray objectAtIndex:self.toPlayingRow];
            [MyWalkManSoundEngine shareEngine].isLocale = YES;
        }
        else
            [MyWalkManSoundEngine shareEngine].isLocale = NO;
    }
    
    [db close];
    
    if (self.isLocale)
    {
        NSLog(@"%s %@", __func__, info.path);
        NSError* error = nil;
        self.avAudioPlayer = [[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:info.path]
                                                                     error:&error] autorelease];
        self.avAudioPlayer.delegate = self;
        if (error)
        {
            NSLog(@"%s %@", __func__, [error description]);
        }
        [self.avAudioPlayer prepareToPlay];
        [self.avAudioPlayer play];
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        [session setActive:YES error:nil];
    }
    else
    {
        NSString* resulstMd5 = [NSString calMD5WithName:info.songURLStr];
        NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* musicFilePath = [filePath stringByAppendingFormat:@"/com.youngsing.cachestream/%@.mp3", resulstMd5];
        NSString* docFilePath = [filePath stringByAppendingString:@"/com.youngsing.cachestream"];
        [[NSFileManager defaultManager] createDirectoryAtPath:docFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        if ([[NSFileManager defaultManager] createFileAtPath:musicFilePath contents:[NSData data] attributes:nil])
        {
            self.cacheStreamLocation = musicFilePath;
        }
        else
        {
            NSLog(@"文件创建失败 %s", __func__);
        }
        
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
    [self.currentTimerProgress invalidate];
    self.currentTimerProgress = nil;
    self.nowPlayingSongId = -1;
    self.nowPlayingRow = -1;    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.isPlaying = NO;
    if (self.isLocale)
    {
        [self.avAudioPlayer stop];
        [_avAudioPlayer release];
        _avAudioPlayer = nil;
    }
    else
    {
        [self.streamerEngine stop];
        [_streamerEngine release];
        _streamerEngine = nil;
    }
}

- (void)playingStateChanged: (NSNotification* )note
{
    NSLog(@"self.streamerEngine.state:::%d", self.streamerEngine.state);
    switch (self.streamerEngine.state)
    {
        case AS_STOPPING:
        {
            NSLog(@"stopping huadong");
            break;
        }
        case AS_STOPPED:
        {
            NSLog(@"self.streamerEngine.stopReason：：：：%d", self.streamerEngine.stopReason);
            self.toPlayingRow = self.nowPlayingRow + 1;
            if (self.toPlayingRow >= self.dataArray.count)
                self.toPlayingRow = 0;
            
            //如果音频正常播放完毕，则将其写入localstream表中
            if (self.streamerEngine.stopReason == AS_STOPPING_EOF)
            {
                NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
                FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
                if (![db open])
                {
                    NSLog(@"db open error %s", __func__);
                }
                QQMusicSongInfo* info = [self.dataArray objectAtIndex:self.nowPlayingRow];
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:info.infoDict];
                [dict setValue:[NSString calMD5WithName:info.songURLStr] forKey:@"md5"];
                [dict setValue:self.cacheStreamLocation forKey:@"path"];
                [db executeUpdate:InsertIntoLocalStreamDatebase withParameterDictionary:dict];
                [db close];
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
