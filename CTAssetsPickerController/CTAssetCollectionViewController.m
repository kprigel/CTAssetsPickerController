/*
 
 MIT License (MIT)
 
 Copyright (c) 2015 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import "CTAssetsPickerDefines.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPickerController+Internal.h"
#import "CTAssetCollectionViewController.h"
#import "CTAssetCollectionViewCell.h"
#import "CTAssetsGridViewController.h"
#import "PHAssetCollection+CTAssetsPickerController.h"
#import "PHAsset+CTAssetsPickerController.h"
#import "PHImageManager+CTAssetsPickerController.h"
#import "NSBundle+CTAssetsPickerController.h"
#import "NSNumberFormatter+CTAssetsPickerController.h"




@interface CTAssetCollectionViewController()
<PHPhotoLibraryChangeObserver, CTAssetsGridViewControllerDelegate>

@property (nonatomic, weak) CTAssetsPickerController *picker;

@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, copy) NSArray *fetchResults;
@property (nonatomic, copy) NSArray *assetCollections;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property (nonatomic, strong) PHAssetCollection *defaultAssetCollection;
@property (nonatomic, assign) BOOL didShowDefaultAssetCollection;
@property (nonatomic, assign) BOOL didSelectDefaultAssetCollection;

@property (nonatomic,strong) NSMutableDictionary *assetCounts;

@end





@implementation CTAssetCollectionViewController

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain])
    {
        _imageManager = [PHCachingImageManager new];
        [self addNotificationObserver];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self localize];
    [self setupDefaultAssetCollection];
    [self setupFetchResults];
    [self registerChangeObserver];
    
    self.assetCounts=[[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupButtons];
    [self updateTitle:self.picker.selectedAssets];
    [self updateButton:self.picker.selectedAssets];
    [self resetTitle];
    [self selectDefaultAssetCollection];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (![self isTopViewController]){
    NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
    NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];
    
    if ([[NSString stringWithFormat:@"%@",self.picker.assetsFetchOptions.predicate] isEqualToString:[NSString stringWithFormat:@"%@",compoundPredicate]]){
        self.title=CTAssetsPickerLocalizedString(@"Videos",nil);
    }
    else{
        self.title = CTAssetsPickerLocalizedString(@"Photos", nil);}
    }
}
- (void)dealloc
{
    [self unregisterChangeObserver];
    [self removeNotificationObserver];
}


#pragma mark - Reload user interface

- (void)reloadUserInterface
{
    [self setupViews];
    [self setupButtons];
    [self localize];
    [self setupDefaultAssetCollection];
    [self setupFetchResults];
}


#pragma mark - Accessors

- (CTAssetsPickerController *)picker
{
    return (CTAssetsPickerController *)self.splitViewController.parentViewController;
}

- (NSIndexPath *)indexPathForAssetCollection:(PHAssetCollection *)assetCollection
{
    NSInteger row = [self.assetCollections indexOfObject:assetCollection];

    if (row != NSNotFound)
        return [NSIndexPath indexPathForRow:row inSection:0];
    else
        return nil;
}


#pragma mark - Setup

- (void)setupViews
{
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.estimatedRowHeight =
    self.picker.assetCollectionThumbnailSize.height +
    self.tableView.layoutMargins.top +
    self.tableView.layoutMargins.bottom;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupButtons
{
    if (self.doneButton == nil)
    {
        NSString *title = (self.picker.doneButtonTitle) ?
        self.picker.doneButtonTitle : CTAssetsPickerLocalizedString(@"Done", nil);
        
        self.doneButton =
        [[UIBarButtonItem alloc] initWithTitle:title
                                         style:UIBarButtonItemStyleDone
                                        target:self.picker
                                        action:@selector(finishPickingAssets:)];
    }
    
    if (self.cancelButton == nil)
    {
        self.cancelButton =
        [[UIBarButtonItem alloc] initWithTitle:CTAssetsPickerLocalizedString(@"Cancel", nil)
                                         style:UIBarButtonItemStylePlain
                                        target:self.picker
                                        action:@selector(dismiss:)];
    }
}

- (void)localize
{
    [self resetTitle];
}

- (void)setupFetchResults
{
    NSMutableArray *fetchResults = [NSMutableArray new];

    for (NSNumber *subtypeNumber in self.picker.assetCollectionSubtypes)
    {
        PHAssetCollectionType type       = [PHAssetCollection ctassetPickerAssetCollectionTypeOfSubtype:subtypeNumber.integerValue];
        PHAssetCollectionSubtype subtype = subtypeNumber.integerValue;
        
        PHFetchResult *fetchResult =
        [PHAssetCollection fetchAssetCollectionsWithType:type
                                                 subtype:subtype
                                                 options:self.picker.assetCollectionFetchOptions];
        
        [fetchResults addObject:fetchResult];
    }
    
    self.fetchResults = [NSMutableArray arrayWithArray:fetchResults];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self updateAssetCollections];
               dispatch_async(dispatch_get_main_queue(), ^(void) {
                        [self reloadData];
                        [self showDefaultAssetCollection];
                    });
            });}

- (void)updateAssetCollections
{
    NSMutableArray *assetCollections = [NSMutableArray new];

    for (PHFetchResult *fetchResult in self.fetchResults)
    {
        for (PHAssetCollection *assetCollection in fetchResult)
        {
            BOOL showsAssetCollection = YES;
            
            if (!self.picker.showsEmptyAlbums)
            {
               /*PHFetchOptions *options = [PHFetchOptions new];
                options.predicate = self.picker.assetsFetchOptions.predicate;
                
                options.fetchLimit = 1;
                
                NSInteger count = [assetCollection ctassetPikcerCountOfAssetsFetchedWithOptions:options];
                
                showsAssetCollection = (count > 0);*/
                showsAssetCollection = (assetCollection.estimatedAssetCount > 0);
            }
            
            if (showsAssetCollection)
                [assetCollections addObject:assetCollection];
        }
    }

    self.assetCollections = [NSMutableArray arrayWithArray:assetCollections];
    [self reloadData];
}

