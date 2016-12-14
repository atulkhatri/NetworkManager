//
//  TANetworkCacheManager.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TANetworkCacheManager.h"
#import "TANetworkCacheItem.h"

@interface TANetworkCacheManager()
@property (nonatomic, strong) NSMutableDictionary* cacheDictionary;
@property (nonatomic, strong) NSMutableArray* cachedItems;
@property (nonatomic, assign) double totalCacheSize;
@end

@implementation TANetworkCacheManager
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.cacheDictionary= [NSMutableDictionary new];
        self.cachedItems= [NSMutableArray new];
        self.networkCacheMaxSize= 10.0f;
    }
    return self;
}

- (void)cacheData:(NSData*)data forKey:(NSString*)key{
    @synchronized (self) {
        if(data && key.length>0 && ![self.cacheDictionary objectForKey:key]){
            TANetworkCacheItem* cacheItem= [[TANetworkCacheItem alloc] initWithKey:key data:data size:data.length andTimestamp:[self currentTimestamp]];
            self.totalCacheSize += ((float)data.length/1024.0f/1024.0f);
            [self.cacheDictionary setObject:cacheItem forKey:key];
            [self.cachedItems insertObject:cacheItem atIndex:0];
            // Check if max limit reached. If yes, remove items from cache
            if(self.totalCacheSize > self.networkCacheMaxSize){
                [self deleteExcessObjects];
            }
        }
    }
}

- (NSData*)dataForKey:(NSString*)key{
    @synchronized (self) {
        if(key.length>0){
            TANetworkCacheItem* cachedItem= [self.cacheDictionary objectForKey:key];
            if(cachedItem){
                [self.cachedItems removeObject:cachedItem];
                [self.cachedItems insertObject:cachedItem atIndex:0];
                return cachedItem.data;
            }
            return nil;
        }
        return nil;
    }
}

- (void)clearCache{
    [self.cacheDictionary removeAllObjects];
    [self.cachedItems removeAllObjects];
}

#pragma mark- Helper methods

- (long long)currentTimestamp{
    return [[NSDate date] timeIntervalSince1970];
}

- (void)deleteExcessObjects{
    while(self.totalCacheSize > self.networkCacheMaxSize){
        TANetworkCacheItem* item= [self.cachedItems lastObject];
        self.totalCacheSize -= ((float)item.data.length/1024.0f/1024.0f);
        [self.cacheDictionary removeObjectForKey:item.key];
        [self.cachedItems removeObject:item];
    }
}
@end
