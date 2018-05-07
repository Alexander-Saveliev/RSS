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
    NSURL *urlToLoad = [self.url copy];
    UIImage *imgToLoad = [_delegate imageByURL:self.url usingNet:YES];
    
    if (urlToLoad == self.url) {
        self.img = imgToLoad;
    }
}

- (void)loadImageFromMemory {
    NSURL *urlToLoad = [self.url copy];
    UIImage *imgToLoad = [_delegate imageByURL:self.url usingNet:NO];
    
    if (urlToLoad == self.url) {
        self.img = imgToLoad;
    }
}

- (void)setCurrentImage {
    if (self.img) {
        self.picture.image = self.img;
    }
}

@end
