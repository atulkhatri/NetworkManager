//
//  TANetworkTask.h
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NETWORK_TASK_TYPE_JSON_GET,
    NETWORK_TASK_TYPE_JSON_POST,
    NETWORK_TASK_TYPE_IMAGE,
    NETWORK_TASK_TYPE_FILE_DOWNLOAD
}NetworkTaskType;

@interface TANetworkTask : NSObject
- (instancetype)initWithtask:(NSURLSessionTask*)sessionTask withType:(NetworkTaskType)type;
- (void)cancel;
@property (nonatomic, assign) NetworkTaskType taskType;
@property (nonatomic, strong) NSURLSessionTask* sessionTask;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isCompleted;
@end
