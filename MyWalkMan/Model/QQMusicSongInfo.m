//
//  QQMusicSongInfo.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "QQMusicSongInfo.h"
#import "FMResultSet.h"
#import "NSString+MD5.h"

@implementation QQMusicSongInfo

- (id)initWithDictionary: (NSDictionary* )dict
{
    if (self = [super init])
    {
        _idStr = [[dict objectForKey:@"id"] retain];
        _typeStr = [[dict objectForKey:@"type"] retain];
        _urlStr = [[dict objectForKey:@"url"] retain];
        _songName = [[dict objectForKey:@"songName"] retain];
        _singerIdStr = [[dict objectForKey:@"singerId"] retain];
        _singerName = [[dict objectForKey:@"singerName"] retain];
        _albumIdStr = [[dict objectForKey:@"albumId"] retain];
        _albumName = [[dict objectForKey:@"albumName"] retain];
        _albumLinkStr = [[dict objectForKey:@"albumLink"] retain];
        _playTimeStr = [[dict objectForKey:@"playtime"] retain];
        [self moreHandle];
    }
    return self;
}

- (void)moreHandle
{
    _idInt = [_idStr intValue];
    _typeInt = [_typeStr intValue];
    _singerIdInt = [_singerIdStr intValue];
    _albumIdInt = [_albumIdStr intValue];
    _playTimeInt = [_playTimeStr intValue];
    
    _matchStr = [_urlStr substringFromIndex:13];
    NSRange matchRange = [_matchStr rangeOfString:@".qqmusic"];
    _matchStr = [_matchStr substringToIndex:matchRange.location];
    _matchInt = [_matchStr intValue];
    
    if (_matchInt > 9)
    {
        YSLog(@"%@", _matchStr);
    }
    _matchInt += 10;
    
    NSString* tmpIdStr = [NSString stringWithFormat:@"%07d", _idInt];
    self.songURLStr = [NSString stringWithFormat:@"http://stream%d.qqmusic.qq.com/3%@.mp3", _matchInt, tmpIdStr];
    self.albumURLStr = [NSString stringWithFormat:@"http://imgcache.qq.com/music/photo/album/%d/albumpic_%@_0.jpg", _albumIdInt % 100, _albumIdStr];
    self.songLrcURLStr = [NSString stringWithFormat:@"http://music.qq.com/miniportal/static/lyric/%d/%@.xml", _idInt % 100, _idStr];
    self.playTimeSwitchedStr = [NSString stringWithFormat:@"%02d:%02d", _playTimeInt / 60,
                        _playTimeInt % 60];
    
    _md5 = [NSString calMD5WithName:_songURLStr];
    NSString* cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    _musicPath = [cachePath stringByAppendingFormat:@"/com.youngsing.cachemusic/%@.mp3", _md5];
    _lrcPath = [cachePath stringByAppendingFormat:@"/com.youngsing.cachelrc/%@", _md5];
    
    self.infoDict = [NSDictionary dictionaryWithObjectsAndKeys:_idStr, @"idStr", _typeStr, @"typeStr", _urlStr, @"urlStr", _songName, @"songName", _singerIdStr, @"singerIdStr", _singerName, @"singerName", _albumIdStr, @"albumIdStr", _albumName, @"albumName", _albumLinkStr, @"albumLinkStr", _playTimeStr, @"playTimeStr", _matchStr, @"matchStr", _songURLStr, @"songURLStr", _albumURLStr, @"albumURLStr", _songLrcURLStr, @"songLrcURLStr", _playTimeSwitchedStr, @"playTimeSwitchedStr", _md5, @"md5", _musicPath, @"musicPath", _lrcPath, @"lrcPath", nil];
}

- (id)initWithFMResultSet:(FMResultSet *)result
{
    if (self = [super init])
    {
        _idStr = [[result stringForColumn:@"idStr"] retain];
        _typeStr = [[result stringForColumn:@"typeStr"] retain];
        _urlStr = [[result stringForColumn:@"urlStr"] retain];
        _songName = [[result stringForColumn:@"songName"] retain];
        _singerIdStr = [[result stringForColumn:@"singerIdStr"] retain];
        _singerName = [[result stringForColumn:@"singerName"] retain];
        _albumIdStr = [[result stringForColumn:@"albumIdStr"] retain];
        _albumName = [[result stringForColumn:@"albumName"] retain];
        _albumLinkStr = [[result stringForColumn:@"albumLinkStr"] retain];
        _playTimeStr = [[result stringForColumn:@"playTimeStr"] retain];
        _matchStr = [[result stringForColumn:@"matchStr"] retain];
        _songURLStr = [[result stringForColumn:@"songURLStr"] retain];
        _albumURLStr = [[result stringForColumn:@"albumURLStr"] retain];
        _songLrcURLStr = [[result stringForColumn:@"songLrcURLStr"] retain];
        _playTimeSwitchedStr = [[result stringForColumn:@"playTimeSwitchedStr"] retain];
        _md5 = [[result stringForColumn:@"md5"] retain];
        _musicPath = [[result stringForColumn:@"musicPath"] retain];
        _lrcPath = [[result stringForColumn:@"lrcPath"] retain];
        
        _idInt = [_idStr intValue];
        _typeInt = [_typeStr intValue];
        _singerIdInt = [_singerIdStr intValue];
        _albumIdInt = [_albumIdStr intValue];
        _playTimeInt = [_playTimeStr intValue];
    }
    return self;
}

@end
