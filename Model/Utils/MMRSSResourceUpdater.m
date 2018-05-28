//
//  MMRSSResourceUpdater.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSResourceUpdater.h"
#import "MMCoreDataStackManager.h"
#import "MMRSSItemEntity.h"
#import "MMRSSResourceEntity.h"

@implementation MMRSSResourceUpdater

- (void)update:(id<MMRSSXMLResource>)resource {
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSFetchRequest<MMRSSResourceEntity *> *requestForURL = [MMRSSResourceEntity fetchRequestWithResourceURL:resource.link];
    NSArray<MMRSSResourceEntity *> *resultWithURL = [context executeFetchRequest:requestForURL error:nil];

    MMRSSResourceEntity *newResource = resultWithURL.firstObject;
    
    if (!newResource) {
        newResource = [NSEntityDescription insertNewObjectForEntityForName:@"RSSResourceEntity" inManagedObjectContext:context];
    }
    else {
        [newResource.items.mutableCopy enumerateObjectsUsingBlock:^(MMRSSItemEntity * _Nonnull obj, BOOL * _Nonnull stop) {
            NSPredicate *predicate = [self itemSearchPredicateWithKey:@"link" urlValue:obj.p_link];
            if (![resource.items filteredArrayUsingPredicate:predicate]) {
                [newResource removeItemsObject:obj];
            }
        }];
    }
    
    newResource.p_title = resource.title;
    newResource.p_url   = resource.link;
    
    [resource.items enumerateObjectsUsingBlock:^(id<MMRSSXMLItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSPredicate *predicate = [self itemSearchPredicateWithKey:@"p_link" urlValue:obj.link];
        MMRSSItemEntity *newItem = [newResource.items filteredSetUsingPredicate:predicate].anyObject;
        
        if (!newItem) {
            newItem = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItemEntity" inManagedObjectContext:context];
            [newResource addItemsObject:newItem];
        }
        
        if (obj.title) {
            newItem.p_title   = obj.title;
        }
        if (obj.link) {
            newItem.p_link    = obj.link;
        }
        if (obj.summary) {
            newItem.p_summary = obj.summary;
        }
        if (obj.imgUrl && ![obj.imgUrl isEqual:newItem.p_imgUrl]) {
            newItem.p_imgUrl  = obj.imgUrl;
            newItem.p_img = nil;
        }
        if (obj.img && !newItem.p_img) {
            newItem.p_img     = obj.img;
        }
        if (obj.pubDate) {
            newItem.p_pubDate = obj.pubDate;
        }
    }];
    
    [[MMCoreDataStackManager sharedInstance] saveContext];
}

- (NSMutableArray<MMRSSResource *> *)fetchAllResources {
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSFetchRequest<MMRSSResourceEntity *> *requestForURL = [MMRSSResourceEntity fetchRequest];
    NSArray<MMRSSResourceEntity *> *resultWithURL = [context executeFetchRequest:requestForURL error:nil];
    NSMutableArray<MMRSSResource *> *storedResources;
    
    [resultWithURL enumerateObjectsUsingBlock:^(MMRSSResourceEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [storedResources addObject:[MMRSSResource makeFromEntity:obj]];
    }];
    
    return storedResources;
}

- (void)deletaResourceWithUrl:(NSURL *)url {
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSFetchRequest<MMRSSResourceEntity *> *requestForURL = [MMRSSResourceEntity fetchRequestWithResourceURL:url];
    NSArray<MMRSSResourceEntity *> *resultWithURL = [context executeFetchRequest:requestForURL error:nil];
    
    MMRSSResourceEntity *resource = resultWithURL.firstObject;
    
    if (resource) {
        [context deleteObject:resource];
        [[MMCoreDataStackManager sharedInstance] saveContext];
    }
}

- (void)updateItemEntity:(NSURL *)itemUrl withBlock:(void(^)(MMRSSItemEntity *item))block {
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSFetchRequest<MMRSSItemEntity *> *itemForURL = [MMRSSItemEntity fetchItemWithURL:itemUrl];
    MMRSSItemEntity *itemEntity = [[context executeFetchRequest:itemForURL error:nil] firstObject];
    
    if (block && itemEntity) {
        block(itemEntity);
        [[MMCoreDataStackManager sharedInstance] saveContext];
    }
}

- (NSPredicate *)itemSearchPredicateWithKey:(NSString *)key urlValue:(NSURL *)value {
    return [NSPredicate predicateWithFormat:@"%K == %@", key, value];
}

@end
