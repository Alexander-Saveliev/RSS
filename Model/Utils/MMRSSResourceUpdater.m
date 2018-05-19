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
    
    MMRSSResourceEntity *newResource;
    
    if (!resultWithURL.firstObject) {
        newResource = [NSEntityDescription insertNewObjectForEntityForName:@"RSSResourceEntity" inManagedObjectContext:context];
    }
    
    newResource.p_title = resource.title;
    newResource.p_url   = resource.link;
    
    if ([newResource.items count]) {
        id mutableCopy = newResource.items.mutableCopy;
        [mutableCopy enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [context deleteObject:obj];
        }];
    }
    
    [resource.items enumerateObjectsUsingBlock:^(id<MMRSSXMLItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRSSItemEntity *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItemEntity" inManagedObjectContext:context];
        
        newItem.p_title   = obj.title;
        newItem.p_link    = obj.link;
        newItem.p_summary = obj.summary;
        newItem.p_imgUrl  = obj.imgUrl;
        newItem.p_img     = obj.img;
        newItem.p_pubDate = obj.pubDate;
        
        [newResource addItemsObject:newItem];
    }];
    
    @try {
        [context save:nil];
    } @catch (NSException *exception) {
        NSLog(@"error with saving context");
    } @finally {
    }
}

- (void)updateItemEntity:(NSURL *)itemUrl withBlock:(void(^)(MMRSSItemEntity *item))block {
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSFetchRequest<MMRSSItemEntity *> *itemForURL = [MMRSSItemEntity fetchItemWithURL:itemUrl];
    MMRSSItemEntity *itemEntity = [[context executeFetchRequest:itemForURL error:nil] firstObject];
    
    if (block && itemEntity) {
        block(itemEntity);
        [context save:nil];
    }
}

@end
