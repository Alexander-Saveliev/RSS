//
//  MMViewController.m
//  RSS
//
//  Created by Marty on 25/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMViewController.h"


@interface MMViewController ()

@end

@implementation MMViewController

@synthesize fullElement;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleLabel.text       = fullElement.element.title;
    descriptionLabel.text = fullElement.element.description;
    pubDateLabel.text     = fullElement.element.date;
    image.image           = fullElement.elementImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
