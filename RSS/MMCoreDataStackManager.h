//
//  MMCoreDataStackManager.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MMCoreDataStackManager : NSObject

+ (id)sharedInstance;
- (void)saveContext;

@property (readonly) NSManagedObjectContext *context;

@end
