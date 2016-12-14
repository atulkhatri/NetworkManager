//
//  TANetworkManager.m
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TANetworkManager.h"
#import "TANetworkCacheManager.h"

@interface TANetworkManager() <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession* multiFileSession;
@property (nonatomic, strong) NSMutableArray* downloadTasks;
@end

@implementation TANetworkManager
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadTasks= [NSMutableArray new];
        self.networkCacheMaxSize= 10.0f;
        self.networkTimeoutDuration= 60.0f;
    }
    return self;
}

- (NSURLSession*)createSessionWithDelegate:(id)delegate{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    if(delegate){
        return [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }else{
        return [NSURLSession sessionWithConfiguration:configuration];
    }
}

- (void)clearCache{
    [[TANetworkCacheManager sharedInstance] clearCache];
}

- (void)setNetworkCacheMaxSize:(float)networkCacheMaxSize{
    _networkCacheMaxSize = networkCacheMaxSize;
    [TANetworkCacheManager sharedInstance].networkCacheMaxSize= networkCacheMaxSize;
}

- (TANetworkTask*)dataWithUrl:(NSURL*)url networkTaskType:(NetworkTaskType)taskType params:(NSDictionary*)params success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock{
    TANetworkTask* networkTask= nil;
    switch (taskType) {
        case NETWORK_TASK_TYPE_JSON_GET:{
            networkTask= [self jsonRequestWithMethodType:HTTP_METHOD_TYPE_GET url:url params:params success:^(id responseObject) {
                successBlock(responseObject);
            } failure:^(NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case NETWORK_TASK_TYPE_JSON_POST:{
            networkTask= [self jsonRequestWithMethodType:HTTP_METHOD_TYPE_POST url:url params:params success:^(id responseObject) {
                successBlock(responseObject);
            } failure:^(NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case NETWORK_TASK_TYPE_IMAGE:{
            networkTask= [self downloadImageWithUrl:url success:^(id responseObject) {
                successBlock(responseObject);
            } failure:^(NSError *error) {
                failureBlock(error);
            }];
            break;
        }
        case NETWORK_TASK_TYPE_FILE_DOWNLOAD:{
            networkTask= [self downloadFileWithUrl:url success:^(id responseObject) {
                successBlock(responseObject);
            } failure:^(NSError *error) {
                failureBlock(error);
            }];
            break;
        }
    }
    
    return networkTask;
}

- (TANetworkTask*)jsonRequestWithMethodType:(HttpMethodType)type url:(NSURL*)url params:(NSDictionary*)params success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock{
    NSMutableURLRequest *request = nil;
    NSString* path= url.absoluteString;
    NSURL* newUrl= [NSURL URLWithString:path];
    switch (type) {
        case HTTP_METHOD_TYPE_GET:{
            [request setHTTPMethod:@"GET"];
            if(params){
                path= [NSString stringWithFormat:@"%@%@",path, [self queryStringFromDictionary:params]];
                newUrl= [NSURL URLWithString:path];
            }
            request= [NSMutableURLRequest requestWithURL:newUrl];
            break;
        }
        case HTTP_METHOD_TYPE_POST:{
            [request setHTTPMethod:@"POST"];
            request= [NSMutableURLRequest requestWithURL:newUrl];
            if(params){
                NSError *error;
                NSData *postData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
                [request setHTTPBody:postData];
            }
            break;
        }
    }
    
    // Only return cached data if method type is GET. Since for POST request, parameters can be different
    if(type == HTTP_METHOD_TYPE_GET){
        NSData* cachedData= [[TANetworkCacheManager sharedInstance] dataForKey:newUrl.absoluteString];
        if(cachedData){
            successBlock(cachedData);
            return [TANetworkTask new];
        }
    }
    
    request.timeoutInterval = self.networkTimeoutDuration;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSession *session= [self createSessionWithDelegate:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            failureBlock(error);
        }else{
            if(type == HTTP_METHOD_TYPE_GET){
                [[TANetworkCacheManager sharedInstance] cacheData:data forKey:response.URL.absoluteString];
            }
            successBlock(data);
        }
    }];
    [task resume];
    
    TANetworkTask* networkTask= [[TANetworkTask alloc] initWithtask:task withType:NETWORK_TASK_TYPE_JSON_GET];
    return networkTask;
}

- (TANetworkTask*)downloadFileWithUrl:(NSURL*)url success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = self.networkTimeoutDuration;
    NSURLSession* session= [self createSessionWithDelegate:nil];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            failureBlock(error);
        }else{
            NSData *data = [NSData dataWithContentsOfURL:location];
            successBlock(data);
        }
    }];
    [task resume];
    TANetworkTask* networkTask= [[TANetworkTask alloc] initWithtask:task withType:NETWORK_TASK_TYPE_FILE_DOWNLOAD];
    return networkTask;
}

- (TANetworkTask*)downloadFileWithUrl:(NSURL*)url withNetworkManagerDelegate:(id <TANetworkManagerDelegate>)delegate{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = self.networkTimeoutDuration;
    self.delegate= delegate;
    if(!self.multiFileSession){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.multiFileSession= [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    NSURLSessionDownloadTask *task = [self.multiFileSession downloadTaskWithRequest:request];
    [task resume];
    TANetworkTask* networkTask= [[TANetworkTask alloc] initWithtask:task withType:NETWORK_TASK_TYPE_FILE_DOWNLOAD];
    [self.downloadTasks addObject:networkTask];
    return networkTask;
}

- (TANetworkTask*)downloadImageWithUrl:(NSURL*)url success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock{
    NSData* cachedData= [[TANetworkCacheManager sharedInstance] dataForKey:url.absoluteString];
    if(cachedData){
        successBlock(cachedData);
        return [TANetworkTask new];
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.timeoutInterval = self.networkTimeoutDuration;
        NSURLSession *session= [self createSessionWithDelegate:nil];
        __block NSURL* blockUrl= url;
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error){
                failureBlock(error);
            }else{
                NSData *data = [NSData dataWithContentsOfURL:location];
                [[TANetworkCacheManager sharedInstance] cacheData:data forKey:blockUrl.absoluteString];
                successBlock(data);
            }
        }];
        [task resume];
        TANetworkTask* networkTask= [[TANetworkTask alloc] initWithtask:task withType:NETWORK_TASK_TYPE_IMAGE];
        return networkTask;
    }
}

