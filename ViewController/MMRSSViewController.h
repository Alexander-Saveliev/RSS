//
//  MMRSSViewController.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMRSSViewController.h"

@class MMRSSResource;
@class MMRSSItemEntity;

@protocol MMTapeUpdater;

@interface MMRSSViewController : UICollectionViewController

@property NSUInteger pageIndex;
@property (nonatomic, strong) NSURL *tapeLink;

@property (weak, nonatomic) id <MMTapeUpdater> delegate;

@end

@protocol MMTapeUpdater <NSObject>

- (void)updateWithURL:(NSURL *)url andBlock:(void(^)(void))block;
- (void)fetchContentWithURL:(NSURL *)url successBlock:(void(^)(MMRSSResource *resource))successBlock failureBlock:(void(^)(void))failureBlock;
- (void)updateItemEntity:(NSURL *)itemUrl withBlock:(void(^)(MMRSSItemEntity *item))block;

@end
