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
    
    @synchronized(context) {
    
        NSFetchRequest<MMRSSResourceEntity *> *requestForURL = [MMRSSResourceEntity fetchRequestWithResourceURL:resource.link];
        NSArray<MMRSSResourceEntity *> *resultWithURL = [context executeFetchRequest:requestForURL error:nil];
        
        NSFetchRequest<MMRSSItemEntity *> *requestForURL2 = [MMRSSItemEntity fetchRequest];
        NSArray<MMRSSItemEntity *> *resultWithURL2 = [context executeFetchRequest:requestForURL2 error:nil];
        
        MMRSSResourceEntity *newResource = resultWithURL.firstObject;
        
        if (newResource) {
            [context deleteObject:newResource];
        }
        
        newResource = [NSEntityDescription insertNewObjectForEntityForName:@"RSSResourceEntity" inManagedObjectContext:context];
        
        newResource.p_title = resource.title;
        newResource.p_url   = resource.link;

        [resource.items enumerateObjectsUsingBlock:^(id<MMRSSXMLItem>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MMRSSItemEntity *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItemEntity" inManagedObjectContext:context];
            
            if (obj.title) {
                newItem.p_title   = obj.title;
            }
            if (obj.link) {
                newItem.p_link    = obj.link;
            }
            if (obj.summary) {
                newItem.p_summary = obj.summary;
            }
            if (obj.imgUrl) {
                newItem.p_imgUrl  = obj.imgUrl;
            }
            if (obj.img) {
                newItem.p_img     = obj.img;
            }
            if (obj.pubDate) {
                newItem.p_pubDate = obj.pubDate;
            }
            
            [newResource addItemsObject:newItem];
        }];
        
        [[MMCoreDataStackManager sharedInstance] saveContext];
    };
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

@end
