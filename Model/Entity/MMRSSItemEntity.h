//
//  MMRSSItemEntity.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <CoreData/CoreData.h>

@class MMRSSResourceEntity;

@interface MMRSSItemEntity : NSManagedObject

+ (NSFetchRequest<MMRSSItemEntity *> *)fetchItemWithURL:(NSURL *)url;
+ (NSString *)entityName;

@end

#import "MMRSSItemEntity+CoreDataProperties.h"
