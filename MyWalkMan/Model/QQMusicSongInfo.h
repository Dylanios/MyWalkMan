//
//  QQMusicSongInfo.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQMusicSongInfo : NSObject

@property (nonatomic, retain) NSString* idStr;
@property (nonatomic, retain) NSString* typeStr;
@property (nonatomic, retain) NSString* urlStr;
@property (nonatomic, retain) NSString* songName;
@property (nonatomic, retain) NSString* singerIdStr;
@property (nonatomic, retain) NSString* singerName;
@property (nonatomic, retain) NSString* albumIdStr;
@property (nonatomic, retain) NSString* albumName;
@property (nonatomic, retain) NSString* albumLinkStr;
@property (nonatomic, retain) NSString* playTimeStr;

@property (nonatomic, assign) int idInt;
@property (nonatomic, assign) int typeInt;
@property (nonatomic, retain) NSString* matchStr;
@property (nonatomic, assign) int matchInt;
@property (nonatomic, assign) int singerIdInt;
@property (nonatomic, assign) int albumIdInt;
@property (nonatomic, assign) int playTimeInt;

@property (nonatomic, retain) NSString* songURLStr;
@property (nonatomic, retain) NSString* albumURLStr;
@property (nonatomic, retain) NSString* songLrcURLStr;
@property (nonatomic, retain) NSString* playTimeSwitchedStr;

- (id)initWithDictionary: (NSDictionary* )dict;

@end