-(NSString *)queryStringFromDictionary:(NSDictionary *)parameters {
    NSMutableString *urlVars = [NSMutableString new];
    for (NSString *key in [parameters allKeys]) {
        id value= parameters[key];
        [urlVars appendString:[NSString stringWithFormat:@"%@%@=%@", urlVars.length ? @"&": @"", key, value]];
    }
    return [NSString stringWithFormat:@"%@%@", urlVars ? @"?" : @"", urlVars ? urlVars : @""];
}

#pragma mark- NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    for(TANetworkTask* networkTask in self.downloadTasks){
        if(networkTask.sessionTask.taskIdentifier == downloadTask.taskIdentifier){
            networkTask.isDownloading= YES;
            networkTask.isCompleted= NO;
            networkTask.isCancelled= NO;
            float progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
            networkTask.progress= progress;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.delegate && [self.delegate conformsToProtocol:@protocol(TANetworkManagerDelegate)]){
                    if([self.delegate respondsToSelector:@selector(networkTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]){
                        [self.delegate networkTask:networkTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
                    }
                }
            });
            break;
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"didFinishDownloadingToURL %@",location.absoluteString);
    for(TANetworkTask* networkTask in self.downloadTasks){
        if(networkTask.sessionTask.taskIdentifier == downloadTask.taskIdentifier){
            networkTask.isDownloading= NO;
            networkTask.isCancelled= NO;
            networkTask.isCompleted= YES;
            if(self.delegate && [self.delegate conformsToProtocol:@protocol(TANetworkManagerDelegate)]){
                if([self.delegate respondsToSelector:@selector(networkTask:didFinishDownloadingToURL:)]){
                    [self.delegate networkTask:networkTask didFinishDownloadingToURL:location];
                }
            }
            [self.downloadTasks removeObject:networkTask];
            break;
        }
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        NSLog(@"didCompleteWithError %@", error.localizedDescription);
        for(TANetworkTask* networkTask in self.downloadTasks){
            if(networkTask.sessionTask.taskIdentifier == task.taskIdentifier){
                networkTask.isDownloading= NO;
                networkTask.isCancelled= YES;
                networkTask.isCompleted= NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(self.delegate && [self.delegate conformsToProtocol:@protocol(TANetworkManagerDelegate)]){
                        if([self.delegate respondsToSelector:@selector(networkTask:didCompleteWithError:)]){
                            [self.delegate networkTask:networkTask didCompleteWithError:error];
                        }
                    }
                });
                [self.downloadTasks removeObject:networkTask];
                break;
            }
        }
    }
}
@end
