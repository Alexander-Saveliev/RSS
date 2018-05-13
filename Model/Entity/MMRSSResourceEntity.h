//
//  MMRSSResourceEntity.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "MMRSSResource.h"

@class MMRSSItemEntity;

@interface MMRSSResourceEntity : NSManagedObject

+ (NSFetchRequest<MMRSSResourceEntity *> *)fetchRequestWithResourceURL:(NSURL *)url;

@end

#import "MMRSSResourceEntity+CoreDataProperties.h"
