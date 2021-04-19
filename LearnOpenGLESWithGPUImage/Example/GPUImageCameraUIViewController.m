//
//  GPUImageCrameUIViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/14.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "GPUImageCameraUIViewController.h"
#import <GPUImage.h>

@interface GPUImageCameraUIViewController ()
@property (nonatomic, strong) GPUImageVideoCamera *gpuVideoCamera;
@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (weak, nonatomic) IBOutlet UIButton *originalBtn;

@end

@implementation GPUImageCameraUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Camera输入滤镜";
    self.view.backgroundColor = [UIColor whiteColor];
    self.gpuImageView.frame = self.view.frame;

    [self setupCamera];
}
- (void)setupCamera
{
    //videoCamera
    self.gpuVideoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    self.gpuVideoCamera.outputImageOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    //GPUImageView填充模式
    self.gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    //空白效果
    GPUImageFilter *clearFilter = [[GPUImageFilter alloc] init];
    [self.gpuVideoCamera addTarget:clearFilter];
    [clearFilter addTarget:self.gpuImageView];
    
    //Start camera capturing, 里面封装的是AVFoundation的session的startRunning
    [self.gpuVideoCamera startCameraCapture];
    
    //屏幕方向的检测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Action && Notification

- (IBAction)originalBtnDown:(id)sender {
    /**先移除target*/
    [self.gpuVideoCamera removeAllTargets];
    //空白效果
    GPUImageFilter *clearFilter = [[GPUImageFilter alloc] init];
    [self.gpuVideoCamera addTarget:clearFilter];
    [clearFilter addTarget:self.gpuImageView];
}
- (IBAction)filterOneBtnDown:(id)sender {
    [self.gpuVideoCamera removeAllTargets];
    /**复古效果滤镜*/
    GPUImageSepiaFilter *filter = [[GPUImageSepiaFilter alloc] init];
    [self.gpuVideoCamera addTarget:filter];
    [filter addTarget:self.gpuImageView];
}
- (IBAction)filterTwoBtnDown:(id)sender {
    [self.gpuVideoCamera removeAllTargets];
    GPUImageGaussianBlurFilter *filter = [[GPUImageGaussianBlurFilter alloc] init];
    filter.blurRadiusInPixels = 10;
    [self.gpuVideoCamera addTarget:filter];
    [filter addTarget:self.gpuImageView];
}
- (IBAction)filterThreeBtnDown:(id)sender {
    [self.gpuVideoCamera removeAllTargets];
    GPUImageSketchFilter *filter = [[GPUImageSketchFilter alloc] init];
    [self.gpuVideoCamera addTarget:filter];
    [filter addTarget:self.gpuImageView];
}
- (IBAction)filterFourBtnDown:(id)sender {
    [self.gpuVideoCamera removeAllTargets];
    GPUImageEmbossFilter *filter = [[GPUImageEmbossFilter alloc] init];
    [self.gpuVideoCamera addTarget:filter];
    [filter addTarget:self.gpuImageView];
}

- (void)orientationDidChange:(NSNotification *)noti
{
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    self.gpuVideoCamera.outputImageOrientation = orientation;
    self.gpuImageView.frame = self.view.frame;
}

@end
