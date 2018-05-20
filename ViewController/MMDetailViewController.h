//
//  MMDetailViewController.h
//  RSS
//
//  Created by Marty on 25/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMRSSItem;

@interface MMDetailViewController : UIViewController {
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *descriptionLabel;
    __weak IBOutlet UILabel *pubDateLabel;
    __weak IBOutlet UIImageView *image;
    
}

@property (nonatomic, strong) MMRSSItem* item;

@end
