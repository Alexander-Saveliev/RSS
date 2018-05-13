//
//  MMNetworkTask.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMNetworkTask.h"

@implementation MMNetworkTask

- (void)initWithURL:(NSURL *)url successBlock:(_Nonnull SuccessBlock)successBlock failureBlock:(_Nonnull FailureBlock)failureBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failureBlock) {
                failureBlock(error);
            }
        } else {
            if (successBlock) {
                successBlock(data);
            }
        }
    }];
    
    [task resume];
}

@end
