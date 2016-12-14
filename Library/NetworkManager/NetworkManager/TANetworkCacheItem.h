//
//  TANetworkCacheItem.h
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TANetworkCacheItem : NSObject
- (instancetype)initWithKey:(NSString*)key data:(NSData*)data size:(long long)size andTimestamp:(long long)timestamp;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSData* data;
@property (nonatomic, assign) long long size;
@property (nonatomic, assign) long long lastUsedTimestamp;
@end
