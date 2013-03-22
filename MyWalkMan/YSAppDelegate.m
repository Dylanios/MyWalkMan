//
//  YSAppDelegate.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSAppDelegate.h"
#import "FMDatabase.h"
#import <AVFoundation/AVFoundation.h>

@implementation YSAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int isADatabase = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isADatabase"] intValue];
    if (!isADatabase)
    {
#if 0
        {
            NSFileManager* fm = [NSFileManager defaultManager];
            NSString* docFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* dbFilePath = [docFilePath stringByAppendingPathComponent:@"MusicDatabase.db"];
            if (![fm fileExistsAtPath:dbFilePath])
            {
                [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"MusicDatabase" ofType:@"db"]
                            toPath:dbFilePath
                             error:nil];
            }
            NSString* cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString* lrcFilePath = [cacheFilePath stringByAppendingPathComponent:@"cacheLrc"];
            if (![fm fileExistsAtPath:lrcFilePath])
            {
                [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"cacheLrc" ofType:nil]
                            toPath:lrcFilePath
                             error:nil];
            }
            NSString* musicFilePath = [cacheFilePath stringByAppendingPathComponent:@"com.youngsing.cachemusic/007216916f599a5d50e949f9940566e9.mp3"];
            if (![fm fileExistsAtPath:musicFilePath])
            {
                [fm createDirectoryAtPath:[cacheFilePath stringByAppendingPathComponent:@"com.youngsing.cachemusic"]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:nil];
                [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"007216916f599a5d50e949f9940566e9" ofType:@"mp3"]
                            toPath:musicFilePath
                             error:nil];
            }
            NSString* albumFilePath = [cacheFilePath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default/239843b0f4ad7d9d805924f709fb8042"];
            if (![fm fileExistsAtPath:albumFilePath])
            {
                [fm createDirectoryAtPath:[cacheFilePath stringByAppendingPathComponent:@"com.hackemist.SDWebImageCache.default"]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:nil];
                [fm copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"239843b0f4ad7d9d805924f709fb8042" ofType:nil]
                            toPath:albumFilePath
                             error:nil];
            }
            NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
            FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
            if (![db open])
            {
                NSLog(@"db open error %s", __func__);
            }
            [db executeUpdate:@"update localmusic set path = ? where idStr = '12839'", musicFilePath];
            [db close];
        }
#elif 1
        {
            NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
            FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
            if (![db open])
            {
                NSLog(@"db open error %s", __func__);
            }
            [db executeUpdate:@"CREATE TABLE LocalMusic (md5 text primary key, idStr text, typeStr text, urlStr text, songName text, singerIdStr text, singerName text, albumIdStr text, albumName text, albumLinkStr text, playTimeStr text, matchStr text, songURLStr text, albumURLStr text, songLrcURLStr text, playTimeSwitchedStr text, path text)"];
            [db executeUpdate:@"CREATE TABLE LocalStream (md5 text primary key, idStr text, typeStr text, urlStr text, songName text, singerIdStr text, singerName text, albumIdStr text, albumName text, albumLinkStr text, playTimeStr text, matchStr text, songURLStr text, albumURLStr text, songLrcURLStr text, playTimeSwitchedStr text, path text)"];
        }
