//
//  TZImagePickerController.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//  version 3.4.3 - 2020.09.24
//  更多信息，请前往项目的github地址：https://github.com/banchichen/TZImagePickerController

#import "TZImagePickerController.h"
#import "TZPhotoPickerController.h"
#import "TZPhotoPreviewController.h"
#import "TZAssetModel.h"
#import "TZAssetCell.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import <sys/utsname.h>

@interface TZImagePickerController () {
    NSTimer *_timer;
    UILabel *_tipLabel;
    UIButton *_settingBtn;
    BOOL _pushPhotoPickerVc;
    BOOL _didPushPhotoPickerVc;
    CGRect _cropRect;
    
    UIButton *_progressHUD;
    UIView *_HUDContainer;
    UIActivityIndicatorView *_HUDIndicatorView;
    UILabel *_HUDLabel;
    
    UIStatusBarStyle _originStatusBarStyle;
}
/// Default is 4, Use in photos collectionView in TZPhotoPickerController
/// 默认4列, TZPhotoPickerController中的照片collectionView
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) NSInteger HUDTimeoutCount; ///< 超时隐藏HUD计数
@end

@implementation TZImagePickerController

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithMaxImagesCount:9 delegate:nil];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(BOOL) shouldAutorotate
{
    return NO;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needShowStatusBar = ![UIApplication sharedApplication].statusBarHidden;
//    self.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationBar.translucent = YES;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;

    [TZImageManager manager].shouldFixOrientation = NO;
    
    // Default appearance, you can reset these after this method
    // 默认的外观，你可以在这个方法后重置
    self.oKButtonTitleColorNormal   = [TZCutomColor whiteColor];
    self.oKButtonTitleColorDisabled = [TZCutomColor whiteColor];
    if (_mainColor) {
        self.oKButtonBackGroundColorEnabled = _mainColor;
    } else {
        self.oKButtonBackGroundColorEnabled = [TZCutomColor colorWithRed:89 / 255.0 green:182 / 255.0 blue:215 / 255.0 alpha:1];
    }
    self.oKButtonBackGroundColorDisabled = [TZCutomColor colorWithRed:222 / 255.0 green:222 / 255.0 blue:222 / 255.0 alpha:1];
//    self.navigationBar.barTintColor = [TZCutomColor whiteColor];
//    self.navigationBar.tintColor = [TZCutomColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
    self.selectedAssetIds = [NSMutableArray array];
//    self.modalPresentationStyle = UIModalPresentationFullScreen;
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:(34/255.0) green:(34/255.0)  blue:(34/255.0) alpha:1.0];
    
    self.navigationBar.tintColor = [TZCutomColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)setNaviBgColor:(UIColor *)naviBgColor {
    _naviBgColor = naviBgColor;
    self.navigationBar.barTintColor = naviBgColor;
}

- (void)setNaviTitleColor:(UIColor *)naviTitleColor {
    _naviTitleColor = naviTitleColor;
    [self configNaviTitleAppearance];
}

- (void)setNaviTitleFont:(UIFont *)naviTitleFont {
    _naviTitleFont = naviTitleFont;
    [self configNaviTitleAppearance];
}

- (void)configNaviTitleAppearance {
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    if (self.naviTitleColor) {
        textAttrs[NSForegroundColorAttributeName] = self.naviTitleColor;
    }
    if (self.naviTitleFont) {
        textAttrs[NSFontAttributeName] = self.naviTitleFont;
    }
    self.navigationBar.titleTextAttributes = textAttrs;
}

- (void)setBarItemTextFont:(UIFont *)barItemTextFont {
    _barItemTextFont = barItemTextFont;
    [self configBarButtonItemAppearance];
}

- (void)setBarItemTextColor:(UIColor *)barItemTextColor {
    _barItemTextColor = barItemTextColor;
    [self configBarButtonItemAppearance];
}

