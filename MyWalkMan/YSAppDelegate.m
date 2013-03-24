//
//  YSAppDelegate.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSAppDelegate.h"

@implementation YSAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    BOOL isDirectoryCreated = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isDirectoryCreated"] boolValue];
    if (!isDirectoryCreated)
    {
        NSString* cacheFilePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* musicFilePath = [cacheFilePath stringByAppendingPathComponent:@"com.youngsing.cachemusic"];
        [[NSFileManager defaultManager] createDirectoryAtPath:musicFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        NSString* lrcFilePath = [cacheFilePath stringByAppendingPathComponent:@"com.youngsing.cachelrc"];
        [[NSFileManager defaultManager] createDirectoryAtPath:lrcFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDirectoryCreated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /*
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
    NSString* tmpFilePath = NSTemporaryDirectory();
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:tmpFilePath error:&error];
    YSLog(@"%@", [error description]);
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
