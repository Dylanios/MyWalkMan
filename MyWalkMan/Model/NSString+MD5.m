//
//  NSString+MD5.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-21.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (MD5)

+ (NSString *)calMD5WithName:(NSString *)name
{
    const char* tmpCstring = [name UTF8String];
    unsigned char result[16];
    CC_MD5(tmpCstring, strlen(tmpCstring), result);
    NSString* resultStr = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
    return resultStr;
}

@end
