//
//  MyWalkManDownLoadEngine.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "MyWalkManDownLoadEngine.h"
#import "ASIHTTPRequest.h"
#import "QQMusicSongInfo.h"
#import <AVFoundation/AVFoundation.h>

NSString* const YSDownloadStateChangedNotification = @"YSDownloadStateChangedNotification";

static MyWalkManDownLoadEngine* engine = nil;

@implementation MyWalkManDownLoadEngine

-(void)dealloc
{
    RELEASE_SAFELY(engine);
    RELEASE_SAFELY(_queue);
//    RELEASE_SAFELY(_dataArray);
    RELEASE_SAFELY(_requestArray);
    [super dealloc];
}

+ (MyWalkManDownLoadEngine* )shareEngine
{
    @synchronized (self)
    {
        if (nil == engine)
        {
            engine = [[MyWalkManDownLoadEngine alloc] init];
            [engine.queue setShowAccurateProgress:YES];
            [engine.queue setMaxConcurrentOperationCount:1];
            [engine.queue setShouldCancelAllRequestsOnFailure:NO];
            engine.queue.delegate = self;
            [engine.queue go];
        }
        return engine;
    }
}

- (id)init
{
    if (self = [super init])
    {
        self.queue = [[[ASINetworkQueue alloc] init] autorelease];
        self.requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addRequest:(ASIHTTPRequest *)request
{
    request.delegate = self;
    [self.requestArray addObject:request];
    [self.queue addOperation:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    _state = YSSuccess;
    QQMusicSongInfo* toDeleteInfo = [request.userInfo objectForKey:@"info"];
    
    [request.responseData writeToFile:toDeleteInfo.musicPath atomically:YES];
    
    NSDictionary* paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"isDown", nil];
    [[YSDatabaseManager shareDatabaseManager] insertWithMusicInfo:toDeleteInfo Param:paramDict];
    
    [self.requestArray removeObject:request];
    
    SystemSoundID soundID;
    NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"success" ofType:@"caf"]];
    AudioServicesCreateSystemSoundID((CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    NSNotification* notification = [NSNotification notificationWithName:YSDownloadStateChangedNotification
                                                                 object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _state = YSFailed;
    [self.requestArray removeObject:request];
//    request can
    
    NSNotification* notififation = [NSNotification notificationWithName:YSDownloadStateChangedNotification
                                                                 object:self];
    [[NSNotificationCenter defaultCenter] postNotification:notififation];
}

@end