- (void)setIsStatusBarDefault:(BOOL)isStatusBarDefault {
    _isStatusBarDefault = isStatusBarDefault;
    
    if (isStatusBarDefault) {
        self.statusBarStyle = UIStatusBarStyleDefault;
    } else {
        self.statusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)configBarButtonItemAppearance {
    UIBarButtonItem *barItem;
    if (@available(iOS 9, *)) {
        barItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
    } else {
        barItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
    }
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = self.barItemTextColor;
    textAttrs[NSFontAttributeName] = self.barItemTextFont;
    [barItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [self.navigationBar setShadowImage:[self imageWithColor:[UIColor clearColor] size:CGSizeMake(UIScreen.mainScreen.bounds.size.width, 1)]];
    /// 更新TZPhotoPickerController的是否显示选中编号的开关
    if (self.viewControllers.count > 0) {
        for (UIViewController * vc in self.viewControllers) {
            if ([vc isKindOfClass:[TZPhotoPickerController class]]) {
                TZPhotoPickerController *pickerVC = (TZPhotoPickerController*)vc;
            } else if([vc isKindOfClass:[TZAlbumPickerController class]]) {
                TZAlbumPickerController *albumPickVC = (TZAlbumPickerController*)vc;
                albumPickVC.mainColor = self.mainColor;
            }
        }
    }
    
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = _originStatusBarStyle;
    [self hideProgressHUD];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TZImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    albumPickerVc.isFirstAppear = YES;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        self.shouldSetCoverImage = YES;
        self.selectedAssets = [NSMutableArray array];
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = YES;
        self.videoMaximumDuration = 10 * 60;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        self.selectedAssets = [NSMutableArray array];
        self.couldQuickExportVideoMaxSeconds = 5 * 60;
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.tz_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            
            NSDictionary *infoDict = [TZCommonTools tz_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.tz_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

- (instancetype)initWithMaxImagesCountTSType:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc square:(BOOL)square shouldPick:(BOOL)shouldPick topTitle:(NSString *)topTitle {
    _isSquare = square;
    _shouldPick = shouldPick;
    _topTitle = topTitle;
    _pushPhotoPickerVc = pushPhotoPickerVc;
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    albumPickerVc.isFirstAppear = YES;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        self.shouldSetCoverImage = YES;
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = YES;
        self.videoMaximumDuration = 10 * 60;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        self.couldQuickExportVideoMaxSeconds = 5 * 60;
        [self configDefaultSetting];
        
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.tz_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            _tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;

            NSDictionary *infoDict = [TZCommonTools tz_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleExecutable"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.tz_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];

            _settingBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:_settingBtn];
            
            if ([PHPhotoLibrary authorizationStatus] == 0) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
            }
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

/// This init method just for previewing photos / 用这个初始化方法以预览图片
- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index{
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        [self configDefaultSetting];
        self.shouldSetCoverImage = YES;
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (!strongSelf) return;
                if (strongSelf.didFinishPickingPhotosHandle) {
                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
                }
            }];
        }];
    }
    return self;
}

/// This init method for crop photo / 用这个初始化方法以裁剪图片
- (instancetype)initCropTypeWithAsset:(PHAsset *)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,PHAsset *asset))completion {
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.maxImagesCount = 1;
        self.allowPickingImage = YES;
        self.allowCrop = YES;
        self.selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
        [self configDefaultSetting];
        self.shouldSetCoverImage = YES;
        
        previewVc.photos = [NSMutableArray arrayWithArray:@[photo]];
        previewVc.isCropImage = YES;
        previewVc.currentIndex = 0;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockCropMode:^(UIImage *cropImage, id asset) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion(cropImage,asset);
                }
            }];
        }];
    }
    return self;
}

- (instancetype)initWithMaxImagesCountTSType:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc square:(BOOL)square shouldPick:(BOOL)shouldPick topTitle:(NSString *)topTitle mainColor:(UIColor *)mainColor {
    _isSquare = square;
    _shouldPick = shouldPick;
    _topTitle = topTitle;
    _pushPhotoPickerVc = pushPhotoPickerVc;
    _mainColor = mainColor;
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    albumPickerVc.isFirstAppear = YES;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        self.shouldSetCoverImage = YES;
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        [self configDefaultSetting];
        
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.tz_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            
            NSDictionary *infoDict = [TZCommonTools tz_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.tz_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount delegate:(id<TZImagePickerControllerDelegate>)delegate mainColor:(UIColor *)mainColor {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:4 delegate:delegate pushPhotoPickerVc:YES mainColor:mainColor];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate mainColor:(UIColor *)mainColor {
    return [self initWithMaxImagesCount:maxImagesCount columnNumber:columnNumber delegate:delegate pushPhotoPickerVc:YES mainColor:mainColor];
}

- (instancetype)initWithMaxImagesCount:(NSInteger)maxImagesCount columnNumber:(NSInteger)columnNumber delegate:(id<TZImagePickerControllerDelegate>)delegate pushPhotoPickerVc:(BOOL)pushPhotoPickerVc mainColor:(UIColor *)mainColor {
    _pushPhotoPickerVc = pushPhotoPickerVc;
    _mainColor = mainColor;
    TZAlbumPickerController *albumPickerVc = [[TZAlbumPickerController alloc] init];
    albumPickerVc.isFirstAppear = YES;
    albumPickerVc.columnNumber = columnNumber;
    self = [super initWithRootViewController:albumPickerVc];
    if (self) {
        self.maxImagesCount = maxImagesCount > 0 ? maxImagesCount : 9; // Default is 9 / 默认最大可选9张图片
        self.pickerDelegate = delegate;
        self.selectedModels = [NSMutableArray array];
        self.shouldSetCoverImage = YES;
        
        // Allow user picking original photo and video, you also can set No after this method
        // 默认准许用户选择原图和视频, 你也可以在这个方法后置为NO
        self.allowPickingOriginalPhoto = YES;
        self.allowPickingVideo = YES;
        self.allowPickingImage = YES;
        self.allowTakePicture = YES;
        self.allowTakeVideo = YES;
        self.sortAscendingByModificationDate = YES;
        self.autoDismiss = YES;
        self.columnNumber = columnNumber;
        self.couldQuickExportVideoMaxSeconds = 5 * 60;
        [self configDefaultSetting];
        
        if (![[TZImageManager manager] authorizationStatusAuthorized]) {
            _tipLabel = [[UILabel alloc] init];
            _tipLabel.frame = CGRectMake(8, 120, self.view.tz_width - 16, 60);
            _tipLabel.textAlignment = NSTextAlignmentCenter;
            _tipLabel.numberOfLines = 0;
            _tipLabel.font = [UIFont systemFontOfSize:16];
            _tipLabel.textColor = [UIColor blackColor];
            
            NSDictionary *infoDict = [TZCommonTools tz_getInfoDictionary];
            NSString *appName = [infoDict valueForKey:@"CFBundleDisplayName"];
            if (!appName) appName = [infoDict valueForKey:@"CFBundleName"];
            NSString *tipText = [NSString stringWithFormat:[NSBundle tz_localizedStringForKey:@"Allow %@ to access your album in \"Settings -> Privacy -> Photos\""],appName];
            _tipLabel.text = tipText;
            [self.view addSubview:_tipLabel];
            
            _settingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
            [_settingBtn setTitle:self.settingBtnTitleStr forState:UIControlStateNormal];
            _settingBtn.frame = CGRectMake(0, 180, self.view.tz_width, 44);
            _settingBtn.titleLabel.font = [UIFont systemFontOfSize:18];
            [_settingBtn addTarget:self action:@selector(settingBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_settingBtn];
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];

        } else {
            [self pushPhotoPickerVc];
        }
    }
    return self;
}

- (instancetype)initWithSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index mainColor:(UIColor *)mainColor {
    _mainColor = mainColor;
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
        self.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
        self.couldQuickExportVideoMaxSeconds = 5 * 60;
        [self configDefaultSetting];
        self.shouldSetCoverImage = YES;
        
        previewVc.photos = [NSMutableArray arrayWithArray:selectedPhotos];
        previewVc.currentIndex = index;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockWithPreviewType:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (!strongSelf) return;
                if (strongSelf.didFinishPickingPhotosHandle) {
                    strongSelf.didFinishPickingPhotosHandle(photos,assets,isSelectOriginalPhoto);
                }
            }];
        }];
    }
    return self;
}

