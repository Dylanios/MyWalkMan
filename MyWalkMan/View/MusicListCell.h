//
//  MusicListCell.h
//  MyWalkMan
//
//  Created by youngsing on 13-3-15.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MusicListCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *albumImageView;
@property (retain, nonatomic) IBOutlet UILabel *songNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *singerNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *playTimeLabel;

@end
