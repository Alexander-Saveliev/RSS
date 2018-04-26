//
//  MMCollectionViewCell.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageLoading;

@interface MMCollectionViewCell : UICollectionViewCell

- (void)loadImageFromNet;
- (void)loadImageFromMemory;
- (void)setCurrentImage;

@property (weak, nonatomic) id <ImageLoading> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel     *title;
@property (weak, nonatomic) IBOutlet UILabel     *date;

@property UIImage *img;
@property NSURL   *url;

@end

@protocol ImageLoading <NSObject>

- (UIImage *)imageByURL:(NSURL *)url uisngNet:(BOOL)net;

@end
