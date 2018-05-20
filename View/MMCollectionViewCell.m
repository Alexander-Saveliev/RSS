//
//  MMCollectionViewCell.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMCollectionViewCell.h"
#import "MMRSSItem.h"

@interface MMCollectionViewCell()
@property BOOL cellUpdated;
@end

@implementation MMCollectionViewCell

- (void)configureWithItem:(MMRSSItem *)item {
    self.cellUpdated = YES;
    
    self.item = item;
    
    self.title.text = item.title;
    self.date.text  = [NSDateFormatter localizedStringFromDate:item.pubDate
                                                     dateStyle:NSDateFormatterShortStyle
                                                     timeStyle:NSDateFormatterFullStyle];
    self.picture.image = (_item.img) ? [UIImage imageWithData:_item.img] : [UIImage imageNamed:@"Marty"];
}

- (void)setupImageIfNeeded {
    if (!self.cellUpdated) {
        return;
    }
    self.cellUpdated = NO;
    
    if (_item.img) {
        self.picture.image = [UIImage imageWithData:_item.img];
    } else {
        [_delegate loadImageData:_item successBlock:^(NSData *data) {
            self.picture.image = (data) ? [UIImage imageWithData:data] : [UIImage imageNamed:@"Marty"];
        }];
    }
}

@end
