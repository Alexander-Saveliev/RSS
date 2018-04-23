//
//  MMCollectionViewCell.h
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMControllerViewCell;

@interface MMCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <MMControllerViewCell> delegate;


@property (weak, nonatomic) IBOutlet UIImageView *picture;
@property (weak, nonatomic) IBOutlet UILabel     *title;
@property (weak, nonatomic) IBOutlet UILabel     *date;

@property UIImage *img;
@property NSURL   *url;

- (void)loadImageFromNet;
- (void)loadImageFromMemory;
- (void)setCurrentImage;

@end

@protocol MMControllerViewCell <NSObject>

- (UIImage *)imageByURL:(NSURL *)url uisngNet:(BOOL)net;

@end
