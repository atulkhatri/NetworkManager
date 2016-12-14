//
//  TACancellableImageVC.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TACancellableImageVC.h"
#import "TANetworkManager.h"

#define kImageUrl @"https://farm6.staticflickr.com/5482/30317889204_f355621153.jpg"

@interface TACancellableImageVC ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) TANetworkTask* networkTask;
@end

@implementation TACancellableImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageView.clipsToBounds= YES;
    self.imageView.layer.cornerRadius= 5.0f;
}

- (void)startDownload{
    [self.activityIndicator startAnimating];
    self.imageView.image= nil;

    __block TACancellableImageVC* blockSelf= self;
    
    self.networkTask= [[TANetworkManager sharedInstance] dataWithUrl:[NSURL URLWithString:kImageUrl] networkTaskType:NETWORK_TASK_TYPE_FILE_DOWNLOAD params:nil success:^(id responseObject) {
        if([responseObject isKindOfClass:[NSData class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [blockSelf.activityIndicator stopAnimating];
                blockSelf.imageView.image= [UIImage imageWithData:responseObject];
                [blockSelf.downloadButton setSelected:NO];
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.activityIndicator stopAnimating];
            blockSelf.imageView.image= nil;
            [blockSelf.downloadButton setSelected:NO];
        });
    }];
}

- (void)stopDownload{
    if(self.networkTask){
        [self.networkTask cancel];
    }
}

- (IBAction)downloadButtonTapped:(id)sender {
    if(!self.downloadButton.selected){
        // Start download
        [self startDownload];
    }else{
        // Stop download
        [self stopDownload];
    }
    [self.downloadButton setSelected:!self.downloadButton.selected];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
