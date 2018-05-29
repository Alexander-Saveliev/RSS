//
//  MMRSSPateViewController.m
//  RSS
//
//  Created by Marty on 28/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//
#import <SCPageViewController.h>
#import <SCPageLayouter.h>

#import "MMRSSPateViewController.h"
#import "MMRSSViewController.h"
#import "MMRSSResourceUpdater.h"
#import "MMNetworkTask.h"
#import "MMRSSParser.h"
#import "MMRSSResourceEntity.h"
#import "MMCoreDataStackManager.h"
#import "MMRSSResource.h"
#import "MMRSSBaseViewController.h"

static NSString * const urlPlaceholder  = @"URL";
static NSString * const add             = @"Add tape";
static NSString * const cancel          = @"Cancel";
static NSString * const go              = @"Go";

@interface MMRSSPateViewController () <MMTapeUpdater, SCPageViewControllerDataSource>

@property BOOL readyToUpdate;
@property (nonatomic, strong) MMRSSResourceUpdater *updater;
@property (nonatomic, strong) dispatch_queue_t contentOperationSerialQueue;
@property (nonatomic, strong) NSMutableArray<MMRSSBaseViewController *> *views;
@property (nonatomic, strong) SCPageViewController *pageViewController;
@property (nonatomic, strong) MMRSSBaseViewController *initialVC;

@end

@implementation MMRSSPateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageViewController = [SCPageViewController new];
    [_pageViewController setDataSource:self];
    
    [self.pageViewController setLayouter:[[SCPageLayouter alloc] init] animated:NO completion:nil];
    
    NSMutableArray *resources = [self.updater fetchAllResources];
    
    _views = [NSMutableArray new];
    
    [resources enumerateObjectsUsingBlock:^(MMRSSResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRSSViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
        viewController.resource = obj;
        viewController.pageIndex = idx;
        viewController.delegate = self;
        
        
        [self.views addObject:viewController];
    }];
    
    if (!resources.count) {
        [self.views addObject:[self initialVC]];
    }
    
    [self addChildViewController:self.pageViewController];
    [self.pageViewController.view setFrame:self.view.bounds];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.readyToUpdate = YES;
}

- (NSUInteger)numberOfPagesInPageViewController:(SCPageViewController *)pageViewController {
    return _views.count;
}

- (UIViewController *)pageViewController:(SCPageViewController *)pageViewController viewControllerForPageAtIndex:(NSUInteger)pageIndex {
    if (pageIndex >= _views.count) {
        return nil;
    }
    
    return _views[pageIndex];
}

#pragma mark - Action

- (IBAction)addUrlButtonWasPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(add, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* actionGo = [UIAlertAction actionWithTitle:go
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           if (!self.views[0].resource) {
                                                               [self.views removeLastObject];
                                                           }
                                                           
                                                           MMRSSResource *newResource = [MMRSSResource new];
                                                           newResource.url = [NSURL URLWithString:alertVC.textFields[0].text];
                                                           
                                                           MMRSSViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
                                                           viewController.resource = newResource;
                                                           viewController.pageIndex = self.views.count;
                                                           viewController.delegate = self;
                                                           
                                                           [self.views addObject:viewController];
                                                           
                                                           [self.pageViewController reloadData];
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

- (IBAction)deleteTape:(UIBarButtonItem *)sender {
    NSUInteger index = [self.pageViewController currentPage];
    
    if (index >= _views.count) {
        return;
    }
    
    if (index == 1 && _views.count == 1 && !_views[0].resource.url) {
        return;
    }
    
    dispatch_async(self.contentOperationSerialQueue, ^{
        NSURL *url = self.views[index].resource.url;
        [self->_updater deletaResourceWithUrl:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.views removeObjectAtIndex:index];
            
            if (!self.views.count) {
                [self.views addObject:[self initialVC]];
            }
            [self.pageViewController reloadData];
        });
    });
}

#pragma mark - Delegate

- (void)updateWithURL:(NSURL *)url andBlock:(void(^)(void))block {
    if (!_readyToUpdate) {
        return;
    }
    _readyToUpdate = NO;
    
    MMNetworkTask *task = [MMNetworkTask new];
    
    dispatch_async(self.contentOperationSerialQueue, ^{
        @synchronized (self) {
            [task initWithURL:url successBlock:^(NSData *data) {
                MMRSSParser *parser = [MMRSSParser new];
                [parser parse:data withURL:url success:^(id<MMRSSXMLResource> resource) {
                    dispatch_async(self.contentOperationSerialQueue, ^{
                        [self.updater update:resource];
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
        }
    });
}

- (void)fetchContentWithURL:(NSURL *)url successBlock:(void(^)(MMRSSResource *resource))successBlock failureBlock:(void(^)(void))failureBlock {
    dispatch_async(self.contentOperationSerialQueue, ^{
        NSFetchRequest *request =  [MMRSSResourceEntity fetchRequestWithResourceURL:url];
        NSManagedObjectContext *context = [[MMCoreDataStackManager sharedInstance] context];
        
        NSArray<MMRSSResourceEntity *> *result = [context executeFetchRequest:request error:nil];
        
        if (result.firstObject) {
            MMRSSResource *resource = [MMRSSResource makeFromEntity:result[0]];
            if (successBlock) {
                successBlock(resource);
            }
        } else {
            NSLog(@"result is empty");
        }
    });
}

- (void)updateItemEntity:(NSURL *)itemUrl withBlock:(void (^)(MMRSSItemEntity *))block {
    [_updater updateItemEntity:itemUrl withBlock:block];
}

#pragma mark - lazy -

- (MMRSSResourceUpdater *)updater {
    if (!_updater) {
        _updater = [MMRSSResourceUpdater new];
    }
    return _updater;
}

- (dispatch_queue_t)contentOperationSerialQueue {
    if (!_contentOperationSerialQueue) {
        _contentOperationSerialQueue = dispatch_queue_create("com.mm.imageLoadingSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _contentOperationSerialQueue;
}

- (MMRSSBaseViewController *)initialVC {
    if (!_initialVC) {
        _initialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EmptyVC"];
    }
    return _initialVC;
}

@end
