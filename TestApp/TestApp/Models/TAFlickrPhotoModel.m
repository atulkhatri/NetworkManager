//
//  TAFlickrPhotoModel.m
//
//  Created by Atul Khatri on 20/11/16
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAFlickrPhotoModel.h"


NSString *const kTAFlickrPhotoModelSecret = @"secret";
NSString *const kTAFlickrPhotoModelOwner = @"owner";
NSString *const kTAFlickrPhotoModelFarm = @"farm";
NSString *const kTAFlickrPhotoModelId = @"id";
NSString *const kTAFlickrPhotoModelServer = @"server";
NSString *const kTAFlickrPhotoModelTitle = @"title";
NSString *const kTAFlickrPhotoModelIsfriend = @"isfriend";
NSString *const kTAFlickrPhotoModelIsfamily = @"isfamily";
NSString *const kTAFlickrPhotoModelIspublic = @"ispublic";


@interface TAFlickrPhotoModel ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation TAFlickrPhotoModel

@synthesize secret = _secret;
@synthesize owner = _owner;
@synthesize farm = _farm;
@synthesize photoId = _photoId;
@synthesize server = _server;
@synthesize title = _title;
@synthesize isfriend = _isfriend;
@synthesize isfamily = _isfamily;
@synthesize ispublic = _ispublic;

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];

    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.secret = [self objectOrNilForKey:kTAFlickrPhotoModelSecret fromDictionary:dict];
            self.owner = [self objectOrNilForKey:kTAFlickrPhotoModelOwner fromDictionary:dict];
            self.farm = [[self objectOrNilForKey:kTAFlickrPhotoModelFarm fromDictionary:dict] integerValue];
            self.photoId = [self objectOrNilForKey:kTAFlickrPhotoModelId fromDictionary:dict];
            self.server = [self objectOrNilForKey:kTAFlickrPhotoModelServer fromDictionary:dict];
            self.title = [self objectOrNilForKey:kTAFlickrPhotoModelTitle fromDictionary:dict];
            self.isfriend = [[self objectOrNilForKey:kTAFlickrPhotoModelIsfriend fromDictionary:dict] integerValue];
            self.isfamily = [[self objectOrNilForKey:kTAFlickrPhotoModelIsfamily fromDictionary:dict] integerValue];
            self.ispublic = [[self objectOrNilForKey:kTAFlickrPhotoModelIspublic fromDictionary:dict] integerValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.secret forKey:kTAFlickrPhotoModelSecret];
    [mutableDict setValue:self.owner forKey:kTAFlickrPhotoModelOwner];
    [mutableDict setValue:[NSNumber numberWithInteger:self.farm] forKey:kTAFlickrPhotoModelFarm];
    [mutableDict setValue:self.photoId forKey:kTAFlickrPhotoModelId];
    [mutableDict setValue:self.server forKey:kTAFlickrPhotoModelServer];
    [mutableDict setValue:self.title forKey:kTAFlickrPhotoModelTitle];
    [mutableDict setValue:[NSNumber numberWithInteger:self.isfriend] forKey:kTAFlickrPhotoModelIsfriend];
    [mutableDict setValue:[NSNumber numberWithInteger:self.isfamily] forKey:kTAFlickrPhotoModelIsfamily];
    [mutableDict setValue:[NSNumber numberWithInteger:self.ispublic] forKey:kTAFlickrPhotoModelIspublic];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}

@end
