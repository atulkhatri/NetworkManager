//
//  TAFileDownloadCell.h
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAFileDownloadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@end
