//
//  ZLEditVideoController.h
//  ZLPhotoBrowser
//
//  Created by long on 2017/9/15.
//  Copyright © 2017年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ZLEditVideoController : UIViewController

@property (nonatomic, strong) PHAsset *asset;
/// 整个项目主题色
@property (nonatomic, copy) UIColor *mainColor;
/// 整个项目的返回按钮图片
@property(nonatomic,strong)UIImage *backImage;
///封面回调
@property (nonatomic, copy) void (^coverImageBlock)(UIImage *coverImage, NSURL *videoPath);
/// 最大裁剪视频时长(秒) 默认10秒
@property (nonatomic) NSUInteger maxEditVideoTime;
/// 最小可选视频时长(秒) 默认3秒
@property (nonatomic) NSUInteger minEditVideoTime;
/// 导出视频
- (void)export:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(NSString *exportFilePath, NSError *error))complete;

@end

@interface ZLVideoExportTool : NSObject

/// 更新导出进度的timer
@property (nonatomic, strong) NSTimer* updateExpProgressTimer;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, copy) void(^progressHandeler)(float progress);

- (void)export:(AVAsset *)asset range:(CMTimeRange)range complete:(void (^)(NSString *exportFilePath, NSError *error))complete;

@end