- (instancetype)initCropTypeWithAsset:(id)asset photo:(UIImage *)photo completion:(void (^)(UIImage *cropImage,id asset))completion mainColor:(UIColor *)mainColor {
    _mainColor = mainColor;
    TZPhotoPreviewController *previewVc = [[TZPhotoPreviewController alloc] init];
    self = [super initWithRootViewController:previewVc];
    if (self) {
        self.maxImagesCount = 1;
        self.allowCrop = YES;
        self.selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
        [self configDefaultSetting];
        self.couldQuickExportVideoMaxSeconds = 5 * 60;
        self.shouldSetCoverImage = YES;
        
        previewVc.photos = [NSMutableArray arrayWithArray:@[photo]];
        previewVc.isCropImage = YES;
        previewVc.currentIndex = 0;
        __weak typeof(self) weakSelf = self;
        [previewVc setDoneButtonClickBlockCropMode:^(UIImage *cropImage, id asset) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf dismissViewControllerAnimated:YES completion:^{
                if (completion) {
                    completion(cropImage,asset);
                }
            }];
        }];
    }
    return self;
}

- (void)configDefaultSetting {
    self.autoSelectCurrentWhenDone = YES;
    self.timeout = 15;
    self.photoWidth = 828.0;
    self.photoPreviewMaxWidth = 600;
    self.naviTitleColor = [UIColor whiteColor];
    self.naviTitleFont = [UIFont systemFontOfSize:17];
    self.barItemTextFont = [UIFont systemFontOfSize:15];
    self.barItemTextColor = [UIColor whiteColor];
    self.allowPreview = YES;
    // 2.2.26版本，不主动缩放图片，降低内存占用
    self.notScaleImage = YES;
    self.needFixComposition = NO;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.allowCameraLocation = YES;
    
    self.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    [self configDefaultBtnTitle];
    [self configDefaultImageName];
    CGFloat cropViewWH = MIN(self.view.tz_width, self.view.tz_height) / 3 * 2;
    self.cropRect = CGRectMake((self.view.tz_width - cropViewWH) / 2, (self.view.tz_height - cropViewWH) / 2, cropViewWH, cropViewWH);
}

