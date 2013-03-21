//
//  YSLrcParser.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-18.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "YSLrcParser.h"
#import "RegexKitLite.h"

@implementation YSLrcParser
+ (YSLrc *)lrcWith:(NSString *)lrcString
{
    NSMutableString* tmpLrcString = [NSMutableString stringWithString:lrcString];
    YSLrc* ysLrc = [YSLrc ysLrc];
    
    /* 将歌词的标识标签先单独提取出来，并存入一个字典
     *
     * lrc歌词的标识标签格式
     *
     * [ar:歌手名]－artist艺术家、演唱者
     * [ti:歌曲名]－title题目,标题,曲目
     * [al:专辑名]－album唱片集、专辑
     * [by:编辑者]－（介词）制作者、编辑人员(一般指lrc歌词的制作人)
     * [offset:时间补偿值]－其单位是毫秒，正值表示延迟，负值表示提前。用于整体调整歌词显示慢（快）于音乐播放。
     */
    NSArray* regexTagArray = [NSArray arrayWithObjects:@"ti", @"ar", @"al", @"offset", @"by", nil];
    for (NSString* param in regexTagArray)
    {
        NSString* regex = [NSString stringWithFormat:@"\\[%@:.*\\]", param];
        NSRange range = [tmpLrcString rangeOfString:regex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound)
        {
            NSString* tagString = [tmpLrcString substringWithRange:range];
            NSRange tagRange = [tagString rangeOfString:@":"];
            tagString = [tagString substringFromIndex:tagRange.location + 1];
            tagRange = [tagString rangeOfString:@"]"];
            tagString = [tagString substringToIndex:tagRange.location];
            tmpLrcString = (NSMutableString* )[tmpLrcString stringByReplacingCharactersInRange:range withString:@""];
            
            [ysLrc.lrcTagDict setObject:tagString forKey:param];
        }
    }
    
    //歌词的偏移时间
    CGFloat offset = [[ysLrc.lrcTagDict objectForKey:@"offset"] floatValue] / 1000;
    NSLog(@"%f", offset);
    
    NSString* regex_lrc = @"\\[.*\\].*";
    NSArray* regexLrcArray = [tmpLrcString componentsMatchedByRegex:regex_lrc];
    for (NSString* timeWithLrc in regexLrcArray)
    {
        NSString* tmpTimeWithLrc = timeWithLrc;
        // numberOfTimeTags 判断单条歌词前存在几个时间标签 Eg:[02:53.84][00:07.74]蔡琴不了情2007经典歌曲香港演唱会
        NSError* error = nil;
        NSRegularExpression* regex_time = [NSRegularExpression regularExpressionWithPattern:@"\\[.{5,8}\\]"
                                                                                    options:NSRegularExpressionAnchorsMatchLines
                                                                                      error:&error];
        NSAssert(error == nil, [error description]);
        
        NSInteger numberOfTimeTags = [regex_time numberOfMatchesInString:tmpTimeWithLrc
                                                                 options:NSMatchingReportCompletion
                                                                   range:NSMakeRange(0, tmpTimeWithLrc.length)];
        //将时间标签分离出来
        NSMutableArray* timeTagArray = [NSMutableArray arrayWithCapacity:numberOfTimeTags];
        for (int i = 0; i < numberOfTimeTags; ++i)
        {
            NSRange range = [tmpTimeWithLrc rangeOfString:@"]"];
            NSString* time = [tmpTimeWithLrc substringWithRange:NSMakeRange(1, range.location - 1)];
            CGFloat tmpTime = [[time substringToIndex:2] floatValue] * 60 + [[time substringFromIndex:3] floatValue];
            tmpTime += offset;
            NSString* tmpTimeStr = [NSString stringWithFormat:@"%f", tmpTime];
            if (tmpTime > 0.01)
            {
                [ysLrc.lrcKeys addObject:tmpTimeStr];
                [timeTagArray addObject:tmpTimeStr];
            }
            
            tmpTimeWithLrc = [tmpTimeWithLrc substringFromIndex:range.location + 1];
        }
        
        for (NSString* key in timeTagArray)
        {
            [ysLrc.lyric setObject:tmpTimeWithLrc forKey:key];
        }
        
    }
    [ysLrc.lrcKeys sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 floatValue] > [obj2 floatValue];
    }];
    
    return ysLrc;
}

@end

@implementation YSLrc
@synthesize lyric = _lyric, lrcKeys = _lrcKeys, lrcTagDict = _lrcTagDict;

+ (YSLrc *)ysLrc
{
    return [[[YSLrc alloc] init] autorelease];
}

- (NSMutableDictionary *)lyric
{
    if (_lyric == nil)
    {
        _lyric = [[NSMutableDictionary alloc] init];
    }
    return _lyric;
}

- (NSMutableArray *)lrcKeys
{
    if (_lrcKeys == nil)
    {
        _lrcKeys = [[NSMutableArray alloc] init];
    }
    return _lrcKeys;
}

- (NSMutableDictionary *)lrcTagDict
{
    if (_lrcTagDict == nil)
    {
        _lrcTagDict = [[NSMutableDictionary alloc] init];
    }
    return _lrcTagDict;
}

@end