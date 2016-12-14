//
//  TAHomeVC.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAHomeVC.h"
#import "TAImageListVC.h"
#import "TACancellableImageVC.h"
#import "TAFileDownloadVC.h"

#define kCellHeight 60.0f
#define kOptionParallelImageDownload @"Parallel Image Download"
#define kOptionFileDownload @"File Download"
#define kOptionCancellableImage @"Cancellable Image"

@interface TAHomeVC () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* dataArray;
@end

@implementation TAHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title= @"Choose an option";
    
    self.dataArray= @[kOptionParallelImageDownload, kOptionCancellableImage, kOptionFileDownload];
    
    [self.tableView reloadData];
}

#pragma mark- UITableViewDataSource/Delegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* reuseIdentifier= @"OptionCell";
    UITableViewCell* cell= [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.imageView.clipsToBounds= YES;
    cell.imageView.contentMode= UIViewContentModeScaleAspectFit;
    
    NSString* option= [self.dataArray objectAtIndex:indexPath.row];
    if([option isEqualToString:kOptionParallelImageDownload]){
        cell.imageView.image= [UIImage imageNamed:@"parallel_icon"];
    }else if([option isEqualToString:kOptionCancellableImage]){
        cell.imageView.image= [UIImage imageNamed:@"imagecancel_icon"];
    }else if([option isEqualToString:kOptionFileDownload]){
        cell.imageView.image= [UIImage imageNamed:@"download_icon"];
    }
    
    cell.textLabel.text= option;
    cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* option= [self.dataArray objectAtIndex:indexPath.row];
    UIViewController* vc= nil;
    if([option isEqualToString:kOptionParallelImageDownload]){
        vc= [[TAImageListVC alloc] initWithNibName:@"TAImageListVC" bundle:nil];
    }else if([option isEqualToString:kOptionCancellableImage]){
        vc= [[TACancellableImageVC alloc] initWithNibName:@"TACancellableImageVC" bundle:nil];
    }else if([option isEqualToString:kOptionFileDownload]){
        vc= [[TAFileDownloadVC alloc] initWithNibName:@"TAFileDownloadVC" bundle:nil];
    }
    if(vc){
        vc.title= option;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
