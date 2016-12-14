//
//  TAFileInfoModel.m
//  TestApp
//
//  Created by Atul Khatri on 21/11/16.
//  Copyright © 2016 AK. All rights reserved.
//

#import "TAFileInfoModel.h"

@implementation TAFileInfoModel
- (instancetype)initWithUrl:(NSURL*)url andType:(NSString*)type{
    self = [super init];
    if (self) {
        self.url= url;
        self.type= type;
    }
    return self;
}
@end