- (void)setupDefaultAssetCollection
{
    if (!self.picker || self.picker.defaultAssetCollection == PHAssetCollectionSubtypeAny) {
        self.defaultAssetCollection = nil;
        return;
    }
    
    PHAssetCollectionType type = [PHAssetCollection ctassetPickerAssetCollectionTypeOfSubtype:self.picker.defaultAssetCollection];
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:self.picker.defaultAssetCollection options:self.picker.assetCollectionFetchOptions];
    
    self.defaultAssetCollection = fetchResult.firstObject;
}


#pragma mark - Rotation

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self updateTitle:self.picker.selectedAssets];
        [self updateButton:self.picker.selectedAssets];
    } completion:nil];
}

#pragma mark - Notifications

- (void)addNotificationObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self
               selector:@selector(selectedAssetsChanged:)
                   name:CTAssetsPickerSelectedAssetsDidChangeNotification
                 object:nil];
    
    [center addObserver:self
               selector:@selector(contentSizeCategoryChanged:)
                   name:UIContentSizeCategoryDidChangeNotification
                 object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTAssetsPickerSelectedAssetsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}


#pragma mark - Photo library change observer

- (void)registerChangeObserver
{
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)unregisterChangeObserver
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


#pragma mark - Photo library changed

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *updatedFetchResults = nil;
        
        for (PHFetchResult *fetchResult in self.fetchResults)
        {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
            
            if (changeDetails)
            {
                if (!updatedFetchResults)
                    updatedFetchResults = [self.fetchResults mutableCopy];
                
                updatedFetchResults[[self.fetchResults indexOfObject:fetchResult]] = changeDetails.fetchResultAfterChanges;
            }
        }
        
        if (updatedFetchResults)
        {
            self.fetchResults = updatedFetchResults;
            [self updateAssetCollections];
            [self reloadData];
        }
        
    });
}


