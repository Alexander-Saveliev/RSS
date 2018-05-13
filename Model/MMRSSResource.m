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

+ (id)makeFromResource:(MMRSSResourceEntity *)entity {
    MMRSSResource *resource = [MMRSSResource new];
    [resource loadFromResource:entity];
    
    return resource;
}


- (void)loadFromResource:(MMRSSResourceEntity *)resource {
    _title = resource.p_title;
    _url   = resource.p_url;
    
    NSMutableArray *items = [NSMutableArray array];
    
    [resource.items enumerateObjectsUsingBlock:^(MMRSSItemEntity * _Nonnull obj, BOOL * _Nonnull stop) {
        [items addObject:[MMRSSItem makeFromEntity:obj]];
    }];
    
    _items = items;
}

@end
