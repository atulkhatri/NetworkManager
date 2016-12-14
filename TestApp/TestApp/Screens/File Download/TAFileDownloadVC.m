//
//  TAFileDownloadVC.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAFileDownloadVC.h"
#import "TAFileInfoModel.h"
#import "TAFileDownloadCell.h"
#import "TANetworkManager.h"
#import <MediaPlayer/MediaPlayer.h>

#define kCellHeight 100.0f
#define kReuseIdentifier @"FileDownloadCell"
#define kVideoUrl @"http://content1.vuliv.com/discover/admin@vuliv.com/1479206206631_Teaser4_20161111_1.mp4"
#define kPDFUrl @"http://www.pdf995.com/samples/pdf.pdf"
#define kZipUrl @"http://www.7-zip.org/a/7za920.zip"

@interface TAFileDownloadVC () <UITableViewDataSource, UITableViewDelegate, TANetworkManagerDelegate, UIDocumentInteractionControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* dataArray;
@property (nonatomic, strong) UIProgressView *progressView;

// For PDF file preview
@property (nonatomic, strong) UIDocumentInteractionController* documentInteractionController;

@end

@implementation TAFileDownloadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataArray= [NSMutableArray new];
    [self.dataArray addObject:[[TAFileInfoModel alloc] initWithUrl:[NSURL URLWithString:kVideoUrl] andType:@"Video"]];
    [self.dataArray addObject:[[TAFileInfoModel alloc] initWithUrl:[NSURL URLWithString:kPDFUrl] andType:@"PDF"]];
    [self.dataArray addObject:[[TAFileInfoModel alloc] initWithUrl:[NSURL URLWithString:kZipUrl] andType:@"ZIP"]];
    
    [self.tableView reloadData];
}

- (void)downloadFile:(TAFileInfoModel*)fileInfoModel{
    TANetworkTask* networkTask= [[TANetworkManager sharedInstance] downloadFileWithUrl:fileInfoModel.url withNetworkManagerDelegate:self];
    fileInfoModel.networkTask= networkTask;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [TANetworkManager sharedInstance].delegate= nil;
}

- (TAFileInfoModel*)fileModelForNetworkTask:(TANetworkTask*)networkTask{
    for(TAFileInfoModel* fileInfo in self.dataArray){
        if([fileInfo.networkTask isEqual:networkTask]){
            return fileInfo;
        }
    }
    return nil;
}

- (void)reloadIndexpathForNetworkTask:(TANetworkTask*)networkTask{
    TAFileInfoModel* fileInfo= [self fileModelForNetworkTask:networkTask];
    NSInteger index= [self.dataArray indexOfObject:fileInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark- UITableViewDataSource/Delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TAFileDownloadCell* cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if (cell == nil) {
        NSArray* nibs = [[NSBundle mainBundle] loadNibNamed:@"TAFileDownloadCell" owner:self options:nil];
        cell = [nibs objectAtIndex:0];
    }
    cell.progressView.hidden= YES;
    cell.progressLabel.hidden= YES;
    cell.downloadLabel.hidden= YES;
    TAFileInfoModel* fileInfo= [self.dataArray objectAtIndex:indexPath.row];
    if(!fileInfo.networkTask.isDownloading && !fileInfo.networkTask.isCancelled && !fileInfo.networkTask.isCompleted){
        cell.downloadLabel.hidden= NO;
        cell.downloadLabel.text= [NSString stringWithFormat:@"Download %@", fileInfo.type];
    }else if(fileInfo.networkTask.isCompleted){
        if([fileInfo.url.absoluteString isEqualToString:kVideoUrl]){
            cell.bgImageView.image= [UIImage imageNamed:@"play_icon"];
        }else if([fileInfo.url.absoluteString isEqualToString:kPDFUrl]){
            cell.bgImageView.image= [UIImage imageNamed:@"pdf_icon"];
        }else if([fileInfo.url.absoluteString isEqualToString:kZipUrl]){
            cell.bgImageView.image= [UIImage imageNamed:@"zip_icon"];
        }
    }else if(fileInfo.networkTask.isDownloading){
        cell.progressView.hidden= NO;
        cell.progressLabel.hidden= NO;
        cell.progressLabel.text= [NSString stringWithFormat:@"%.0f%%", fileInfo.networkTask.progress*100];
        cell.progressView.progress= fileInfo.networkTask.progress;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TAFileInfoModel* fileInfo= [self.dataArray objectAtIndex:indexPath.row];
    if(!fileInfo.networkTask.isDownloading && !fileInfo.networkTask.isCancelled && !fileInfo.networkTask.isCompleted){
        [self downloadFile:fileInfo];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if(fileInfo.networkTask.isCompleted){
        [self openFileInforModel:fileInfo];
    }
}

- (void)openFileInforModel:(TAFileInfoModel*)infoModel{
    if([infoModel.url.absoluteString isEqualToString:kVideoUrl]){
        // Play video
        MPMoviePlayerViewController* vc = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:infoModel.downloadedPath]];
        [self presentMoviePlayerViewControllerAnimated:vc];
        [vc.moviePlayer play];
    }else if([infoModel.url.absoluteString isEqualToString:kPDFUrl]){
        // Preview pdf
        self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:infoModel.downloadedPath]];
        [self.documentInteractionController setDelegate:self];
        [self.documentInteractionController presentPreviewAnimated:YES];
    }else {
        // Show share dialog
        NSURL *url = [NSURL fileURLWithPath:infoModel.downloadedPath];
        UIActivityViewController* activityController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
        [self presentViewController:activityController animated:YES completion:nil];
    }

}

- (NSString*)documentDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return (paths.count)? paths[0] : nil;
}

- (NSURL *)filesDirectory{
    NSString *filesPath = [[self documentDirectoryPath] stringByAppendingPathComponent:@"Files"];
    NSURL *filesUrl= [NSURL fileURLWithPath:filesPath];
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filesPath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtURL:filesUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"[Thumbnail Directory] %@", [error description]);
            return nil;
        }
    }
    return filesUrl;
}

#pragma mark- TANetworkManagerDelegate methods
- (void)networkTask:(TANetworkTask *)networkTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    [self reloadIndexpathForNetworkTask:networkTask];
}

- (void)networkTask:(TANetworkTask *)networkTask didFinishDownloadingToURL:(NSURL *)location{
    TAFileInfoModel* fileInfo= [self fileModelForNetworkTask:networkTask];
    NSString* path = [self filesDirectory].path;
    NSString* fileName= [fileInfo.url lastPathComponent];
    path = [path stringByAppendingPathComponent:fileName];
    fileInfo.downloadedPath= path;
    if (location) {
        // Remove file if already exists
        if([[NSFileManager defaultManager] fileExistsAtPath:path]){
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:&error];
        if (error){
            NSLog(@"Error %@",error.description);
            NSError* errorWrite = nil;
            NSData* data = [NSData dataWithContentsOfURL:location];
            [data writeToFile:path options:NSDataWritingAtomic error:&errorWrite];
        }
    }
    [self reloadIndexpathForNetworkTask:networkTask];
}

- (void)networkTask:(TANetworkTask *)networkTask didCompleteWithError:(NSError *)error{
    [self reloadIndexpathForNetworkTask:networkTask];
}

#pragma mark- UIDocumentInteractionControllerDelegate method
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller{
    return self;
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
