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

@interface MMRSSResourceUpdater : NSObject

- (void)update:(id<MMRSSXMLResource>)resource;

@end

