//
//  MMCollectionViewCell.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMRSSItem;

@protocol ImageLoading;

@interface MMCollectionViewCell : UICollectionViewCell

- (void)configureWithItem:(MMRSSItem *)item;
- (void)setupImageIfNeeded;

@property (weak, nonatomic) id <ImageLoading> delegate;
@property (weak, nonatomic) MMRSSItem *item;

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel     *title;
@property (weak, nonatomic) IBOutlet UILabel     *date;

@end

@protocol ImageLoading <NSObject>

- (void)loadImageData:(MMRSSItem *)item successBlock:(void(^)(NSData *data))successBlock;

@end