#pragma mark - Selected assets changed

- (void)selectedAssetsChanged:(NSNotification *)notification
{
    NSArray *selectedAssets = (NSArray *)notification.object;
    [self updateTitle:selectedAssets];
    [self updateButton:selectedAssets];
}

- (void)updateTitle:(NSArray *)selectedAssets
{
    if ([self isTopViewController] && selectedAssets.count > 0)
        self.title = self.picker.selectedAssetsString;
    else
       // if ([self isTopViewController])
            [self resetTitle];
    
}

- (void)updateButton:(NSArray *)selectedAssets
{
    self.navigationItem.leftBarButtonItem = (self.picker.showsCancelButton) ? self.cancelButton : nil;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    
    
    if((orientation == 0)||(orientation == UIInterfaceOrientationPortrait)){
         self.navigationItem.rightBarButtonItem = [self isTopViewController] ? self.doneButton : self.doneButton;
    }
    else if((orientation == UIInterfaceOrientationLandscapeLeft)
                ||(orientation == UIInterfaceOrientationLandscapeRight))
    {
         self.navigationItem.rightBarButtonItem = [self isTopViewController] ? self.doneButton : nil;
    }
        
   
    
    if (self.picker.alwaysEnableDoneButton)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = (self.picker.selectedAssets.count > 0);
}

- (BOOL)isTopViewController
{
    UIViewController *vc = self.splitViewController.viewControllers.lastObject;
    
    if ([vc isKindOfClass:[UINavigationController class]])
        return (self == ((UINavigationController *)vc).topViewController);
    else
        return NO;
}

- (NSPredicate *)predicateOfMediaType:(PHAssetMediaType)type
{
    return [NSPredicate predicateWithBlock:^BOOL(PHAsset *asset, NSDictionary *bindings) {
        return (asset.mediaType == type);
    }];
}



- (void)resetTitle
{
    
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (!self.picker.title){
        if(((orientation == UIInterfaceOrientationLandscapeLeft)
                                                                                ||(orientation == UIInterfaceOrientationLandscapeRight))&&([[UIDevice currentDevice] userInterfaceIdiom]!=UIUserInterfaceIdiomPad)){
            
            NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
            NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];

            if ([[NSString stringWithFormat:@"%@",self.picker.assetsFetchOptions.predicate] isEqualToString:[NSString stringWithFormat:@"%@",compoundPredicate]]){
                self.title=CTAssetsPickerLocalizedString(@"Videos",nil);
            }
            else{
                self.title = CTAssetsPickerLocalizedString(@"Photos", nil);}
            
        }
        else if((orientation == 0)||(orientation == UIInterfaceOrientationPortrait))
        {
            
            if (![self isTopViewController]){
                NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
                NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];
                
                if ([[NSString stringWithFormat:@"%@",self.picker.assetsFetchOptions.predicate] isEqualToString:[NSString stringWithFormat:@"%@",compoundPredicate]]){
                    self.title=CTAssetsPickerLocalizedString(@"Videos",nil);
                }
                else{
                    self.title = CTAssetsPickerLocalizedString(@"Photos", nil);}
            }
            else{
                
            
            NSPredicate *photoPredicate = [self predicateOfMediaType:PHAssetMediaTypeImage];
            NSPredicate *videoPredicate = [self predicateOfMediaType:PHAssetMediaTypeVideo];
            
            BOOL photoSelected = ([self.picker.selectedAssets filteredArrayUsingPredicate:photoPredicate].count > 0);
            BOOL videoSelected = ([self.picker.selectedAssets filteredArrayUsingPredicate:videoPredicate].count > 0);
            
            NSString *format;
            
            if (photoSelected||videoSelected){
                if (photoSelected && videoSelected)
                    format = CTAssetsPickerLocalizedString(@"%@ Items Selected", nil);
                
                else if (photoSelected)
                    format = (self.picker.selectedAssets.count > 1) ?
                    CTAssetsPickerLocalizedString(@"%@ Photos Selected", nil) :
                    CTAssetsPickerLocalizedString(@"%@ Photo Selected", nil);
                
                else if (videoSelected)
                    format = (self.picker.selectedAssets.count > 1) ?
                    CTAssetsPickerLocalizedString(@"%@ Videos Selected", nil) :
                    CTAssetsPickerLocalizedString(@"%@ Video Selected", nil);
                
                NSNumberFormatter *nf = [NSNumberFormatter new];
                
                NSString *countAssets=[nf ctassetsPickerStringFromAssetsCount:self.picker.selectedAssets.count];
                
                
                self.title = [NSString stringWithFormat:format, countAssets];
        
        }
            else{
            NSPredicate *predicateMediaType = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
            NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[predicateMediaType]];
            
            if ([[NSString stringWithFormat:@"%@",self.picker.assetsFetchOptions.predicate] isEqualToString:[NSString stringWithFormat:@"%@",compoundPredicate]]){
                self.title=CTAssetsPickerLocalizedString(@"Videos",nil);
            }
            else{
                self.title = CTAssetsPickerLocalizedString(@"Photos", nil);}
            }

    }
    }
    }
    else
        self.title = self.picker.title;
}


