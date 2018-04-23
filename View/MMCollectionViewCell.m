//
//  MMCollectionViewCell.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMCollectionViewCell.h"

@implementation MMCollectionViewCell

@synthesize url;

- (void)loadImageFromNet {
    self.img = [_delegate imageByURL:self.url uisngNet:YES];
}

- (void)loadImageFromMemory {
    self.img = [_delegate imageByURL:self.url uisngNet:NO];
}

- (void)setCurrentImage {
    self.picture.image = self.img;
}

@end
