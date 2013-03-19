//
//  MyWalkManSoundEngine.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioStreamer.h"
#import "QQMusicSongInfo.h"
#import "YSLrcParser.h"

@interface MyWalkManSoundEngine : NSObject

@property (nonatomic, retain) AudioStreamer* streamerEngine;

@property (nonatomic, retain) NSArray* dataArray;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) NSInteger nowPlayingRow;
@property (nonatomic, assign) NSInteger toPlayingRow;
@property (nonatomic, assign) NSInteger nowPlayingSongId;

@property (nonatomic, retain) NSTimer* currentTimerProgress;

@property (nonatomic, retain) NSMutableDictionary* cacheLrcDict;
@property (nonatomic, retain) YSLrc* lrc;
@property (nonatomic, assign) BOOL isLrcExit;

+ (MyWalkManSoundEngine* )shareEngine;
- (void)engineStart;
- (void)resumePlay;
- (void)pause;
- (void)playingSongChange: (BOOL)isNext;
- (double)getProgress;
- (NSString* )currentTime;

@end
