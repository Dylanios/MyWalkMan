//
//  DownloadListCell.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *albumImageView;
@property (retain, nonatomic) IBOutlet UIProgressView *progressView;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *singerAndAlbumNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;
@property (retain, nonatomic) IBOutlet UIButton *pauseBtn;


- (IBAction)pauseBtnAction:(UIButton *)sender;
- (IBAction)cancelBtnAction:(UIButton *)sender;


@end
