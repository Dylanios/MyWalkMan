//
//  HomeViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSViewTransitionProtocol.h"

@interface HomeViewController : UIViewController <UIScrollViewDelegate, YSViewTransitionProtocol>
{
    NSArray* urlArray;  //音乐来源获取地址
    NSMutableDictionary* cacheDict; //播放列表的缓存
    NSInteger listFlag; //指示将要加载哪个列表
}
@property (nonatomic, retain) NSArray* dataArray;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageCtrl;


- (IBAction)homeBtnAction:(UIButton *)sender;
- (IBAction)pageCtrlValueChangedAction:(UIPageControl *)sender;

@end
