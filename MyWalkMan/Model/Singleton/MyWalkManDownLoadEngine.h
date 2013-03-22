//
//  MyWalkManDownLoadEngine.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-22.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASINetworkQueue.h"

typedef enum 
{
    YSSuccess = 0,
    YSFailed
}YSDownloadState;

extern NSString* const YSDownloadStateChangedNotification;

@interface MyWalkManDownLoadEngine : NSObject <ASIHTTPRequestDelegate>

@property (nonatomic, retain) ASINetworkQueue* queue;
@property (nonatomic, retain) NSMutableArray* requestArray;
@property (nonatomic, readonly) YSDownloadState state;

+ (MyWalkManDownLoadEngine* )shareEngine;
- (void)addRequest: (ASIHTTPRequest* )request;

@end
