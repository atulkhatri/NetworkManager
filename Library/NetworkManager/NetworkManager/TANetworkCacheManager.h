//
//  TANetworkCacheManager.h
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TANetworkCacheManager : NSObject
// Specify max cache size in MegaBytes, Default 10MB
@property (nonatomic, assign) float networkCacheMaxSize;

+ (instancetype)sharedInstance;
- (void)cacheData:(NSData*)data forKey:(NSString*)key;
- (NSData*)dataForKey:(NSString*)key;
- (void)clearCache;
@end
