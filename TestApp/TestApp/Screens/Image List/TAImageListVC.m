//
//  TAImageListVC.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAImageListVC.h"
#import "TAImageCollectionCell.h"
#import "TANetworkManager.h"
#import "TAFlickrPhotoModel.h"

#define screenSize [UIScreen mainScreen].bounds.size
#define kCellReuseIdentifier @"ImageListCell"
#define kFlickrAPIKey @"433ff6b9d52b7e184698280338149ac6"
#define kFlickrAPIPath @"https://api.flickr.com/services/rest/"
#define kFlickrSecretKey @"c37047fac13631ae"
#define kPerPageCount 10

@interface TAImageListVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray* dataArray;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL hasMoreData;
@property (nonatomic, assign) BOOL isFetchingData;
@end

@implementation TAImageListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerNib:[UINib nibWithNibName:@"TAImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:kCellReuseIdentifier];
    
    self.currentPage= 0;
    self.hasMoreData= YES;
    self.dataArray= [NSMutableArray new];

    
    [self fetchFlickrData];
}

- (void)fetchFlickrData{
    NSMutableDictionary* params= [NSMutableDictionary new];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:@"random" forKey:@"sort"];
    [params setObject:@"flickr.photos.search" forKey:@"method"];
    [params setObject:@"sky" forKey:@"tags"];
    [params setObject:@"all" forKey:@"tag_mode"];
    [params setObject:kFlickrAPIKey forKey:@"api_key"];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"nojsoncallback"];
    [params setObject:[NSNumber numberWithInteger:kPerPageCount] forKey:@"per_page"];
    [params setObject:[NSNumber numberWithInteger:++self.currentPage] forKey:@"page"];
    self.isFetchingData= YES;
    [self.activityIndicator startAnimating];
    __block TAImageListVC* blockSelf= self;
    
    [[TANetworkManager sharedInstance] dataWithUrl:[NSURL URLWithString:kFlickrAPIPath] networkTaskType:NETWORK_TASK_TYPE_JSON_GET params:params success:^(id responseObject) {
        NSDictionary* responseDict= [self responseDictionaryForData:responseObject];
        blockSelf.isFetchingData= NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.activityIndicator stopAnimating];
        });
        NSDictionary* photosDict= [responseDict objectForKey:@"photos"];
        if(photosDict.count>0){
            NSArray* photos= [photosDict objectForKey:@"photo"];
            if(photos.count < kPerPageCount){
                blockSelf.hasMoreData= NO;
            }
            if(photos.count>0){
                for(NSDictionary* photo in photos){
                    TAFlickrPhotoModel* photoModel= [[TAFlickrPhotoModel alloc] initWithDictionary:photo];
                    NSString* imagePath= [NSString stringWithFormat:@"https://farm%ld.staticflickr.com/%@/%@_%@_n.jpg", photoModel.farm, photoModel.server, photoModel.photoId, photoModel.secret];
                    photoModel.imageUrl= [NSURL URLWithString:imagePath];
                    [blockSelf.dataArray addObject:photoModel];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [blockSelf.collectionView reloadData];
                });
            }
        }
    } failure:^(NSError *error) {
        blockSelf.isFetchingData= NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [blockSelf.activityIndicator stopAnimating];
        });
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (NSDictionary*)responseDictionaryForData:(id)data{
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response:   %@",dataString);
    NSData *objectData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:nil];
    return json;
}

#pragma mark - UICollectionViewDataSource/Delegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TAImageCollectionCell* cell= [collectionView dequeueReusableCellWithReuseIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    cell.tag= indexPath.row;
    TAFlickrPhotoModel* photoModel= [self.dataArray objectAtIndex:indexPath.row];
    __block TAImageCollectionCell* blockCell= cell;

    [[TANetworkManager sharedInstance] dataWithUrl:photoModel.imageUrl networkTaskType:NETWORK_TASK_TYPE_IMAGE params:nil success:^(id responseObject) {
        if([responseObject isKindOfClass:[NSData class]]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(blockCell.tag == indexPath.row){
                    [blockCell.activityIndicator stopAnimating];
                    blockCell.imageView.image= [UIImage imageWithData:responseObject];
                }
            });
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(blockCell.tag == indexPath.row){
                [blockCell.activityIndicator stopAnimating];
                blockCell.imageView.image= nil;
            }
        });
    }];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // Show full screen image if necessary
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count-1 == indexPath.row && self.hasMoreData && !self.isFetchingData){
        [self fetchFlickrData];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth= (screenSize.width/2);
    return CGSizeMake(cellWidth, cellWidth+20.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0.0f;
}

#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
