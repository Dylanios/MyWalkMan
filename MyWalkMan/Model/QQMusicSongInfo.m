//
//  QQMusicSongInfo.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "QQMusicSongInfo.h"

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
        NSLog(@"%s %d 此处参数为:%@", __FUNCTION__, __LINE__, _matchStr);
    }
    _matchInt += 10;
    
    NSString* tmpIdStr = [NSString stringWithFormat:@"%07d", _idInt];
    self.songURLStr = [NSString stringWithFormat:@"http://stream%d.qqmusic.qq.com/3%@.mp3", _matchInt, tmpIdStr];
    self.albumURLStr = [NSString stringWithFormat:@"http://imgcache.qq.com/music/photo/album/%d/albumpic_%@_0.jpg", _albumIdInt % 100, _albumIdStr];
    self.songLrcURLStr = [NSString stringWithFormat:@"http://music.qq.com/miniportal/static/lyric/%d/%@.xml", _idInt % 100, _idStr];
    self.playTimeSwitchedStr = [NSString stringWithFormat:@"%02d:%02d", _playTimeInt / 60,
                        _playTimeInt % 60];
}

@end