- (void)configDefaultImageName {
    self.takePictureImageName = @"takePicture80";
    self.photoSelImageName = @"photo_sel_photoPickerVc";
    self.photoDefImageName = @"photo_def_photoPickerVc";
    self.photoPreviewSelImageName = @"preview_select_sel";
    self.photoPreviewDefImageName = @"preview_select_def";
    self.photoNumberIconImageName = @"photo_number_icon";
    self.photoNumberIconImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    self.photoPreviewOriginDefImageName = @"preview_original_def";
    self.photoOriginDefImageName = @"photo_original_def";
    self.photoOriginSelImageName = @"photo_original_sel";
}
// 为了不大幅改动TZ原结构，重写get方法定制UI
- (NSString* )takePictureImageName {
    if (self.allowPickingGif == NO && self.allowPickingImage == NO && self.allowPickingVideo == YES) {
        return @"takeVideo";
    } else {
        return @"takePicture";
    }
}
- (void)setSelectImage:(UIImage *)selectImage {
    /// 建议直接使用photoSelImage进行设置，为兼容旧版本暂不移除该属性
    _selectImage = selectImage;
    self.photoSelImage = selectImage;
}

- (void)setPhotoSelImageName:(NSString *)photoSelImageName {
    _photoSelImageName = photoSelImageName;
    _photoSelImage = [UIImage tz_imageNamedFromMyBundle:photoSelImageName];
}

- (void)setPhotoDefImageName:(NSString *)photoDefImageName {
    _photoDefImageName = photoDefImageName;
    _photoDefImage = [UIImage tz_imageNamedFromMyBundle:photoDefImageName];
}

- (void)setPhotoNumberIconImageName:(NSString *)photoNumberIconImageName {
    _photoNumberIconImageName = photoNumberIconImageName;
    _photoNumberIconImage = [UIImage tz_imageNamedFromMyBundle:photoNumberIconImageName];
}

- (void)setPhotoPreviewOriginDefImageName:(NSString *)photoPreviewOriginDefImageName {
    _photoPreviewOriginDefImageName = photoPreviewOriginDefImageName;
    _photoPreviewOriginDefImage = [UIImage tz_imageNamedFromMyBundle:photoPreviewOriginDefImageName];
}

- (void)setPhotoOriginDefImageName:(NSString *)photoOriginDefImageName {
    _photoOriginDefImageName = photoOriginDefImageName;
    _photoOriginDefImage = [UIImage tz_imageNamedFromMyBundle:photoOriginDefImageName];
}

- (void)setPhotoOriginSelImageName:(NSString *)photoOriginSelImageName {
    _photoOriginSelImageName = photoOriginSelImageName;
    _photoOriginSelImage = [UIImage tz_imageNamedFromMyBundle:photoOriginSelImageName];
}

- (void)setIconThemeColor:(UIColor *)iconThemeColor {
    _iconThemeColor = iconThemeColor;
    self.photoNumberIconImage = [self createImageWithColor:iconThemeColor size:CGSizeMake(24, 24) radius:12];
}

- (void)configDefaultBtnTitle {
    self.doneBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Done"];
    self.cancelBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Cancel"];
    self.previewBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Preview"];
    self.fullImageBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Full image"];
    self.settingBtnTitleStr = [NSBundle tz_localizedStringForKey:@"Setting"];
    self.processHintStr = [NSBundle tz_localizedStringForKey:@"Processing..."];
}

- (void)setShowSelectedIndex:(BOOL)showSelectedIndex {
    _showSelectedIndex = showSelectedIndex;
    if (showSelectedIndex) {
        self.photoSelImage = [self createImageWithColor:nil size:CGSizeMake(24, 24) radius:12];
    }
    [TZImagePickerConfig sharedInstance].showSelectedIndex = showSelectedIndex;
}

- (void)setShowPhotoCannotSelectLayer:(BOOL)showPhotoCannotSelectLayer {
    _showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
    [TZImagePickerConfig sharedInstance].showPhotoCannotSelectLayer = showPhotoCannotSelectLayer;
}

- (void)setNotScaleImage:(BOOL)notScaleImage {
    _notScaleImage = notScaleImage;
    [TZImagePickerConfig sharedInstance].notScaleImage = notScaleImage;
}

- (void)setNeedFixComposition:(BOOL)needFixComposition {
    _needFixComposition = needFixComposition;
    [TZImagePickerConfig sharedInstance].needFixComposition = needFixComposition;
}

- (void)observeAuthrizationStatusChange {
    [_timer invalidate];
    _timer = nil;
    if ([PHPhotoLibrary authorizationStatus] == 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(observeAuthrizationStatusChange) userInfo:nil repeats:NO];
    }
    
    if ([[TZImageManager manager] authorizationStatusAuthorized]) {
        [_tipLabel removeFromSuperview];
        [_settingBtn removeFromSuperview];
        
        [self pushPhotoPickerVc];
        
        TZAlbumPickerController *albumPickerVc = (TZAlbumPickerController *)self.visibleViewController;
        if ([albumPickerVc isKindOfClass:[TZAlbumPickerController class]]) {
            [albumPickerVc configTableView];
        }
    }
}

