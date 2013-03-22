//
//  HomeViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-14.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UIScrollViewDelegate>
{
    NSArray* urlArray;
    BOOL isNowPlayingBtnAction;
    NSMutableDictionary* cacheDict;
    NSInteger listFlag;
}
@property (nonatomic, retain) NSArray* dataArray;
@property (retain, nonatomic) IBOutlet UIButton *homeBtn;
@property (retain, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageCtrl;


- (IBAction)homeBtnAction:(UIButton *)sender;
- (IBAction)nowPlayingBtnAction:(UIButton *)sender;
- (IBAction)pageCtrlValueChangedAction:(UIPageControl *)sender;

@end
