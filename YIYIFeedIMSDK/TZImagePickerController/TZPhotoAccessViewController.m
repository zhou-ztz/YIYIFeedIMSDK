//
//  TZPhotoAccessViewController.m
//  TZImagePickerController
//
//  Created by yiyikeji on 2025/2/8.
//

#import "TZPhotoAccessViewController.h"
#import "TZImagePickerController.h"
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
@interface TZPhotoAccessViewController ()

@property(nonatomic,strong) UIView *sheetView;

@end

@implementation TZPhotoAccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self setupUI];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
     [self.view addGestureRecognizer:tapGesture];
    
}

// 设置 UI
- (void)setupUI {
    CGFloat sheetHeight = 250;
    self.sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - sheetHeight, self.view.bounds.size.width, sheetHeight)];
    self.sheetView.backgroundColor = [UIColor blackColor];
    self.sheetView.layer.cornerRadius = 12;
    [self.view addSubview:self.sheetView];

    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.sheetView.frame.size.width, 25)];
    titleLabel.text = [NSBundle tz_localizedStringForKey:@"video_limited_pop_title"];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.sheetView addSubview:titleLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage tz_imageNamedFromMyBundle:@"photo_limited_close"];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(self.sheetView.frame.size.width - 40, 20, 30, 30);
    [self.sheetView addSubview:closeButton];
    [closeButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    
    // “Select more photos” 按钮
    UIButton *selectMorePhotosButton = [self createButtonWithTitle:[NSBundle tz_localizedStringForKey:@"video_limited_pop_more_photo"]
                                                             action:@selector(selectMorePhotosTapped)];
    selectMorePhotosButton.frame = CGRectMake(20, 70, self.sheetView.frame.size.width - 40, 50);
    UIBezierPath *selectMoreMaskPath = [UIBezierPath bezierPathWithRoundedRect:selectMorePhotosButton.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(20.0, 20.0)];

    CAShapeLayer *selectMoreMaskLayer = [[CAShapeLayer alloc] init];
    selectMoreMaskLayer.frame = selectMorePhotosButton.bounds;
    selectMoreMaskLayer.path = selectMoreMaskPath.CGPath;
    selectMorePhotosButton.layer.mask = selectMoreMaskLayer;
    
    [self.sheetView addSubview:selectMorePhotosButton];

    // “Change settings” 按钮
    UIButton *changeSettingsButton = [self createButtonWithTitle:[NSBundle tz_localizedStringForKey:@"video_limited_pop_change_settings"]
                                                           action:@selector(changeSettingsTapped)];
    changeSettingsButton.frame = CGRectMake(20, 121, self.sheetView.frame.size.width - 40, 50);
    
    
    
    
    UIBezierPath *changeSettingsMaskPath = [UIBezierPath bezierPathWithRoundedRect:changeSettingsButton.bounds
                                                   byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(20.0, 20.0)];

    CAShapeLayer *changeSettingsMaskLayer = [[CAShapeLayer alloc] init];
    changeSettingsMaskLayer.frame = changeSettingsButton.bounds;
    changeSettingsMaskLayer.path = changeSettingsMaskPath.CGPath;
    changeSettingsButton.layer.mask = changeSettingsMaskLayer;
    
    [self.sheetView addSubview:changeSettingsButton];

//    // 取消按钮
//    UIButton *cancelButton = [self createButtonWithTitle:@"Cancel"
//                                                  action:@selector(dismissViewController)];
//    cancelButton.frame = CGRectMake(20, 140, sheetView.frame.size.width - 40, 44);
//    [sheetView addSubview:cancelButton];
}

// 创建按钮
- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor = [UIColor darkGrayColor];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

// 处理 "Select more photos" 逻辑
- (void)selectMorePhotosTapped {
    if (@available(iOS 15, *)) {
        __weak typeof(self) weakSelf = self;
        [[PHPhotoLibrary sharedPhotoLibrary] presentLimitedLibraryPickerFromViewController:self completionHandler:^(NSArray<NSString *> * assetIdentifiers) {
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewController];
            });
          
        }];
    }
}

// 打开 App 设置
- (void)changeSettingsTapped {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
        }
    }
}

// 关闭弹窗
- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.view];
    if (!CGRectContainsPoint(self.sheetView.frame, location)) {
        [self dismissViewController];
    }
}
@end
