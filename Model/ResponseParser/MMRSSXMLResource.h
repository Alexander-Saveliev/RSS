//
//  MMRSSXMLResource.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

@protocol MMRSSXMLItem;

@protocol MMRSSXMLResource

- (NSString *)title;
- (NSURL    *)link;
- (NSArray<id<MMRSSXMLItem>> *)items;

@end;
