//
//  MMCollectionViewController.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSViewController.h"
#import "MMCollectionViewCell.h"
#import "MMDetailViewController.h"
#import "MMNetworkTask.h"
#import "MMRSSParser.h"
#import "MMRSSResourceUpdater.h"
#import "MMRSSResourceEntity.h"
#import "MMCoreDataStackManager.h"
#import "MMRSSItem.h"
#import "MMRSSItemEntity.h"

static NSString * const reuseIdentifier = @"Cell";
static NSString * const urlPlaceholder  = @"URL";
static NSString * const showMore        = @"showMore";
static NSString * const cancel          = @"Cancel";
static NSString * const add             = @"Add tape";
static NSString * const go              = @"Go";

@interface MMRSSViewController () <ImageLoading, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) dispatch_queue_t contentOperationSerialQueue;
@property (nonatomic, strong) MMRSSResource *resource;
@property BOOL readyToUpdate;
@property (nonatomic, strong) MMRSSResourceUpdater *updater;

@end

@implementation MMRSSViewController

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 100);
}

- (void)updateWithBlock:(void(^)(void))block {
    if (!_readyToUpdate) {
        return;
    } else {
        _readyToUpdate = NO;
    }
    
    MMNetworkTask *task = [MMNetworkTask new];
    NSURL *url = [NSURL URLWithString:@"https://habrahabr.ru/rss/interesting/"];
    
    dispatch_async(self.contentOperationSerialQueue, ^{
        [task initWithURL:url successBlock:^(NSData *data) {
            MMRSSParser *parser = [MMRSSParser new];
            [parser parse:data withURL:url success:^(id<MMRSSXMLResource> resource) {
                dispatch_async(self.contentOperationSerialQueue, ^{
                    [self.updater update:resource];
                    [self fetchContent];
                    self.readyToUpdate = YES;
                    if (block) {
                        block();
                    }
                });
            } failure:^{
                NSLog(@"Parsing error");
                self.readyToUpdate = YES;
                if (block) {
                    block();
                }
            }];
        } failureBlock:^(NSError *error) {
            NSLog(@"Loading error");
            self.readyToUpdate = YES;
            if (block) {
                block();
            }
        }];
    });
}

- (MMRSSResourceUpdater *)updater {
    if (!_updater) {
        _updater = [MMRSSResourceUpdater new];
    }
    return _updater;
}

- (void)fetchContent {
    dispatch_async(self.contentOperationSerialQueue, ^{
        NSFetchRequest *request =  [MMRSSResourceEntity fetchRequestWithResourceURL:[NSURL URLWithString:@"https://habrahabr.ru/rss/interesting/"]];
        NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
        
        NSArray<MMRSSResourceEntity *> *result = [context executeFetchRequest:request error:nil];
        
        if (result.firstObject) {
            self.resource = [MMRSSResource makeFromEntity:result[0]];
            
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf.collectionView reloadData];
                strongSelf.readyToUpdate = YES;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf updateVisibleCellsImages];
                });
            });
        } else {
            NSLog(@"result is empty");
            self.readyToUpdate = YES;
        }
    });
}

- (void)refreshWasPulled:(UIRefreshControl *)refreshController {
    [self updateWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshController endRefreshing];
        });
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchContent];
    
    UIRefreshControl *refreshController = [UIRefreshControl new];
    
    refreshController.backgroundColor = [UIColor redColor];
    refreshController.tintColor       = [UIColor whiteColor];
    [refreshController addTarget:self action:@selector(refreshWasPulled:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshController];
    
    self.readyToUpdate = YES;
    
    [self updateWithBlock:nil];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; //TODO: Budet 4to-to
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return (_resource.items) ? _resource.items.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    MMRSSItem *item;
    
    cell.delegate = self;
    
    if (_resource.items[indexPath.row]) {
        item = _resource.items[indexPath.row];
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

- (dispatch_queue_t)contentOperationSerialQueue {
    if (!_contentOperationSerialQueue) {
        _contentOperationSerialQueue = dispatch_queue_create("com.mm.imageLoadingSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _contentOperationSerialQueue;
}

- (void)loadImageData:(MMRSSItem *)item successBlock:(void(^)(NSData *data))successBlock {
    dispatch_async(self.contentOperationSerialQueue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:item.imgUrl];
        item.img = imgData;
        
        if (imgData) {
            [self.updater updateItemEntity:item.link withBlock:^(MMRSSItemEntity *item) {
                item.p_img = imgData;
            }];
        }
        
        if (successBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successBlock(imgData);
            });
        }
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:showMore]) {
        MMDetailViewController *fullItemVC = [segue destinationViewController];
        NSLog(@"send");
        
       // fullItemVC.item = self.fullElement;
        NSLog(@"sended");
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _resource.items.count) {        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"DetailsViewController" bundle:nil];
        MMDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MMDetailViewController"];
        vc.item = _resource.items[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
