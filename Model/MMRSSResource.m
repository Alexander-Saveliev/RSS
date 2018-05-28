//
//  MMRSSResource.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSResource.h"
#import "MMRSSResourceEntity.h"
#import "MMRSSItem.h"

@implementation MMRSSResource

+ (id)makeFromEntity:(MMRSSResourceEntity *)entity {
    MMRSSResource *resource = [MMRSSResource new];
    [resource loadFromEntity:entity];
    
    return resource;
}

- (void)loadFromEntity:(MMRSSResourceEntity *)resource {
    _title = resource.p_title;
    _url   = resource.p_url;
    
    NSMutableArray *items = [NSMutableArray array];
    
    [resource.items enumerateObjectsUsingBlock:^(MMRSSItemEntity * _Nonnull obj, BOOL * _Nonnull stop) {
        [items addObject:[MMRSSItem makeFromEntity:obj]];
    }];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    
    _items = [items sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