- (void)pushPhotoPickerVc {
    _didPushPhotoPickerVc = NO;
    // 1.6.8 判断是否需要push到照片选择页，如果_pushPhotoPickerVc为NO,则不push
    if (!_didPushPhotoPickerVc && _pushPhotoPickerVc) {
        TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
        photoPickerVc.isFirstAppear = YES;
        photoPickerVc.columnNumber = self.columnNumber;
        if (_mainColor) {
            photoPickerVc.mainColor = _mainColor;
        }
        [[TZImageManager manager] getCameraRollAlbum:self.allowPickingVideo allowPickingImage:self.allowPickingImage needFetchAssets:NO completion:^(TZAlbumModel *model) {
            photoPickerVc.model = model;
            [self pushViewController:photoPickerVc animated:YES];
            self->_didPushPhotoPickerVc = YES;
        }];
    }
}

- (UIAlertController *)showAlertWithTitle:(NSString *)title {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSBundle tz_localizedStringForKey:@"OK"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    return alertController;
}

- (void)hideAlertView:(UIAlertController *)alertView {
    [alertView dismissViewControllerAnimated:YES completion:nil];
    alertView = nil;
}

- (void)showProgressHUD {
    if (!_progressHUD) {
        _progressHUD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_progressHUD setBackgroundColor:[UIColor clearColor]];
        
        _HUDContainer = [[UIView alloc] init];
        _HUDContainer.layer.cornerRadius = 8;
        _HUDContainer.clipsToBounds = YES;
        _HUDContainer.backgroundColor = [UIColor darkGrayColor];
        _HUDContainer.alpha = 0.7;
        
        _HUDIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        _HUDLabel = [[UILabel alloc] init];
        _HUDLabel.textAlignment = NSTextAlignmentCenter;
        _HUDLabel.text = self.processHintStr;
        _HUDLabel.font = [UIFont systemFontOfSize:15];
        _HUDLabel.textColor = [UIColor whiteColor];
        
        [_HUDContainer addSubview:_HUDLabel];
        [_HUDContainer addSubview:_HUDIndicatorView];
        [_progressHUD addSubview:_HUDContainer];
    }
    [_HUDIndicatorView startAnimating];
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    [applicationWindow addSubview:_progressHUD];
    [self.view setNeedsLayout];
    
    // if over time, dismiss HUD automatic
    self.HUDTimeoutCount++;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.HUDTimeoutCount--;
        if (strongSelf.HUDTimeoutCount <= 0) {
            strongSelf.HUDTimeoutCount = 0;
            [strongSelf hideProgressHUD];
        }
    });
}
- (void)updateProgressInfo:(NSString*)progress {
    if ([[NSThread currentThread] isMainThread] == false) {
            dispatch_sync(dispatch_get_main_queue(), ^{
            if (_progressHUD == nil) {
               [self showProgressHUD];
            }
            _HUDLabel.text = progress;
        });
    } else {
        if (_progressHUD == nil) {
           [self showProgressHUD];
        }
        _HUDLabel.text = progress;
    }
}
- (void)hideProgressHUD {
    if (_progressHUD) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self->_HUDIndicatorView stopAnimating];
            [self->_progressHUD removeFromSuperview];
        });
    }
}

