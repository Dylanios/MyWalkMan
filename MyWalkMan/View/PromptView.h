//
//  PromptView.h
//  ZLZP_CJW
//
//  Created by youngsing on 13-3-4.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptView : UIView
{
    CGFloat duration;
}

- initWithTitle: (NSString* )tips Duration: (CGFloat)time;
- (void)animationBeginAndEnd;

@end
