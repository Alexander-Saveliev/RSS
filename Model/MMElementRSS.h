//
//  MMElementRSS.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMElementRSS : NSObject

+ (instancetype)createElementWithTitle:(NSString *)title description:(NSString *)description date:(NSString *)date link:(NSURL *)link andImageUrl:(NSURL *)imageUrl;

@property (readonly) NSString *title;
@property (readonly) NSString *description;
@property (readonly) NSString *date;
@property (readonly) NSURL    *imageURL;
@property (readonly) NSURL    *link;

@end
