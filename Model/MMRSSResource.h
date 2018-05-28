//
//  MMRSSResource.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMRSSResourceEntity;
@class MMRSSItem;

@interface MMRSSResource : NSObject

+ (id)makeFromEntity:(MMRSSResourceEntity *)reesource;

@property (readonly) NSString *title;
@property (readonly) NSURL *url;

@property (readonly) NSArray<MMRSSItem *> *items;

@end
