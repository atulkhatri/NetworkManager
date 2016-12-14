//
//  TAImageCollectionCell.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAImageCollectionCell.h"

@implementation TAImageCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.clipsToBounds= YES;
    self.activityIndicator.hidesWhenStopped= YES;
}

- (void)prepareForReuse{
    self.imageView.image= nil;
    self.activityIndicator.hidden= NO;
}

@end
