//
//  MMFullElementRSS.h
//  RSS
//
//  Created by Marty on 26/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MMElementRSS.h"

@interface MMFullElementRSS : NSObject

+ (instancetype)createFullElementWithElement:(MMElementRSS *)element andImage:(UIImage *)image;

@property MMElementRSS* element;
@property UIImage* elementImage;

@end
