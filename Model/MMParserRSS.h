//
//  MMParserRSS.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMParserRSS : NSObject

- (NSMutableArray *)parsedItems;
- (void)setData:(NSData *)data;

@end
