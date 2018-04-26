//
//  MMElementRSS.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMElementRSS.h"

@implementation MMElementRSS

+ (instancetype)createElementWithTitle:(NSString *)title description:(NSString *)description date:(NSString *)date andImageUrl:(NSURL *)imageUrl {
    MMElementRSS *rssElement = [MMElementRSS new];
    [rssElement loadWithTitle:title description:description date:date andImageUrl:imageUrl];
    
    return rssElement;
}

- (void)loadWithTitle:(NSString *)title description:(NSString *)description date:(NSString *)date andImageUrl:(NSURL *)imageURL {
    _title       = title;
    _description = description;
    _date        = date;
    _imageURL    = imageURL;
}

@synthesize title       = _title;
@synthesize description = _description;
@synthesize date        = _date;
@synthesize imageURL    = _imageURL;

@end
