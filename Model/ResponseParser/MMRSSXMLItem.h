//
//  MMRSSXMLItem.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

@protocol MMRSSXMLItem

- (NSString *)title;
- (NSString *)summary;
- (NSURL    *)link;
- (NSData   *)img;
- (NSDate   *)pubDate;
- (NSURL    *)imgUrl;

@end;
