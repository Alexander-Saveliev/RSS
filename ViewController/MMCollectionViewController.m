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
#import "MMFullElementRSS.h"
#import "MMViewController.h"

@interface MMCollectionViewController () <ImageLoading, UICollectionViewDelegateFlowLayout> {
    NSMutableArray * rssData;
    NSURL          * url;
}

@property (nonatomic, strong) dispatch_queue_t imageLoadingSerialQueue;
@property (nonatomic, strong) NSMutableDictionary *imagesByURL;
@property (nonatomic, strong) MMFullElementRSS *fullElement;

@end


@implementation MMCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const showMore        = @"showMore";
static NSString * const urlPlaceholder  = @"URL";
static NSString * const add             = @"Add tape";
static NSString * const go              = @"Go";
static NSString * const cancel          = @"Cancel";


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 100);
}

- (IBAction)addButtonWasTaped:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(add, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* actionGo = [UIAlertAction actionWithTitle:go
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           self->url = [NSURL URLWithString:alertVC.textFields[0].text];
                                                           [self reloadDataWithURL:self->url];
                                                       }];
    
    UIAlertAction* actionCancel = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = urlPlaceholder;
    }];
    
    [alertVC addAction:actionGo];
    [alertVC addAction:actionCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)refreshButtonWasTaped:(UIBarButtonItem *)sender {
    rssData = [NSMutableArray new];
    [self reloadDataWithURL:url];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showMore]) {
        MMViewController *fullItemVC = [segue destinationViewController];
        NSLog(@"send");
        
        fullItemVC.fullElement = self.fullElement;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MMElementRSS *element;
    UIImage *img;
    
    if (indexPath.row < [rssData count]) {
        element = [rssData objectAtIndex:indexPath.row];
        NSURL *url = element.imageURL;
        
        if (url) {
            img = [self.imagesByURL valueForKey:url.absoluteString];
        }
    }
    self.fullElement = [MMFullElementRSS createFullElementWithElement:element andImage:img];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fullElement = [MMFullElementRSS new];
    
    // https://lenta.ru/rss/news
    // https://habrahabr.ru/rss/interesting/
    // http://kino-2017.net/novosti/rss.xml
    // http://www.arms-expo.ru/news/rss/
    // http://www.forbes.com/investing/feed2/
    // http://www.nytimes.com/services/xml/rss/nyt/HomePage.xml
    // http://news.mail.ru/rss/91/
    // !!! https://rss.itunes.apple.com/api/v1/jp/books/top-free/all/100/non-explicit.atom?at=1001l5Uo
    // this shit sends empty image url http://botanicheskiy-rai.ru/rss.xml
    // http://www.vedomosti.ru/rss/news
    
    url = [NSURL URLWithString:@"https://habrahabr.ru/rss/interesting/"];
    UIRefreshControl *refreshController = [UIRefreshControl new];
    
    refreshController.backgroundColor = [UIColor redColor];
    refreshController.tintColor       = [UIColor whiteColor];
    [refreshController addTarget:self action:@selector(refreshWasPulled:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshController];
    
    rssData = [NSMutableArray new];
    [self reloadDataWithURL:url];
}

- (void)refreshWasPulled:(UIRefreshControl *)refreshController {
    [self reloadDataWithURL:url];
    [refreshController endRefreshing];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVisibleCellsImages];
}

- (void)updateVisibleCellsImages {
    for (MMCollectionViewCell *cell in [self.collectionView visibleCells]) {
        dispatch_async(self.imageLoadingSerialQueue, ^{
            [cell loadImageFromNet];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setCurrentImage];
            });
        });
    }
}

- (void)reloadDataWithURL:(NSURL *)url {
    
#ifdef DEBUG
    self.imagesByURL = [NSMutableDictionary new];
    [self updateVisibleCellsImages];
#endif
    
    MMParserRSS *parser = [MMParserRSS new];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [parser setData:data];
        self->rssData = [parser parsedItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
    [task resume];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; //TODO: Budet 4to-to
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return rssData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.picture.image = nil;

    if (indexPath.row >= [rssData count]) {
        return cell;
    }
    
    cell.delegate = self;
    
    MMElementRSS *element = [rssData objectAtIndex:indexPath.row];
    cell.title.text = [element.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.date.text  = [element.date stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cell.url        = element.imageURL;
    
    [cell loadImageFromMemory];
    [cell setCurrentImage];
    
    return cell;
}

- (UIImage *)imageByURL:(NSURL *)url usingNet:(BOOL)net {
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

#pragma mark - lazy -

- (dispatch_queue_t)imageLoadingSerialQueue {
    if (!_imageLoadingSerialQueue) {
        _imageLoadingSerialQueue = dispatch_queue_create("com.mm.imageLoadingSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _imageLoadingSerialQueue;
}

- (NSMutableDictionary *)imagesByURL {
    if (!_imagesByURL) {
        _imagesByURL = [NSMutableDictionary new];
    }
    return _imagesByURL;
}

@end
