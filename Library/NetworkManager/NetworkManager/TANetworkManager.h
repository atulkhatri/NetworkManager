//
//  TANetworkManager.h
//  TestApp
//
//  Created by Atul Khatri on 20/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TANetworkTask.h"

typedef enum {
    HTTP_METHOD_TYPE_GET,
    HTTP_METHOD_TYPE_POST
}HttpMethodType;

@protocol TANetworkManagerDelegate <NSObject>

/**
 Provides current progress of File download.

 @param networkTask Network task to keep track on the current status and to cancel the ongoing request.
 @param bytesWritten Bytes written in current chunk
 @param totalBytesWritten Total bytes written till now
 @param totalBytesExpectedToWrite Total bytes expected for this file
 */
- (void)networkTask:(TANetworkTask*)networkTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;


/**
 Notifies that the current file has finished downloading

 @param networkTask Network task to keep track on the current status and to cancel the ongoing request.
 @param location Temporary location of downloaded file
 */
- (void)networkTask:(TANetworkTask*)networkTask didFinishDownloadingToURL:(NSURL *)location;


/**
 Notifies that the current file has completed with error. Error can be nil.

 @param networkTask Network task to keep track on the current status and to cancel the ongoing request.
 @param error NSError in case of error in file download. This can be nil.
 */
- (void)networkTask:(TANetworkTask*)networkTask didCompleteWithError:(NSError *)error;

@end

@interface TANetworkManager : NSObject

/**
 Singleton instance to perform network operations. Do not use init method.

 @return Singleton instance of TANetworkManager
 */
+ (instancetype)sharedInstance;

/**
    Use this delegate to get status of File downloads if files are downloaded through delegate based method.
 */
@property (nonatomic, weak) id <TANetworkManagerDelegate> delegate;

/**
    Specify timeout duration in seconds, default 60 seconds
 */
@property (nonatomic, assign) float networkTimeoutDuration;

/**
    Specify max cache size in MegaBytes, default 10MB
 */
@property (nonatomic, assign) float networkCacheMaxSize;

/**
    Clear all images/json data cached in memory
 */
- (void)clearCache;

/**
 This method accepts an NSURL to perform network operation and returns result in <b>NSData</b> format. It also caches the JSON response if networkTaskType is set to <b>NETWORK_TASK_TYPE_JSON_GET</b>.
 All images performed via networkTaskType as <b>NETWORK_TASK_TYPE_IMAGE</b> are cached in memory. Disk cache is not being used.
 NetworkTaskType <b>NETWORK_TASK_TYPE_FILE_DOWNLOAD</b> can be used for all kind of files i.e. PDF, Videos, Zip etc.

 @param url The url to perform network operation.
 @param taskType This parameter defines which kind of task is to be performed. There are 4 basic tasks i.e. NETWORK_TASK_TYPE_JSON_GET, NETWORK_TASK_TYPE_JSON_POST, NETWORK_TASK_TYPE_IMAGE & NETWORK_TASK_TYPE_FILE_DOWNLOAD.
 @param params This parameter takes query parameters for JSON GET and POST requests. This can be set as <b>nil</b> for all other requests
 @param successBlock Success block returns success response in <b>NSData</b> form.
 @param failureBlock Failure block returns <b>NSError</b> in case request fails.
 @return TANetworkTask Network task is returned to get the status of the task. This can also be used to Cancel the ongoing request.
 */
- (TANetworkTask*)dataWithUrl:(NSURL*)url networkTaskType:(NetworkTaskType)taskType params:(NSDictionary*)params success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock;


#pragma mark- Use below methods for more task specific operations.

/**
 This method is used to get more granular control of file downloads. This method doesn't use block based callbacks, it uses delegate based callbacks. It can be used to show the current progress of file downloads which is critical if file is comparatively larger. No caching is used for file downloads.

 @param url Url to download the file
 @param delegate TANetworkManagerDelegate object to get callbacks
 @return TANetworkTask Network task is returned to get the status of the task. This can also be used to Cancel the ongoing request.
 */
- (TANetworkTask*)downloadFileWithUrl:(NSURL*)url withNetworkManagerDelegate:(id <TANetworkManagerDelegate>)delegate;


/**
 This method is used to download an image from network. Files are NOT cached in memory.

 @param url Url to download the file
 @param successBlock Success block returns success response in <b>NSData</b> form.
 @param failureBlock Failure block returns <b>NSError</b> in case request fails.
 @return TANetworkTask Network task is returned to get the status of the task. This can also be used to Cancel the ongoing request.
 */
- (TANetworkTask*)downloadFileWithUrl:(NSURL*)url success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock;

/**
 This method is used to download an image from network. Images are cached in memory.

 @param url Url to download the image
 @param successBlock Success block returns success response in <b>NSData</b> form.
 @param failureBlock Failure block returns <b>NSError</b> in case request fails.
 @return TANetworkTask Network task is returned to get the status of the task. This can also be used to Cancel the ongoing request.
 */
- (TANetworkTask*)downloadImageWithUrl:(NSURL*)url success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock;


/**
 This method is used to perform JSON requests in GET & POST methods

 @param type This param defines type of JSON reqeuest, GET or POST
 @param url Url to peform JSON request
 @param params Query parameters for JSON request
 @param successBlock Success block returns success response in <b>NSData</b> form.
 @param failureBlock Failure block returns <b>NSError</b> in case request fails.
 @return TANetworkTask Network task is returned to get the status of the task. This can also be used to Cancel the ongoing request.
 */
- (TANetworkTask*)jsonRequestWithMethodType:(HttpMethodType)type url:(NSURL*)url params:(NSDictionary*)params success:(void (^)(id responseObject))successBlock failure:(void (^)(NSError *error))failureBlock;

#pragma mark-

@end
