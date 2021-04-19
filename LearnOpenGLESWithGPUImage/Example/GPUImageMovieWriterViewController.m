//
//  GPUImageMovieWriterViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/16.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "GPUImageMovieWriterViewController.h"
#import "GPUImage.h"
#import "LFGPUImageBeautyFilter.h"
#import <Photos/Photos.h>

@interface GPUImageMovieWriterViewController ()

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) NSURL *movieURL;
@property (nonatomic, strong) LFGPUImageBeautyFilter *beautifyFilter;//设置滤镜

@end

@implementation GPUImageMovieWriterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MoiveWriter使用";
    self.view.backgroundColor = [UIColor blackColor];
    //创建输入源
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    //输出源
    self.filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView.backgroundColor = [UIColor blackColor];
    self.filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:self.filterView];
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    self.movieURL = [NSURL fileURLWithPath:pathToMovie];
    //另一个输出源
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:self.movieURL size:CGSizeMake(480, 640)];
    self.videoCamera.audioEncodingTarget = _movieWriter;
    [self.videoCamera addAudioInputsAndOutputs];
    
    _movieWriter.encodingLiveVideo = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.videoCamera startCameraCapture];
    });
    //设置滤镜
    self.beautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
    [self.videoCamera addTarget:self.beautifyFilter];
    //处理后的滤镜添加到输出源
    [self.beautifyFilter addTarget:self.filterView];
    [self.beautifyFilter addTarget:_movieWriter];
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view sendSubviewToBack:self.filterView];
}
#pragma mark - Action

- (IBAction)sliderChange:(id)sender {
    UISlider *slider = (UISlider*)sender;
    self.beautifyFilter.beautyLevel = slider.value;
}
- (IBAction)startBtnDown:(id)sender {
    NSLog(@"开始了...");
    //开始记录
    [_movieWriter startRecording];
}
- (IBAction)stopBtnDown:(id)sender {
    NSLog(@"结束了...");
    [self.beautifyFilter removeTarget:_movieWriter];
    [_movieWriter finishRecording];
    
    [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
        //写入视频到相册,拿到的图片是filter处理后的
       [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:self.movieURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(success){
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVc addAction:sureAction];
                [self presentViewController:alertVc animated:YES completion:nil];
            }
        });
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
