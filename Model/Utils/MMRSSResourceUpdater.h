//
//  MMRSSResourceUpdater.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMRSSXMLResource.h"
#import "MMRSSXMLItem.h"

@class MMRSSItemEntity;
@class MMRSSResource;

@interface MMRSSResourceUpdater : NSObject

- (void)update:(id<MMRSSXMLResource>)resource;
- (void)updateItemEntity:(NSURL *)itemUrl withBlock:(void(^)(MMRSSItemEntity *item))block;
- (void)deletaResourceWithUrl:(NSURL *)url;
- (NSMutableArray<MMRSSResource *> *)fetchAllResources;

@end

