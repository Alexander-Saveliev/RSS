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
static NSString * const showMore        = @"showMore";

@interface MMRSSViewController () <ImageLoading, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) dispatch_queue_t contentOperationSerialQueue;
@property (nonatomic, assign) BOOL elementSelected;

@end

@implementation MMRSSViewController

@synthesize resource;
@synthesize pageIndex;
//- (IBAction)refreshButtonWasPressed:(UIBarButtonItem *)sender {
//    [self updateWithURL:_tapeLink andBlock:nil];
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width, 100);
}

- (void)refreshWasPulled:(UIRefreshControl *)refreshController {
    [_delegate updateWithURL:resource.url andBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshController endRefreshing];
        });
    }];
}

- (void)updateView {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf.collectionView.backgroundView setHidden:YES];
        [strongSelf.collectionView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf updateVisibleCellsImages];
        });
    });
}

- (void)newTapeIsComeingWithUrl:(NSURL *)url {
    [_delegate fetchContentWithURL:resource.url successBlock:^(MMRSSResource *resource) {
        self.resource = resource;
        [self updateView];
    } failureBlock:^{
        NSLog(@"some error");
    }];

    [_delegate updateWithURL:self.resource.url andBlock:^{
        [self->_delegate fetchContentWithURL:self.resource.url successBlock:^(MMRSSResource *resource) {
            self.resource = resource;
           [self updateView];
        } failureBlock:^{
            NSLog(@"some error");
            //TODO: show error label
        }];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _elementSelected = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIRefreshControl *refreshController = [UIRefreshControl new];
    
    refreshController.backgroundColor = [UIColor clearColor];
    refreshController.tintColor       = [UIColor grayColor];
    [refreshController addTarget:self action:@selector(refreshWasPulled:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshController];
    
    [self newTapeIsComeingWithUrl:resource.url];
    
    self.collectionView.alwaysBounceVertical = YES;
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (resource.items) {
        return 1;
    } else {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.collectionView.backgroundView = messageLabel;
    }
    
    return 0;
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
            [self->_delegate updateItemEntity:item.link withBlock:^(MMRSSItemEntity *item) {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < resource.items.count && !_elementSelected) {
        _elementSelected = YES;
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"DetailsViewController" bundle:nil];
        MMDetailViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MMDetailViewController"];
        vc.item = resource.items[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
