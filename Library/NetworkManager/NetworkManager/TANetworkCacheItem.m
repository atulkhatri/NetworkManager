//
//  TANetworkCacheItem.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TANetworkCacheItem.h"

@implementation TANetworkCacheItem

- (instancetype)initWithKey:(NSString*)key data:(NSData*)data size:(long long)size andTimestamp:(long long)timestamp{
    self = [super init];
    if (self) {
        self.key= key;
        self.data= data;
        self.size= size;
        self.lastUsedTimestamp= timestamp;
    }
    return self;
}
@end
