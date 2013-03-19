//
//  YSLrcParser.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-18.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSLrc;

@interface YSLrcParser : NSObject

+ (YSLrc *)lrcWith:(NSString* )lrcString;

@end

@interface YSLrc : NSObject

@property (readonly, retain, nonatomic) NSMutableDictionary* lyric; // time:value
@property (readonly, retain, nonatomic) NSMutableArray* lrcKeys;
@property (readonly, retain, nonatomic) NSMutableDictionary* lrcTagDict; // keys: ti ar al by offset

+ (YSLrc *)ysLrc;

@end