#endif
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"isADatabase"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        NSLog(@"数据库已存在");
    }    
    
    /*
    NSString* dbPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    dbPath = [dbPath stringByAppendingPathComponent:@"MusicDatabase.db"];
    FMDatabase* db = [FMDatabase databaseWithPath:dbPath];
    [db open];
    NSDictionary *argsDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Name4", @"md5", @"url4", @"idStr", nil];
    [db executeUpdate:@"INSERT INTO localmusic (md5, idStr) VALUES (:md5, :idStr)" withParameterDictionary:argsDict];
    */
    
    /*
    NSString* path = @"http://stream20.qqmusic.qq.com/30012839.mp3";
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:path]];
    [request setCompletionBlock:^{
        NSString* tmpString = [[[NSString alloc] initWithData:request.responseData encoding:1] autorelease];
        const char* resultString = [tmpString UTF8String];
        unsigned char result[16];
        CC_MD5(resultString, strlen(resultString), result);
        NSString* string = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
        NSLog(@"%@", string);
    }];
    [request setFailedBlock:^{
        NSLog(@"%@", [request.error description]);
    }];
    [request startAsynchronous];
     */
    
    /*
    NSString* path = @"/Users/youngsing/Downloads/test.txt";
    NSString* testString = [[[NSString alloc] initWithContentsOfFile:path encoding:4 error:nil] autorelease];
    YSLrc* lrc = [YSLrcParser lrcWith:testString];
    NSLog(@"%@", lrc.lrcKeys);
    NSLog(@"%@", lrc.lyric);
    for (NSString* key in lrc.lrcKeys)
    {
        NSString* string = [lrc.lyric objectForKey:key];
        NSLog(@"%@:%@", key, string);
    }
     */
    
    /*
    NSString* path = @"/Users/youngsing/Downloads/test.txt";
    NSString* testString = [[[NSString alloc] initWithContentsOfFile:path encoding:4 error:nil] autorelease];
    NSLog(@"testString%@", testString);
    
    NSMutableDictionary* lrcTagDict = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
    NSArray* regexTagArray = [[[NSArray alloc] initWithObjects:@"ti", @"ar", @"al", @"offset", @"by", nil] autorelease];
    for (NSString* param in regexTagArray)
    {
        NSString* regex = [NSString stringWithFormat:@"\\[%@:.*\\]", param];
        NSRange range = [testString rangeOfString:regex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound)
        {
            NSString* tagString = [testString substringWithRange:range];
            NSRange tagRange = [tagString rangeOfString:@":"];
            tagString = [tagString substringFromIndex:tagRange.location + 1];
            tagRange = [tagString rangeOfString:@"]"];
            tagString = [tagString substringToIndex:tagRange.location];
            testString = [testString stringByReplacingCharactersInRange:range withString:@""];
            [lrcTagDict setObject:tagString forKey:param];
        }
    }
    NSMutableArray* lrcKeys = [[[NSMutableArray alloc] init] autorelease];
    NSMutableDictionary* lyric = [[[NSMutableDictionary alloc] init] autorelease];
    NSString* regex_lrc = @"\\[.*\\].*";
    NSArray* regexLrcArray = [testString componentsMatchedByRegex:regex_lrc];
    NSLog(@"%@", regexLrcArray);
    for (NSString* timeWithLrc in regexLrcArray)
    {
        NSString* time = [timeWithLrc substringWithRange:NSMakeRange(1, 8)];
        CGFloat tmpTime = [[time substringToIndex:2] floatValue] * 60 + [[time substringFromIndex:3] floatValue];
        NSString* tmpTimeStr = [NSString stringWithFormat:@"%f", tmpTime];
        if (tmpTime > 0.01)
        {
            [lrcKeys addObject:tmpTimeStr];
        }
        
        NSString* lrc = [timeWithLrc substringFromIndex:10];
        [lyric setValue:lrc forKey:tmpTimeStr];
    }
    [lrcKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 floatValue] > [obj2 floatValue];
    }];
    NSLog(@"%@", lrcKeys);
    NSLog(@"%@", lyric);
     */
    
    /*
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.*\\].*" options:NSRegularExpressionCaseInsensitive error:&error];
    NSAssert(error == nil, [error description]);
    NSInteger numberOfMatches = [regex numberOfMatchesInString:testString options:NSMatchingAnchored range:NSMakeRange(0, testString.length)];
    NSLog(@"%d", numberOfMatches);
    
    [regex enumerateMatchesInString:testString options:NSMatchingAnchored range:NSMakeRange(0, testString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSLog(@"%@", result);
    }];
    */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (bgTaskId != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:bgTaskId];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    NSLog(@"Appdelege remote");
    if (event.type == UIEventTypeRemoteControl)
    {
        switch (event.subtype)
        {
            case UIEventSubtypeRemoteControlPause:
            {
                NSLog(@"Pause");
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack:
            {
                NSLog(@"Next");
                break;
            }
            case UIEventSubtypeRemoteControlPreviousTrack:
            {
                NSLog(@"Previous");
                break;
            }
            default:
                break;
        }
    }
}

@end
