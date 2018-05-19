//
//  MMCollectionViewController.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSViewController.h"
#import "MMCollectionViewCell.h"
#import "MMElementRSS.h"
#import "MMFullElementRSS.h"
#import "MMDetailViewController.h"
#import "MMNetworkTask.h"
#import "MMRSSParser.h"
#import "MMRSSResourceUpdater.h"
#import "MMRSSResourceEntity.h"
#import "MMCoreDataStackManager.h"
#import "MMRSSItem.h"


@interface MMRSSViewController () <ImageLoading, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) dispatch_queue_t imageLoadingSerialQueue;
@property (nonatomic, strong) MMRSSResource *resource;
@property BOOL readyToUpdate;

@end


@implementation MMRSSViewController

@synthesize resource;
@synthesize readyToUpdate;

static NSString * const reuseIdentifier = @"Cell";

- (void)update {
    if (!readyToUpdate) {
        return;
    } else {
        self->readyToUpdate = NO;
    }
    
    MMNetworkTask *task = [MMNetworkTask new];
    
    [task initWithURL:[NSURL URLWithString:@"https://habrahabr.ru/rss/interesting/"] successBlock:^(NSData *data) {
        MMRSSParser *parser = [MMRSSParser new];
        [parser parse:data success:^(id<MMRSSXMLResource> resource) {
            MMRSSResourceUpdater *updater = [MMRSSResourceUpdater new];
            [updater update:resource];
            [self fetchContent];
        } failure:^{
            NSLog(@"Parsing error");
            self->readyToUpdate = YES;
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Loading error");
        self->readyToUpdate = YES;
    }];
}

- (void)fetchContent {
    NSFetchRequest *request =  [MMRSSResourceEntity fetchRequestWithResourceURL:[NSURL URLWithString:@"https://habr.com/"]];
    NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
    
    NSArray<MMRSSResourceEntity *> *result = [context executeFetchRequest:request error:nil];
    
    if (result.firstObject) {
        self.resource = [MMRSSResource makeFromEntity:result[0]];
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            [strongSelf.collectionView reloadData];
            strongSelf->readyToUpdate = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf updateVisibleCellsImages];
            });
        });
    } else {
        NSLog(@"result is empty");
        self->readyToUpdate = YES;
    }
}

- (void)refreshWasPulled:(UIRefreshControl *)refreshController {
    [refreshController endRefreshing];
    
    [self update];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchContent];
    
    UIRefreshControl *refreshController = [UIRefreshControl new];
    
    refreshController.backgroundColor = [UIColor redColor];
    refreshController.tintColor       = [UIColor whiteColor];
    [refreshController addTarget:self action:@selector(refreshWasPulled:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshController];
    
    self->readyToUpdate = YES;
    
    [self update];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; //TODO: Budet 4to-to
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (resource.items) ? resource.items.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    MMRSSItem *item;
    
    cell.delegate = self;
    
    if (resource.items[indexPath.row]) {
        item = resource.items[indexPath.row];
    } else {
        cell.title.text = @"";
        cell.date.text  = @"";
        
        return cell;
    }
    
    [cell configureWithItem:item];
    
    return cell;
}

- (void)updateVisibleCellsImages {
    for (MMCollectionViewCell *cell in [self.collectionView visibleCells]) {
        [cell setupImageIfNeeded];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateVisibleCellsImages];
}

- (dispatch_queue_t)imageLoadingSerialQueue {
    if (!_imageLoadingSerialQueue) {
        _imageLoadingSerialQueue = dispatch_queue_create("com.mm.imageLoadingSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _imageLoadingSerialQueue;
}


/*
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
        MMDetailViewController *fullItemVC = [segue destinationViewController];
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
    self.fullElement.element      = element;
    self.fullElement.elementImage = img;
    NSLog(@"set element");
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
    
    MMParserRSS *parser = [MMParserRSS new];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [parser setData:data];
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf->rssData = [parser parsedItems];
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.collectionView reloadData];
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
*/

- (void)loadImageData:(MMRSSItem *)item successBlock:(void(^)(NSData *data))successBlock {
    dispatch_async(self.imageLoadingSerialQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:item.imgUrl];
        item.img = imgData;
        
        if (successBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(imgData);
            });
        }
        
        
    });
}



@end
