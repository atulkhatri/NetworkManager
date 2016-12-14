//
//  TAFileDownloadCell.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAFileDownloadCell.h"

@implementation TAFileDownloadCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.bgImageView.clipsToBounds= YES;
}

- (void)prepareForReuse{
    self.bgImageView.image= nil;
    self.progressView.progress= 0.0f;
    self.progressLabel.text= @"";
}

@end
