//
//  TAFlickrPhotoModel.h
//
//  Created by Atul Khatri on 20/11/16
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAFlickrPhotoModel : NSObject

@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *owner;
@property (nonatomic, assign) NSInteger farm;
@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger isfriend;
@property (nonatomic, assign) NSInteger isfamily;
@property (nonatomic, assign) NSInteger ispublic;

// Custom properties
@property (nonatomic, strong) NSURL* imageUrl;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
