//
//  YSDatabaseManager.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-23.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSDatabaseManager.h"
#import <SDWebImage/SDImageCache.h>
#import "NSString+MD5.h"
#import "QQMusicSongInfo.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

static YSDatabaseManager* manager = nil;

@implementation YSDatabaseManager

- (void)dealloc
{
    RELEASE_SAFELY(manager);
    RELEASE_SAFELY(_database);
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
        self.database = [FMDatabase databaseWithPath:dbPath];
        /*
         * md5                  根据songUrlStr计算的md5码
         * idStr                歌曲的id（返回信息）
         * typeStr              歌曲的type（返回信息）
         * urlStr               歌曲的url（返回信息）
         * songName             歌曲的名字（返回信息）
         * singerIdStr          歌曲的演唱者id（返回信息）
         * singerName           歌曲的演唱者名字（返回信息）
         * albumIdStr           歌曲专辑的id（返回信息）
         * albunName            专辑名字（返回信息）
         * albumLinkStr         专辑封面的链接地址（返回信息）
         * playTimeStr          歌曲的长度（以秒计）
         * matchStr             拼接参数
         * songUrlStr           拼接出来的歌曲下载路径
         * albumURLStr          拼接出来的专辑封面下载路径
         * songLrcURLStr        拼接出来的歌词下载路径
         * playTimeSwitchedStr  转换后的歌曲长度（00：00格式）
         * path                 歌曲在磁盘上的路径
         * lrc                  歌词缓存
         * isCache              下载或是历史
         * musicData            歌曲的cache
         * playCount            播放次数（暂不实现）
         * rating               评分（暂不实现）
         * size                 歌曲的大小（0.0M格式）
         */
        if (![self.database open])
        {
            YSLog(@"数据库打开失败");
        }
        else
        {
            [self.database executeUpdate:@"create table if not exists localmusic (md5 text primary key, idStr text, typeStr text, urlStr text, songName text, singerIdStr text, singerName text, albumIdStr text, albumName text, albumLinkStr text, playTimeStr text, matchStr text, songURLStr text, albumURLStr text, songLrcURLStr text, playTimeSwitchedStr text, musicPath text, lrcPath text, isDown text, musicData blob, lrcData text, playCount text, rating text, size text)"];
            [self.database close];
        }
    }
    return self;
}

+ (YSDatabaseManager* )shareDatabaseManager;
{
    if (nil == manager)
    {
        manager = [[YSDatabaseManager alloc] init];
    }
    return manager;
}

- (BOOL)clearAllCache;
{
    BOOL clearResult = NO;
    
    if (![self.database open])
    {
        YSLog(@"Open Database Failed");
    }
    else
    {
        [[SDImageCache sharedImageCache] clearDisk];
        clearResult = [self.database executeUpdate:@"truncate table localmusic"];
        [self.database close];
    }
    
    return clearResult;
}

