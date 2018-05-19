//
//  MMRSSResourceEntity.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSResourceEntity.h"

static const NSString *kMMurl = @"p_url";

@implementation MMRSSResourceEntity

+ (NSFetchRequest<MMRSSResourceEntity *> *)fetchRequestWithResourceURL:(NSURL *)url {
    NSFetchRequest *fetchRequest = [MMRSSResourceEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", kMMurl, url];
    
    return fetchRequest;
}

@end
