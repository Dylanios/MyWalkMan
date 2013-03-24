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
#import <AVFoundation/AVFoundation.h>

typedef enum
{
    YS_Audio_Data_Not_Found = 0,
}YSPlayingState;

extern NSString* const YSWalkManPlayStateNotification;

@interface MyWalkManSoundEngine : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, assign) BOOL isLocale;
@property (nonatomic, retain) AVAudioPlayer* avAudioPlayer;
@property (nonatomic, retain) AudioStreamer* streamerEngine;

@property (nonatomic, readonly) YSPlayingState playingState;

@property (nonatomic, retain) NSMutableArray* dataArray;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) NSInteger nowPlayingRow;
@property (nonatomic, assign) NSInteger toPlayingRow;
@property (nonatomic, assign) NSInteger nowPlayingSongId;

@property (nonatomic, retain) NSTimer* currentTimerProgress;

@property (nonatomic, retain) NSString* cacheStreamLocation;

//@property (nonatomic, retain) NSMutableDictionary* cacheLrcDict;
@property (nonatomic, retain) YSLrc* lrc;
@property (nonatomic, assign) BOOL isLrcExit;

//@property (nonatomic, retain) NSMutableData* metaData;

+ (MyWalkManSoundEngine* )shareEngine;
- (void)engineStart;
- (void)destroyStreamerEngine;
- (void)playingSongChangeIsNext: (BOOL)isNext;
- (double)getProgress;
- (NSString* )currentTime;

@end