#pragma mark - Content size category changed

- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self reloadData];
}


#pragma mark - Reload data

- (void)reloadData
{
    if ([self.assetCollections count] > 0)
    {
        [self.tableView reloadData];
    }
    else
    {
        //[self.picker showNoAssets];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetCollections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collection = self.assetCollections[indexPath.row];
    NSUInteger count;
    
    if (self.picker.showsNumberOfAssets)
        {
            if ([self.assetCounts objectForKey:indexPath])
                count=[[self.assetCounts objectForKey:indexPath] integerValue];
            else{
                PHAssetCollection *collection = self.assetCollections[indexPath.row];
                
                if (self.picker.showsNumberOfAssets)
                    count = [collection ctassetPikcerCountOfAssetsFetchedWithOptions:self.picker.assetsFetchOptions];
                else
                    count = NSNotFound;
                
                [self.assetCounts setObject:[NSNumber numberWithInteger:count] forKey:indexPath];
            }
        }
    else
        count = NSNotFound;
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    CTAssetCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
        cell = [[CTAssetCollectionViewCell alloc] initWithThumbnailSize:self.picker.assetCollectionThumbnailSize
                                                            reuseIdentifier:cellIdentifier];
    
    [cell bind:collection count:count];
    [self requestThumbnailsForCell:cell assetCollection:collection];
    
    if (count==0)
        cell.hidden=TRUE;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count;
    
    if ([self.assetCounts objectForKey:indexPath])
        count=[[self.assetCounts objectForKey:indexPath] integerValue];
    else{
        PHAssetCollection *collection = self.assetCollections[indexPath.row];
        
        
        if (self.picker.showsNumberOfAssets)
            count = [collection ctassetPikcerCountOfAssetsFetchedWithOptions:self.picker.assetsFetchOptions];
        else
            count = NSNotFound;
    
        [self.assetCounts setObject:[NSNumber numberWithInteger:count] forKey:indexPath];
    }
    
    if (count==0)
        return 0.0;
    else
        return UITableViewAutomaticDimension;
}

- (void)requestThumbnailsForCell:(CTAssetCollectionViewCell *)cell assetCollection:(PHAssetCollection *)collection
{
    NSUInteger count    = cell.thumbnailStacks.thumbnailViews.count;
    NSArray *assets     = [self posterAssetsFromAssetCollection:collection count:count];
    CGSize targetSize   = [self.picker imageSizeForContainerSize:self.picker.assetCollectionThumbnailSize];
    
    for (NSUInteger index = 0; index < count; index++)
    {
        CTAssetThumbnailView *thumbnailView = [cell.thumbnailStacks thumbnailAtIndex:index];
        thumbnailView.hidden = (assets.count > 0) ? YES : NO;
        
        if (index < assets.count)
        {
            PHAsset *asset = assets[index];
            [self.imageManager ctassetsPickerRequestImageForAsset:asset
                                         targetSize:targetSize
                                        contentMode:PHImageContentModeAspectFill
                                            options:self.picker.thumbnailRequestOptions
                                      resultHandler:^(UIImage *image, NSDictionary *info){
                                          [thumbnailView setHidden:NO];
                                          [thumbnailView bind:image assetCollection:collection];
                                      }];
        }
    }
}

- (NSArray *)posterAssetsFromAssetCollection:(PHAssetCollection *)collection count:(NSUInteger)count;
{
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate       = self.picker.assetsFetchOptions.predicate; // aligned specified predicate
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *result = [PHAsset fetchKeyAssetsInAssetCollection:collection options:options];
    
    NSUInteger location = 0;
    NSUInteger length   = (result.count < count) ? result.count : count;
    NSArray *assets     = [self itemsFromFetchResult:result range:NSMakeRange(location, length)];
    
    return assets;
}

- (NSArray *)itemsFromFetchResult:(PHFetchResult *)result range:(NSRange)range
{
    if (result.count == 0)
        return nil;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    NSArray *array = [result objectsAtIndexes:indexSet];
    
    return array;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAssetCollection *collection = self.assetCollections[indexPath.row];
    
    CTAssetsGridViewController *vc = [CTAssetsGridViewController new];
    vc.title = self.picker.selectedAssetsString ? : collection.localizedTitle;
    vc.assetCollection = collection;
    vc.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.delegate = (id<UINavigationControllerDelegate>)self.picker;
    
    [self.picker setShouldCollapseDetailViewController:NO];
    [self.splitViewController showDetailViewController:nav sender:nil];
}


#pragma mark - Show / select default asset collection

- (void)showDefaultAssetCollection
{
    if (self.defaultAssetCollection && !self.didShowDefaultAssetCollection)
    {
        CTAssetsGridViewController *vc = [CTAssetsGridViewController new];
        vc.title = self.picker.selectedAssetsString ? : self.defaultAssetCollection.localizedTitle;
        vc.assetCollection = self.defaultAssetCollection;
        vc.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.delegate = (id<UINavigationControllerDelegate>)self.picker;
        
        [self.picker setShouldCollapseDetailViewController:(self.picker.modalPresentationStyle == UIModalPresentationFormSheet)];
        [self.splitViewController showDetailViewController:nav sender:nil];

        NSIndexPath *indexPath = [self indexPathForAssetCollection:self.defaultAssetCollection];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        self.didShowDefaultAssetCollection = YES;
    }
}

- (void)selectDefaultAssetCollection
{
    if (self.defaultAssetCollection && !self.didSelectDefaultAssetCollection)
    {
        NSIndexPath *indexPath = [self indexPathForAssetCollection:self.defaultAssetCollection];
        
        if (indexPath)
        {
            [UIView animateWithDuration:0.0f
                             animations:^{
                                 [self.tableView selectRowAtIndexPath:indexPath
                                                             animated:(!self.splitViewController.collapsed)
                                                       scrollPosition:UITableViewScrollPositionTop];
                         }
                         completion:^(BOOL finished){
                             // mimic clearsSelectionOnViewWillAppear
                             if (finished && self.splitViewController.collapsed)
                                 [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                         }];
        }
        
        self.didSelectDefaultAssetCollection = YES;
    }
}


#pragma mark - Grid view controller delegate

- (void)assetsGridViewController:(CTAssetsGridViewController *)picker photoLibraryDidChangeForAssetCollection:(PHAssetCollection *)assetCollection
{
    NSIndexPath *indexPath = [self indexPathForAssetCollection:assetCollection];
    
    if (indexPath)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

@end
