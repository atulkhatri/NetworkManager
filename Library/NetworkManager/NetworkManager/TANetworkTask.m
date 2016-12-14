//
//  TANetworkTask.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TANetworkTask.h"

@interface TANetworkTask ()
@end

@implementation TANetworkTask

- (instancetype)initWithtask:(NSURLSessionTask*)sessionTask withType:(NetworkTaskType)type{
    self = [super init];
    if(self){
        self.sessionTask= sessionTask;
        self.taskType= type;
        self.isCancelled= NO;
        self.progress= 0.0f;
    }
    return self;
}

- (void)cancel{
    if(self.sessionTask){
        [self.sessionTask cancel];
    }
    self.isCancelled= YES;
}
@end
