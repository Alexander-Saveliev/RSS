//
//  MMRSSItem.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSItem.h"
#import "MMRSSItemEntity.h"

@implementation MMRSSItem

+ (id)makeFromEntity:(MMRSSItemEntity *)entity {
    MMRSSItem *item = [MMRSSItem new];
    [item loadFromEntity:entity];
    
    return item;
}

- (void)loadFromEntity:(MMRSSItemEntity *)item {
    _pubDate = item.p_pubDate;
    _summary = item.p_summary;
    _imgUrl  = item.p_imgUrl;
    _title   = item.p_title;
    _link    = item.p_link;
    _img     = item.p_img;
}

@end
