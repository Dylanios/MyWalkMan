//
//  QQMusicDataManager.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "QQMusicDataManager.h"
#import "QQMusicSongInfo.h"
#import "MyWalkManSoundEngine.h"

@implementation QQMusicDataManager

+ (NSArray *)handleWithData:(NSData *)newData
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* string = [[[NSString alloc] initWithData:newData
                                              encoding:gbkEncoding] autorelease];
    
    NSRange range = [string rangeOfString:@"songlist:"];
    string = [string substringFromIndex:range.location + range.length];
    range = [string rangeOfString:@"}]}"];
    string = [string substringToIndex:range.location + 2];
    
    string = [string stringByReplacingOccurrencesOfString:@"{id" withString:@"{\"id\""];
    string = [string stringByReplacingOccurrencesOfString:@"type" withString:@"\"type\""];
    string = [string stringByReplacingOccurrencesOfString:@"url" withString:@"\"url\""];
    string = [string stringByReplacingOccurrencesOfString:@"songName" withString:@"\"songName\""];
    string = [string stringByReplacingOccurrencesOfString:@"singerId" withString:@"\"singerId\""];
    string = [string stringByReplacingOccurrencesOfString:@"singerName" withString:@"\"singerName\""];
    string = [string stringByReplacingOccurrencesOfString:@"albumId" withString:@"\"albumId\""];
    string = [string stringByReplacingOccurrencesOfString:@"albumName" withString:@"\"albumName\""];
    string = [string stringByReplacingOccurrencesOfString:@"albumLink" withString:@"\"albumLink\""];
    string = [string stringByReplacingOccurrencesOfString:@"playtime" withString:@"\"playtime\""];
    
    NSData* jsonData = [string dataUsingEncoding:4];
    NSArray* receiveArray = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableLeaves
                                                              error:nil];
    
    NSMutableArray* returnArray = [NSMutableArray arrayWithCapacity:receiveArray.count];
    for (NSDictionary* dict in receiveArray)
    {
        QQMusicSongInfo* info = [[[QQMusicSongInfo alloc] initWithDictionary:dict] autorelease];
        [returnArray addObject:info];
    }
    
    return returnArray;
}

+ (void)handleLrcWithData:(NSData *)newData
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString* lrcString = [[[NSString alloc] initWithData:newData encoding:gbkEncoding] autorelease];
    
    NSRange range = [lrcString rangeOfString:@"[CDATA["];
    if (range.length == 0)
    {
        engine.isLrcExit = NO;
        return;
    }
    
    lrcString = [lrcString substringFromIndex:range.location + range.length];
    range = [lrcString rangeOfString:@"]]></lyric>"];
    lrcString = [lrcString substringToIndex:range.location];
    NSLog(@"%@", lrcString);
    [self handleLrcWithString:lrcString];
}

+ (void)handleLrcWithString: (NSString* )lrcString
{
    MyWalkManSoundEngine* engine = [MyWalkManSoundEngine shareEngine];
    
    engine.isLrcExit = YES;
    
    engine.lrc = [YSLrcParser lrcWith:lrcString];
    
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"cacheLrc"];
    [engine.cacheLrcDict setValue:lrcString
                           forKey:[NSString stringWithFormat:@"%d", engine.nowPlayingSongId]];
    [engine.cacheLrcDict writeToFile:path atomically:YES];
}

@end
