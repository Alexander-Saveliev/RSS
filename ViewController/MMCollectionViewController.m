//
//  MMCollectionViewController.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMCollectionViewController.h"
#import "MMCollectionViewCell.h"
#import "MMParserRSS.h"
#import "MMElementRSS.h"


@interface MMCollectionViewController () {
    NSMutableArray * RSSdata;
}

@property (nonatomic, strong) dispatch_queue_t someSerialQueue;
@property (nonatomic, strong) NSMutableDictionary *imagesByURL;

@end


@implementation MMCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (IBAction)refresh:(UIBarButtonItem *)sender {
    RSSdata = [NSMutableArray new];
    [self reloadData];
}

- (IBAction)add:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Add tape" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionGo = [UIAlertAction actionWithTitle:@"Go"
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                       }];
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"URL";
    }];
    
    [alertVC addAction:actionGo];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RSSdata = [NSMutableArray new];
    
    [self reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVisibleCellsImages];
}

- (void)updateVisibleCellsImages {
    for (MMCollectionViewCell *cell in [self.collectionView visibleCells]) {
        dispatch_async(self.someSerialQueue, ^{
            [cell loadImageFromNet];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setCurrentImage];
            });
        });
    }
}

- (void)reloadData {
    MMParserRSS *parser = [MMParserRSS new];
    
    NSURLSession *session;
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL * url = [NSURL URLWithString:@"https://habrahabr.ru/rss/interesting/"];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [parser setData:data];
        self->RSSdata = [parser parsedItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateVisibleCellsImages];
            [self.collectionView reloadData];
        });
    }];
    [task resume];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return RSSdata.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    cell.delegate = self;
    
    MMElementRSS *element = [RSSdata objectAtIndex:indexPath.row];
    cell.title.text = [element.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.date.text  = [element.date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.url        = element.image;
    
    [cell loadImageFromMemory];
    [cell setCurrentImage];
    
    return cell;
}

- (UIImage *)imageByURL:(NSURL *)url uisngNet:(BOOL)net {
    if (!url) {
        return [UIImage imageNamed:@"Marty"];
    }
    
    UIImage *img = [self.imagesByURL valueForKey:url.absoluteString];
    
    if (img) {
        return img;
    }
    
    if (!net) {
        return [UIImage imageNamed:@"Marty"];
    }
    
    img = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    if (img) {
        [self.imagesByURL setValue:img forKey:url.absoluteString];
        return img;
    }
    
    return [UIImage imageNamed:@"Marty"];
}

- (dispatch_queue_t)someSerialQueue {
    if (!_someSerialQueue) {
        _someSerialQueue = dispatch_queue_create("com.mm.mySerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _someSerialQueue;
}

- (NSMutableDictionary *)imagesByURL {
    if (!_imagesByURL) {
        _imagesByURL = [NSMutableDictionary new];
    }
    return _imagesByURL;
}

@end
