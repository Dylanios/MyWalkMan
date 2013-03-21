//
//  DownloadListCell.m
//  MyWalkMan
//
//  Created by youngsing on 13-3-19.
//  Copyright (c) 2013年 youngsing. All rights reserved.
//

#import "DownloadListCell.h"

@implementation DownloadListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_albumImageView release];
    [_progressView release];
    [_progressLabel release];
    [_songNameLabel release];
    [_singerAndAlbumNameLabel release];
    [_cancelBtn release];
    [_pauseBtn release];
    [super dealloc];
}
- (IBAction)pauseBtnAction:(UIButton *)sender {
}

- (IBAction)cancelBtnAction:(UIButton *)sender {
}
@end
