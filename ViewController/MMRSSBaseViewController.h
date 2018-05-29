//
//  MMRSSBaseViewController.h
//  RSS
//
//  Created by Marty on 29/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMRSSResource;

@interface MMRSSBaseViewController : UICollectionViewController

@property (nonatomic, strong) MMRSSResource *resource;
@property (nonatomic, assign) NSUInteger pageIndex;

@end
