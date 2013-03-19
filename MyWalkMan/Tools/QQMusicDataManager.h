//
//  QQMusicDataManager.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQMusicDataManager : NSObject
{
    NSMutableArray* _lrcKeys;
}

+ (NSArray* )handleWithData: (NSData* )newData;
+ (void)handleLrcWithData: (NSData* )newData;
+ (void)handleLrcWithString: (NSString* )lrcString;

@end
