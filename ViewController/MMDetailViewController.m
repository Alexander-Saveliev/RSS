//
//  MMDetailViewController.m
//  RSS
//
//  Created by Marty on 25/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMDetailViewController.h"
#import "MMCoreDataStackManager.h"
#import <CoreData/CoreData.h>
#import "MMRSSItemEntity.h"
#import "MMRSSResourceEntity.h"


@interface MMDetailViewController ()

@end

@implementation MMDetailViewController

@synthesize fullElement;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
//    
//    MMRSSItemEntity *newItem = [NSEntityDescription insertNewObjectForEntityForName:[MMRSSItemEntity entityName] inManagedObjectContext:context];
//
//    newItem.p_title = @"some news";
//    newItem.p_link = [NSURL URLWithString:@"https://someURL.com"];
//    newItem.p_summary = @"some text";
//
//    MMRSSResourceEntity *newResource = [NSEntityDescription insertNewObjectForEntityForName:@"RSSResourceEntity" inManagedObjectContext:context];
//
//    newResource.p_title = @"some resource";
//    newResource.p_url = [NSURL URLWithString:@"https://urrrl.com"];
//
//    [newResource addItemsObject:newItem];
//
//    @try {
//        [context save:nil];
//    } @catch (NSException *exception) {
//        NSLog(@"error with saving context");
//    } @finally {
//
//    }
//    
//    
//    NSFetchRequest<MMRSSItemEntity *> *request = [MMRSSItemEntity fetchRequest];
//
//    NSArray<MMRSSItemEntity *> *result = [context executeFetchRequest:request error:nil];
//
//    if (!result) {
//        NSLog(@"empty");
//    } else {
//        NSLog(@"Title: %@", result[0].p_title);
//    }
    
//    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[fullElement.element.description dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

//
//    titleLabel.text       = fullElement.element.title;
//    descriptionLabel.attributedText = attrStr;
//    pubDateLabel.text     = fullElement.element.date;
//    image.image           = fullElement.elementImage;
}

- (IBAction)redirectButtonWasTaped:(UIButton *)sender {
    if (fullElement.element.link) {
        [[UIApplication sharedApplication] openURL:fullElement.element.link options:@{} completionHandler:nil];
    }
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
