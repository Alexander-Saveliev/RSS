//
//  MMRSSItem.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMRSSItemEntity;

@interface MMRSSItem : NSObject

+ (id)makeFromEntity:(MMRSSItemEntity *)item;

@property (readonly) NSString *title;
@property (readonly) NSString *summary;
@property (readonly) NSURL    *link;
@property NSData              *img;
@property (readonly) NSDate   *pubDate;
@property (readonly) NSURL    *imgUrl;

@end
