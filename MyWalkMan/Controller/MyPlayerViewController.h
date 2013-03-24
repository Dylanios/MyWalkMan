//
//  MyPlayerViewController.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyWalkManSoundEngine.h"

@class QQMusicSongInfo;

@interface MyPlayerViewController : UIViewController
{
    BOOL isTipsViewShow;
    BOOL isLrcViewShow;
    BOOL isExitLrcView;
    NSInteger index;
    CGFloat offset;
    
    UIBackgroundTaskIdentifier bgTaskId;
}

@property (retain, nonatomic) QQMusicSongInfo* info;

@property (retain, nonatomic) NSString* segueParent;

@property (retain, nonatomic) IBOutlet UIButton *popBackBtn;
@property (retain, nonatomic) IBOutlet UIView *titleView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *musicListBtn;

@property (retain, nonatomic) IBOutlet UIView *imageBgView;
@property (retain, nonatomic) IBOutlet UIImageView *albumImageView;

@property (retain, nonatomic) IBOutlet UIImageView *lrcMaskImageView;
@property (retain, nonatomic) IBOutlet UIScrollView *lrcBgScrollView;
@property (retain, nonatomic) IBOutlet UILabel *lrcLabel;
@property (retain, nonatomic) IBOutlet UILabel *selectedLrcLabel;

@property (retain, nonatomic) IBOutlet UIScrollView *controlScrollView;
@property (retain, nonatomic) IBOutlet UIButton *playBtn;
@property (retain, nonatomic) IBOutlet UIButton *preBtn;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
@property (retain, nonatomic) IBOutlet UIButton *pauseBtn;

@property (retain, nonatomic) IBOutlet UISlider *playingtimeSlider;

@property (retain, nonatomic) IBOutlet UIView *tipsView;
@property (retain, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *favBtn;

@property (retain, nonatomic) IBOutlet UIView *toolView;
@property (retain, nonatomic) IBOutlet UIButton *downloadBtn;
@property (retain, nonatomic) IBOutlet UIButton *moreBtn;
@property (retain, nonatomic) IBOutlet UIButton *addtoBtn;
@property (retain, nonatomic) IBOutlet UIButton *circleBtn;
@property (retain, nonatomic) IBOutlet UISlider *volumnSlider;

@property (retain, nonatomic) IBOutlet UILabel *beginTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel *endTimeLabel;

- (IBAction)playBtnAction:(UIButton *)sender;
- (IBAction)preBtnAction:(UIButton *)sender;
- (IBAction)nextBtnAction:(UIButton *)sender;
- (IBAction)pauseBtnAction:(UIButton *)sender;

- (IBAction)playingtimeSliderChanged:(UISlider *)sender;

- (IBAction)popBackBtnAction:(UIButton *)sender;
- (IBAction)musicListBtnAction:(UIButton *)sender;

- (IBAction)volumnSliderAction:(UISlider *)sender;

- (IBAction)favBtnAction:(UIButton *)sender;

- (IBAction)circleBtnAction:(UIButton *)sender;
- (IBAction)addtoBtnAction:(UIButton *)sender;
- (IBAction)downloadBtnAction:(UIButton *)sender;
- (IBAction)moreBtnAction:(UIButton *)sender;

@end