- (BOOL)insertWithMusicInfo: (QQMusicSongInfo* )info Param:(NSDictionary *)dict
{
    BOOL insertResult = NO;
    
    if (nil == info)
    {
        YSLog(@"传入数据库的数据有误");
    }
    else
    {
        if (![self.database open])
        {
            YSLog(@"Open Database Failed");
        }
        else
        {
            FMResultSet* resultSet = [self.database executeQuery:@"select * from localmusic where idStr = ?", info.idStr];
            if (resultSet.next)
            {
                YSLog(@"%@已存在于数据库中", info.songName);
                insertResult = [self updateWithMusicInfo:info Param:dict];
            }
            else
            {
                NSMutableDictionary* paramDict = [NSMutableDictionary dictionaryWithDictionary:info.infoDict];
                if (dict.count)
                {
                    NSArray* keys = [dict allKeys];
                    for (NSString* key in keys)
                    {
                        id obj = [dict objectForKey:key];
                        [paramDict setValue:obj forKey:key];
                    }
                }
                NSMutableArray* cols = [NSMutableArray array];
                NSMutableArray* vals = [NSMutableArray array];
                NSArray* keys = [paramDict allKeys];
                for (NSString* key in keys)
                {
                    [cols addObject:key];
                    [vals addObject:[paramDict objectForKey:key]];
                }
                NSMutableArray* newVals = [NSMutableArray array];
                for (int i = 0; i != cols.count; ++i)
                {
                    [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
                }
                NSString* sql = [NSString stringWithFormat:@"insert into localmusic (%@) values(%@)", [cols componentsJoinedByString:@","], [newVals componentsJoinedByString:@","]];
                insertResult = [self.database executeUpdate:sql];
                [self.database close];
            }
        }
    }
    
    return insertResult;
}

- (BOOL)deleteWithMusicInfo: (QQMusicSongInfo* )info Param:(NSDictionary *)dict
{
    BOOL deleteResult = NO;
    
    if (nil == info)
    {
        YSLog(@"传入数据库的数据有误");
    }
    else
    {
        if (![self.database open])
        {
            YSLog(@"Open Database Failed");
        }
        else
        {
            deleteResult = [self.database executeUpdate:@"delete from localmusic where md5 = ?", info.md5];
            [self.database close];
        }
    }
    
    return deleteResult;
}

- (BOOL)updateWithMusicInfo: (QQMusicSongInfo* )info Param:(NSDictionary *)dict
{
    BOOL updateResult = NO;
    
    if (nil == info || dict == nil)
    {
        YSLog(@"传入数据库的数据有误");
    }
    else
    {
        if (![self.database open])
        {
            YSLog(@"Open Database Failed");
        }
        else
        {
            NSMutableArray* cols = [NSMutableArray array];
            NSMutableArray* vals = [NSMutableArray array];
            NSArray* keys = [dict allKeys];
            for (NSString* key in keys)
            {
                [cols addObject:key];
                [vals addObject:[dict objectForKey:key]];
            }
            NSMutableArray* newArray = [NSMutableArray array];
            for (int i = 0; i != cols.count; ++i)
            {
                [newArray addObject:[NSString stringWithFormat:@"%@ = '%@'", [cols objectAtIndex:i], [vals objectAtIndex:i]]];
            }
            NSString* sql = [NSString stringWithFormat:@"update localmusic set %@ where md5 = '%@'", [newArray componentsJoinedByString:@","], info.md5];
            updateResult = [self.database executeUpdate:sql];
            [self.database close];
        }
    }
    
    return updateResult;
}

- (BOOL)queryWithMusicInfo: (QQMusicSongInfo* )info Param:(NSDictionary *)dict
{
    BOOL queryResult = NO;
    
    if (nil == info)
    {
        YSLog(@"传入数据库的数据有误");
    }
    else
    {
        if (![self.database open])
        {
            YSLog(@"Open Database Failed");
        }
        else
        {
            [self.database close];
        }
    }
    
    
    return queryResult;
}

- (NSMutableArray* )localCacheInfoInDatabase:(NSDictionary *)dict
{
    NSMutableArray* localInfo = [NSMutableArray array];
    
    if (![self.database open])
    {
        YSLog(@"Open Database Failed");
    }
    else
    {
        FMResultSet* resultSet = nil;
        if (dict.count)
        {
            NSMutableArray* cols = [NSMutableArray array];
            NSMutableArray* vals = [NSMutableArray array];
            NSArray* keys = [dict allKeys];
            for (NSString* key in keys)
            {
                [cols addObject:key];
                [vals addObject:[dict objectForKey:key]];
            }
            NSMutableArray* newArray = [NSMutableArray array];
            for (int i = 0; i != cols.count; ++i)
            {
                [newArray addObject:[NSString stringWithFormat:@"%@='%@'", [cols objectAtIndex:i], [vals objectAtIndex:i]]];
            }
            NSString* sql = [NSString stringWithFormat:@"select * from localmusic where %@", [newArray componentsJoinedByString:@","]];
            resultSet = [self.database executeQuery:sql];
        }
        else
        {
            resultSet = [self.database executeQuery:@"select * from localmusic"];
        }
        
        while ([resultSet next])
        {
            @autoreleasepool {
                QQMusicSongInfo* info = [[[QQMusicSongInfo alloc] initWithFMResultSet:resultSet] autorelease];
                [localInfo addObject:info];
            }
        }
        [self.database close];
    }
    return localInfo;
}

- (BOOL)isInDatabase: (QQMusicSongInfo* )info
{
    BOOL isIn = NO;
    
    [self.database open];
    isIn = [self.database stringForQuery:@"select md5 from localmusic where md5 = ?", info.md5].length;
    [self.database close];
    
    return isIn;
}

- (BOOL)isMusicDownloaded: (QQMusicSongInfo* )info
{
    BOOL isDownloaded = NO;
    
    [self.database open];
    isDownloaded = [[self.database stringForQuery:@"select isDown from localmusic where md5 = ?", info.md5] intValue];
    [self.database close];
    
    return isDownloaded;
}

- (QQMusicSongInfo* )localCacheItemWithMusicInfo: (QQMusicSongInfo* )info
{
    QQMusicSongInfo* localInfo = nil;
    return localInfo;
}

@end
