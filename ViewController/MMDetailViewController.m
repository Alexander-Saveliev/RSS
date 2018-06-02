//
//  MMDetailViewController.m
//  RSS
//
//  Created by Marty on 25/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMDetailViewController.h"
#import "MMRSSItem.h"


@interface MMDetailViewController ()

@end

@implementation MMDetailViewController
- (IBAction)openInBrowserButtonWasTapped:(UIButton *)sender {
        if (_item.link) {
            [[UIApplication sharedApplication] openURL:_item.link options:@{} completionHandler:nil];
        }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[_item.summary dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    titleLabel.text = _item.title;
    descriptionLabel.attributedText = attrStr;
    pubDateLabel.text  = [NSDateFormatter localizedStringFromDate:_item.pubDate
                                                                          dateStyle:NSDateFormatterShortStyle
                                                                          timeStyle:NSDateFormatterFullStyle];
    
    image.image = [UIImage imageWithData:_item.img];
}

@end
