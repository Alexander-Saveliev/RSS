//
//  MMRSSParser.h
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MMRSSXMLResource;

typedef void (^ParserSuccessBlock)(id<MMRSSXMLResource> resource);
typedef void (^ParserFailureBlock)(void);

@interface MMRSSParser : NSObject

- (void)parse:(NSData *)data withURL:(NSURL *)url success:(ParserSuccessBlock)success failure:(ParserFailureBlock)failure;

@end
