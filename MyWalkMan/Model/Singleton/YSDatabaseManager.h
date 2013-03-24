//
//  YSDatabaseManager.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-23.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

@class QQMusicSongInfo;

@interface YSDatabaseManager : NSObject

@property (nonatomic, retain) FMDatabase* database;

+ (YSDatabaseManager* )shareDatabaseManager;
- (BOOL)clearAllCache;
- (BOOL)insertWithMusicInfo: (QQMusicSongInfo* )info Param: (NSDictionary* )dict;
- (BOOL)deleteWithMusicInfo: (QQMusicSongInfo* )info Param: (NSDictionary* )dict;;
- (BOOL)updateWithMusicInfo: (QQMusicSongInfo* )info Param: (NSDictionary* )dict;;
//- (BOOL)queryWithMusicInfo: (QQMusicSongInfo* )info Param: (NSDictionary* )dict;
- (NSMutableArray* )localCacheInfoInDatabase: (NSDictionary *)dict;
- (BOOL)isInDatabase: (QQMusicSongInfo* )info;
- (BOOL)isMusicDownloaded: (QQMusicSongInfo* )info;
//- (QQMusicSongInfo* )localCacheItemWithMusicInfo: (QQMusicSongInfo* )info;

@end