- (void)setMaxImagesCount:(NSInteger)maxImagesCount {
    _maxImagesCount = maxImagesCount;
    if (maxImagesCount > 1) {
        _showSelectBtn = YES;
        _allowCrop = NO;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    // 多选模式下，不允许让showSelectBtn为NO
    if (!showSelectBtn && _maxImagesCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setAllowCrop:(BOOL)allowCrop {
    _allowCrop = _maxImagesCount > 1 ? NO : allowCrop;
    if (allowCrop) { // 允许裁剪的时候，不能选原图和GIF
        self.allowPickingOriginalPhoto = NO;
        self.allowPickingGif = NO;
    }
}

- (void)setCircleCropRadius:(NSInteger)circleCropRadius {
    _circleCropRadius = circleCropRadius;
    self.cropRect = CGRectMake(self.view.tz_width / 2 - circleCropRadius, self.view.tz_height / 2 - _circleCropRadius, _circleCropRadius * 2, _circleCropRadius * 2);
}

- (void)setCropRect:(CGRect)cropRect {
    _cropRect = cropRect;
    _cropRectPortrait = cropRect;
    CGFloat widthHeight = cropRect.size.width;
    _cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, cropRect.origin.x, widthHeight, widthHeight);
}

- (CGRect)cropRect {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    BOOL isFullScreen = self.view.tz_height == screenHeight;
    if (isFullScreen) {
        return _cropRect;
    } else {
        CGRect newCropRect = _cropRect;
        newCropRect.origin.y -= ((screenHeight - self.view.tz_height) / 2);
        return newCropRect;
    }
}

- (void)setTimeout:(NSInteger)timeout {
    _timeout = timeout;
    if (timeout < 5) {
        _timeout = 5;
    } else if (_timeout > 60 * 3) {
        _timeout = 60 * 3;
    }
}

- (void)setPickerDelegate:(id<TZImagePickerControllerDelegate>)pickerDelegate {
    _pickerDelegate = pickerDelegate;
    [TZImageManager manager].pickerDelegate = pickerDelegate;
}

- (void)setColumnNumber:(NSInteger)columnNumber {
    _columnNumber = columnNumber;
    if (columnNumber <= 2) {
        _columnNumber = 2;
    } else if (columnNumber >= 6) {
        _columnNumber = 6;
    }
    
    TZAlbumPickerController *albumPickerVc = [self.childViewControllers firstObject];
    albumPickerVc.columnNumber = _columnNumber;
    [TZImageManager manager].columnNumber = _columnNumber;
}

- (void)setMinPhotoWidthSelectable:(NSInteger)minPhotoWidthSelectable {
    _minPhotoWidthSelectable = minPhotoWidthSelectable;
    [TZImageManager manager].minPhotoWidthSelectable = minPhotoWidthSelectable;
}

- (void)setMinPhotoHeightSelectable:(NSInteger)minPhotoHeightSelectable {
    _minPhotoHeightSelectable = minPhotoHeightSelectable;
    [TZImageManager manager].minPhotoHeightSelectable = minPhotoHeightSelectable;
}

- (void)setHideWhenCanNotSelect:(BOOL)hideWhenCanNotSelect {
    _hideWhenCanNotSelect = hideWhenCanNotSelect;
    [TZImageManager manager].hideWhenCanNotSelect = hideWhenCanNotSelect;
}

- (void)setPhotoPreviewMaxWidth:(CGFloat)photoPreviewMaxWidth {
    _photoPreviewMaxWidth = photoPreviewMaxWidth;
    if (photoPreviewMaxWidth > 800) {
        _photoPreviewMaxWidth = 800;
    } else if (photoPreviewMaxWidth < 500) {
        _photoPreviewMaxWidth = 500;
    }
    [TZImageManager manager].photoPreviewMaxWidth = _photoPreviewMaxWidth;
}

- (void)setPhotoWidth:(CGFloat)photoWidth {
    _photoWidth = photoWidth;
    [TZImageManager manager].photoWidth = photoWidth;
}

- (void)setSelectedAssets:(NSMutableArray *)selectedAssets {
    _selectedAssets = selectedAssets;
    _selectedModels = [NSMutableArray array];
    _selectedAssetIds = [NSMutableArray array];
    for (PHAsset *asset in selectedAssets) {
        TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:[[TZImageManager manager] getAssetType:asset]];
        model.isSelected = YES;
        [self addSelectedModel:model];
    }
}

- (void)setAllowPickingImage:(BOOL)allowPickingImage {
    _allowPickingImage = allowPickingImage;
    [TZImagePickerConfig sharedInstance].allowPickingImage = allowPickingImage;
    //    if (!allowPickingImage) {
    //        _allowTakePicture = NO;
    //    }
}

- (void)setAllowPickingVideo:(BOOL)allowPickingVideo {
    _allowPickingVideo = allowPickingVideo;
    [TZImagePickerConfig sharedInstance].allowPickingVideo = allowPickingVideo;
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    [TZImagePickerConfig sharedInstance].preferredLanguage = preferredLanguage;
    [self configDefaultBtnTitle];
}

- (void)setLanguageBundle:(NSBundle *)languageBundle {
    _languageBundle = languageBundle;
    [TZImagePickerConfig sharedInstance].languageBundle = languageBundle;
    [self configDefaultBtnTitle];
}

- (void)setSortAscendingByModificationDate:(BOOL)sortAscendingByModificationDate {
    _sortAscendingByModificationDate = sortAscendingByModificationDate;
    [TZImageManager manager].sortAscendingByModificationDate = sortAscendingByModificationDate;
}

- (void)settingBtnClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.automaticallyAdjustsScrollViewInsets = NO;
    [super pushViewController:viewController animated:animated];
}

- (void)dealloc {
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (void)addSelectedModel:(TZAssetModel *)model {
    [_selectedModels addObject:model];
    [_selectedAssetIds addObject:model.asset.localIdentifier];
}

- (void)removeSelectedModel:(TZAssetModel *)model {
    [_selectedModels removeObject:model];
    [_selectedAssetIds removeObject:model.asset.localIdentifier];
}

- (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius {
    if (!color) {
        color = self.iconThemeColor;
    }
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CGContextAddPath(context, path.CGPath);
    CGContextFillPath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![UIApplication sharedApplication].statusBarHidden) {
            if (self.needShowStatusBar) [UIApplication sharedApplication].statusBarHidden = NO;
        }
    });
    if (size.width > size.height) {
        _cropRect = _cropRectLandscape;
    } else {
        _cropRect = _cropRectPortrait;
    }
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat progressHUDY = CGRectGetMaxY(self.navigationBar.frame);
    _progressHUD.frame = CGRectMake(0, progressHUDY, self.view.tz_width, self.view.tz_height - progressHUDY);
    _HUDContainer.frame = CGRectMake((self.view.tz_width - 120) / 2, (_progressHUD.tz_height - 90 - progressHUDY) / 2, 120, 90);
    _HUDIndicatorView.frame = CGRectMake(45, 15, 30, 30);
    _HUDLabel.frame = CGRectMake(0,40, 120, 50);
}

