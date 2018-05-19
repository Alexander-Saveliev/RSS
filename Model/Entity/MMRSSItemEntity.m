//
//  MMRSSItemEntity.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSItemEntity.h"

static const NSString *kMMurl = @"p_link";

@implementation MMRSSItemEntity

+ (NSString *)entityName {
    return @"RSSItemEntity";
}

+ (NSFetchRequest<MMRSSItemEntity *> *)fetchItemWithURL:(NSURL *)url {
    NSFetchRequest *fetchRequest = [MMRSSItemEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@", kMMurl, url];
    
    return fetchRequest;
}

@end
