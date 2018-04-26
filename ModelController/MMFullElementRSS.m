//
//  MMFullElementRSS.m
//  RSS
//
//  Created by Marty on 26/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMFullElementRSS.h"

@implementation MMFullElementRSS

@synthesize element      = _element;
@synthesize elementImage = _elementImage;

+ (instancetype)createFullElementWithElement:(MMElementRSS *)element andImage:(UIImage *)image {
    MMFullElementRSS *fullElement = [MMFullElementRSS new];
    [fullElement loadWithElement:element andImage:image];
    
    return fullElement;
}

- (void)loadWithElement:(MMElementRSS *)element andImage:(UIImage *)image {
    _element      = element;
    _elementImage = image;
}

@end