#pragma mark - Public

- (void)cancelButtonClick {
    if (self.autoDismiss) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self callDelegateMethod];
        }];
    } else {
        [self callDelegateMethod];
    }
}

- (void)callDelegateMethod {
    if ([self.pickerDelegate respondsToSelector:@selector(tz_imagePickerControllerDidCancel:)]) {
        [self.pickerDelegate tz_imagePickerControllerDidCancel:self];
    }
    if (self.imagePickerControllerDidCancelHandle) {
        self.imagePickerControllerDidCancelHandle();
    }
}

@end


@interface TZAlbumPickerController ()<UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver> {
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation TZAlbumPickerController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.isFirstAppear = YES;
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
    [TZCommonTools configBarButtonItem:cancelItem tzImagePickerVc:imagePickerVc];
    self.navigationItem.rightBarButtonItem = cancelItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"select_album"];
    [self configTableView];
}

- (void)configTableView {
    if (![[TZImageManager manager] authorizationStatusAuthorized]) {
        return;
    }
    
    if (self.isFirstAppear) {
        TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
        [imagePickerVc showProgressHUD];
    }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[TZImageManager manager] getAllAlbums:imagePickerVc.allowPickingVideo allowPickingImage:imagePickerVc.allowPickingImage needFetchAssets:!self.isFirstAppear completion:^(NSArray<TZAlbumModel *> *models) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_albumArr = [NSMutableArray arrayWithArray:models];
                for (TZAlbumModel *albumModel in self->_albumArr) {
                    albumModel.selectedModels = imagePickerVc.selectedModels;
                }
                [imagePickerVc hideProgressHUD];
                
                if (self.isFirstAppear) {
                    self.isFirstAppear = NO;
                    [self configTableView];
                }
                
                if (!self->_tableView) {
                    self->_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
                    self->_tableView.rowHeight = 70;
                    if (@available(iOS 13.0, *)) {
                        self->_tableView.backgroundColor = [UIColor tertiarySystemBackgroundColor];
                    } else {
                        self->_tableView.backgroundColor = [UIColor whiteColor];
                    }
                    self->_tableView.tableFooterView = [[UIView alloc] init];
                    self->_tableView.dataSource = self;
                    self->_tableView.delegate = self;
                    [self->_tableView registerClass:[TZAlbumCell class] forCellReuseIdentifier:@"TZAlbumCell"];
                    [self.view addSubview:self->_tableView];
                    if (imagePickerVc.albumPickerPageUIConfigBlock) {
                        imagePickerVc.albumPickerPageUIConfigBlock(self->_tableView);
                    }
                } else {
                    [self->_tableView reloadData];
                }
            });
        }];
    });
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    // NSLog(@"%@ dealloc",NSStringFromClass(self.class));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    TZImagePickerController *tzImagePicker = (TZImagePickerController *)self.navigationController;
    if (tzImagePicker && [tzImagePicker isKindOfClass:[TZImagePickerController class]]) {
        return tzImagePicker.statusBarStyle;
    }
    return [super preferredStatusBarStyle];
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configTableView];
    });
}

#pragma mark - Layout

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat top = 0;
    CGFloat tableViewHeight = 0;
    CGFloat naviBarHeight = self.navigationController.navigationBar.tz_height;
    BOOL isStatusBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
    BOOL isFullScreen = self.view.tz_height == [UIScreen mainScreen].bounds.size.height;
    if (self.navigationController.navigationBar.isTranslucent) {
        top = naviBarHeight;
        if (!isStatusBarHidden && isFullScreen) top += [TZCommonTools tz_statusBarHeight];
        tableViewHeight = self.view.tz_height - top;
    } else {
        tableViewHeight = self.view.tz_height;
    }
    _tableView.frame = CGRectMake(0, top, self.view.tz_width, tableViewHeight);
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    if (imagePickerVc.albumPickerPageDidLayoutSubviewsBlock) {
        imagePickerVc.albumPickerPageDidLayoutSubviewsBlock(_tableView);
    }
}

#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TZAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TZAlbumCell"];
    if (@available(iOS 13.0, *)) {
        cell.backgroundColor = UIColor.tertiarySystemBackgroundColor;
    }
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    cell.albumCellDidLayoutSubviewsBlock = imagePickerVc.albumCellDidLayoutSubviewsBlock;
    cell.albumCellDidSetModelBlock = imagePickerVc.albumCellDidSetModelBlock;
    cell.selectedCountButton.backgroundColor = imagePickerVc.iconThemeColor;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TZPhotoPickerController *photoPickerVc = [[TZPhotoPickerController alloc] init];
    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.navigationController;
    photoPickerVc.columnNumber = self.columnNumber;
    TZAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    photoPickerVc.mainColor = self.mainColor;
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma clang diagnostic pop

@end


@implementation UIImage (MyBundle)

