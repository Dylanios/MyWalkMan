//
//  YSAppDelegate.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSAppDelegate.h"
#import "YSLrcParser.h"
#import <AVFoundation/AVFoundation.h>

@implementation YSAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
