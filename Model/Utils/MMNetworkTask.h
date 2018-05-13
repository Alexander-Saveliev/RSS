//
//  MMNetworkTask.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SuccessBlock)(NSData *data);
typedef void (^FailureBlock)(NSError *error);

@interface MMNetworkTask : NSObject

- (void)initWithURL:(NSURL *)url successBlock:(_Nonnull SuccessBlock)successBlock failureBlock:(_Nonnull FailureBlock)failureBlock;

@end