+ (UIImage *)tz_imageNamedFromMyBundle:(NSString *)name {
    NSBundle *imageBundle = [NSBundle tz_imagePickerBundle];
    name = [name stringByAppendingString:@"@2x"];
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    if (!image) {
        // 兼容业务方自己设置图片的方式
        name = [name stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        image = [UIImage imageNamed:name];
    }
    return image;
}

@end


@implementation TZCommonTools
/// iPhoneX系列判断
+ (BOOL)tz_isIPhoneX {
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        // 获取安全区域
        UIEdgeInsets safeAreaInsets = window.safeAreaInsets;
        
        // 判断顶部和底部安全区域是否大于零
        if (safeAreaInsets.top > 0 || safeAreaInsets.bottom > 0) {
            return YES;
        }
    }
    return NO;
}

+ (CGFloat)tz_statusBarHeight {
    return [self tz_isIPhoneX] ? 44 : 20;
}

// 获得Info.plist数据字典
+ (NSDictionary *)tz_getInfoDictionary {
    NSDictionary *infoDict = [NSBundle mainBundle].localizedInfoDictionary;
    if (!infoDict || !infoDict.count) {
        infoDict = [NSBundle mainBundle].infoDictionary;
    }
    if (!infoDict || !infoDict.count) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return infoDict ? infoDict : @{};
}

+ (BOOL)tz_isRightToLeftLayout {
    if (@available(iOS 9.0, *)) {
        if ([UIView userInterfaceLayoutDirectionForSemanticContentAttribute:UISemanticContentAttributeUnspecified] == UIUserInterfaceLayoutDirectionRightToLeft) {
            return YES;
        }
    } else {
        NSString *preferredLanguage = [NSLocale preferredLanguages].firstObject;
        if ([preferredLanguage hasPrefix:@"ar-"]) {
            return YES;
        }
    }
    return NO;
}

+ (void)configBarButtonItem:(UIBarButtonItem *)item tzImagePickerVc:(TZImagePickerController *)tzImagePickerVc {
    item.tintColor = tzImagePickerVc.barItemTextColor;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = tzImagePickerVc.barItemTextColor;
    textAttrs[NSFontAttributeName] = tzImagePickerVc.barItemTextFont;
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
}

+ (BOOL)isICloudSyncError:(NSError *)error {
    if (!error) return NO;
    if ([error.domain isEqualToString:@"CKErrorDomain"] || [error.domain isEqualToString:@"CloudPhotoLibraryErrorDomain"]) {
        return YES;
    }
    return NO;
}

@end


@implementation TZImagePickerConfig

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static TZImagePickerConfig *config = nil;
    dispatch_once(&onceToken, ^{
        if (config == nil) {
            config = [[TZImagePickerConfig alloc] init];
            config.preferredLanguage = nil;
            config.gifPreviewMaxImagesCount = 50;
        }
    });
    return config;
}

- (void)setPreferredLanguage:(NSString *)preferredLanguage {
    _preferredLanguage = preferredLanguage;
    
    if (!preferredLanguage || !preferredLanguage.length) {
        preferredLanguage = [NSLocale preferredLanguages].firstObject;
    }
    if ([preferredLanguage rangeOfString:@"zh-Hans"].location != NSNotFound) {
        preferredLanguage = @"zh-Hans";
    } else if ([preferredLanguage rangeOfString:@"zh-Hant"].location != NSNotFound) {
        preferredLanguage = @"zh-Hant";
    } else if ([preferredLanguage rangeOfString:@"vi"].location != NSNotFound) {
        preferredLanguage = @"vi";
    } else {
        preferredLanguage = @"en";
    }
    _languageBundle = [NSBundle bundleWithPath:[[NSBundle tz_imagePickerBundle] pathForResource:preferredLanguage ofType:@"lproj"]];
}

@end

// MARK: - 自定义颜色
@implementation TZCutomColor

+ (UIColor*)whiteColor {
    if (@available(iOS 13.0, *)) {
       return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.blackColor;
            } else {
                return UIColor.whiteColor;
            }
        }];
    } else {
        return UIColor.whiteColor;
    }
}

+ (UIColor*)blackColor {
    if (@available(iOS 13.0, *)) {
       return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.whiteColor;
            } else {
                return UIColor.blackColor;
            }
        }];
    } else {
        return UIColor.blackColor;
    }
}

+ (UIColor*)toobarColor {
    CGFloat rgb = 253 / 255.0;
    UIColor* aColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    if (@available(iOS 13.0, *)) {
       return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor colorWithWhite:0.15 alpha:0.9];
            } else {
                return aColor;
            }
        }];
    } else {
        return aColor;
    }
}

+ (UIColor*)lightGrayColor {
    if (@available(iOS 13.0, *)) {
       return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.whiteColor;
            } else {
                return UIColor.lightGrayColor;
            }
        }];
    } else {
        return UIColor.lightGrayColor;
    }
}

+ (UIColor*)grayColor {
    if (@available(iOS 13.0, *)) {
       return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return UIColor.lightGrayColor;
            } else {
                return UIColor.grayColor;
            }
        }];
    } else {
        return UIColor.grayColor;
    }
}


@end
