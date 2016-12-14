//
//  TAFileInfoModel.h
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TANetworkTask.h"

@interface TAFileInfoModel : NSObject
- (instancetype)initWithUrl:(NSURL*)url andType:(NSString*)type;
@property (nonatomic, strong) NSURL* url;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) TANetworkTask* networkTask;
@property (nonatomic, strong) NSString* downloadedPath;
@end
