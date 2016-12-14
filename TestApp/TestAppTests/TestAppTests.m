//
//  TestAppTests.m
//  TestAppTests
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TANetworkManager.h"
#define kFlickrAPIKey @"433ff6b9d52b7e184698280338149ac6"
#define kFlickrAPIPath @"https://api.flickr.com/services/rest/"

@interface TestAppTests : XCTestCase

@end

@implementation TestAppTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCorrectJsonRequest{
    NSMutableDictionary* params= [NSMutableDictionary new];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:@"random" forKey:@"sort"];
    [params setObject:@"flickr.photos.search" forKey:@"method"];
    [params setObject:@"sky" forKey:@"tags"];
    [params setObject:@"all" forKey:@"tag_mode"];
    [params setObject:kFlickrAPIKey forKey:@"api_key"];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"nojsoncallback"];
    [params setObject:[NSNumber numberWithInteger:10] forKey:@"per_page"];
    [params setObject:[NSNumber numberWithInteger:1] forKey:@"page"];
    [[TANetworkManager sharedInstance] dataWithUrl:[NSURL URLWithString:kFlickrAPIPath] networkTaskType:NETWORK_TASK_TYPE_JSON_GET params:params success:^(id responseObject) {
        XCTAssertNotNil(responseObject);
    } failure:^(NSError *error) {
        // Failure
    }];
}

- (void)testInvalidImageUrl{
    [[TANetworkManager sharedInstance] dataWithUrl:[NSURL URLWithString:@"Test URL"] networkTaskType:NETWORK_TASK_TYPE_IMAGE params:nil success:^(id responseObject) {
        // Failure
    } failure:^(NSError *error) {
        XCTAssertNotNil(error);
    }];
}

- (void)testImageDownload{
    // This test will download the image
    [[TANetworkManager sharedInstance] dataWithUrl:[NSURL URLWithString:@"https://support.apple.com/library/content/dam/edam/applecare/images/en_US/iphone/iphone-iphone6plus-colors.jpg"] networkTaskType:NETWORK_TASK_TYPE_IMAGE params:nil success:^(id responseObject) {
        XCTAssertNotNil(responseObject);
    } failure:^(NSError *error) {
        // Failure
    }];
}
@end
