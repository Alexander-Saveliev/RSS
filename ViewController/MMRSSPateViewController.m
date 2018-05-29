//
//  MMRSSPateViewController.m
//  RSS
//
//  Created by Marty on 28/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSPateViewController.h"
#import "MMRSSViewController.h"
#import "MMRSSResourceUpdater.h"
#import "MMNetworkTask.h"
#import "MMRSSParser.h"
#import "MMRSSResourceEntity.h"
#import "MMCoreDataStackManager.h"
#import "MMRSSResource.h"

static NSString * const urlPlaceholder  = @"URL";
static NSString * const add             = @"Add tape";
static NSString * const cancel          = @"Cancel";
static NSString * const go              = @"Go";

@interface MMRSSPateViewController () <MMTapeUpdater>

@property BOOL readyToUpdate;
@property (nonatomic, strong) MMRSSResourceUpdater *updater;
@property (nonatomic, strong) dispatch_queue_t contentOperationSerialQueue;
@property (nonatomic, strong) NSMutableArray<MMRSSViewController *> *views;
//@property (nonatomic, strong) NSMutableArray<MMRSSResource *> *resources;

@end

@implementation MMRSSPateViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *resources = [self.updater fetchAllResources];
    
    _views = [NSMutableArray new];
    
    [resources enumerateObjectsUsingBlock:^(MMRSSResource * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMRSSViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
        viewController.resource = obj;
        viewController.pageIndex = idx;
        viewController.delegate = self;
        [self.views addObject:viewController];
    }];
    
    self.readyToUpdate = YES;
    
    self.dataSource = self;
    
    if (!resources.count) {
        MMRSSResource *firstResource = [MMRSSResource new];
        
        MMRSSViewController *initialVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
        initialVC.resource = firstResource;
        initialVC.pageIndex = 0;
        initialVC.delegate = self;
        [self.views addObject:initialVC];
    }
    
    
    [self setViewControllers:_views direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (MMRSSViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (index >= _views.count) {
        return nil;
    }
    
    return _views[index];
    
//    if (_views[index]) {
//        return _views[index];
//    }
//
//    MMRSSViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
//    viewController.tapeLink = [NSURL URLWithString:tapes[index]];
//    viewController.pageIndex = index;
//    viewController.delegate = self;
//    [_views addObject:viewController];
//
//    return viewController;
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((MMRSSViewController *)viewController).pageIndex;
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index -= 1;
    
    return [self viewControllerAtIndex:index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((MMRSSViewController *)viewController).pageIndex;
    
    if (index == NSNotFound || index == _views.count - 1) {
        return nil;
    }
    index += 1;
    
    return [self viewControllerAtIndex:index];
}


#pragma mark - Action

- (IBAction)addUrlButtonWasPressed:(UIBarButtonItem *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(add, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* actionGo = [UIAlertAction actionWithTitle:go
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           if (self.views.count == 1 && !self.views[0].resource.url) {
                                                               [self.views removeLastObject];
                                                           }
                                                           
                                                           MMRSSResource *newResource = [MMRSSResource new];
                                                           newResource.url = [NSURL URLWithString:alertVC.textFields[0].text];
                                                           
                                                           MMRSSViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RSSViewController"];
                                                           viewController.resource = newResource;
                                                           viewController.pageIndex = self.views.count;
                                                           viewController.delegate = self;
                                                           
                                                           [self.views addObject:viewController];
                                                           
                                                           [self setViewControllers:self.views direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
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
//    UIViewController *currentVc = self.viewControllers.firstObject;
//    NSUInteger index = currentVc.view.tag;
//    
//    if (index >= [tapes count] || index == 0) {
//        return;
//    }
//    
//    [tapes removeObjectAtIndex:index];
//    [_views removeObjectAtIndex:index];
//    
//    self.dataSource = nil;
//    self.dataSource = self;
//    
    
//    NSMutableArray *arr = self.viewControllers.mutableCopy;
//    [arr removeObject:currentVc];
//
//    if (!arr.count) {
//        [arr addObject:[UIViewController new]]; //TODO: сделать пустой контроллер (с текстом)
//        self.dataSource = nil;
//    }
//    [self setViewControllers:arr direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
//
//    NSURL *url = tapes[index];
//    if (!url) {
//        NSLog(@"incorrect url");
//        return;
//    }
//    dispatch_async(self.contentOperationSerialQueue, ^{
//        @synchronized (self) {
//            [self->_updater deletaResourceWithUrl:url];
//            [self->tapes removeObject:url];
//        }
//    });
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

@end
