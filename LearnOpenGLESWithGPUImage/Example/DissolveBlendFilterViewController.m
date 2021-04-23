//
//  DissolveBlendFilterViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/16.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "DissolveBlendFilterViewController.h"
#import "GPUImage.h"
#import <Photos/Photos.h>

@interface DissolveBlendFilterViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    GPUImageVideoCamera *videoCamera;
}

@property (nonatomic , strong) UILabel  *mLabel;

@end

@implementation DissolveBlendFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"混合滤镜";
    
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    filterView.center = self.view.center;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:filterView];
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    filter = [[GPUImageDissolveBlendFilter alloc] init];
    //设置滤镜混合度
    [(GPUImageDissolveBlendFilter *)filter setMix:0.5];
    
    // 播放
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"IMG_4278" withExtension:@"MOV"];
    //视频输出源头
    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    //摄像头输出源头
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    //初始化接受者
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];

    //初始化 显示接受者
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [movieFile addTarget:progressFilter];
    //设置输出方向
    [progressFilter setInputRotation:kGPUImageRotateRight atIndex:0];
    //设置音源是否使用视频文件的
    BOOL audioFromFile = YES;
    // 响应链
    [progressFilter addTarget:filter];
    [videoCamera addTarget:filter];
    //设置音源
    if(audioFromFile){
        movieWriter.shouldPassthroughAudio = YES;
        movieFile.audioEncodingTarget = movieWriter;
        [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    }else{
        movieWriter.shouldPassthroughAudio = NO;
        videoCamera.audioEncodingTarget = movieWriter;
        movieWriter.encodingLiveVideo = NO;
    }
    // 显示到界面
    [filter addTarget:filterView];
    //添加接受者
    [filter addTarget:movieWriter];
    
    [videoCamera startCameraCapture];
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
    [movieWriter setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->movieWriter];
        [strongSelf->movieWriter finishRecording];
        
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            //写入图片到相册,拿到的图片是filter处理后的
           [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            NSLog(@"success==%d, error ===%@",success,error);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVc addAction:sureAction];
                [strongSelf presentViewController:alertVc animated:YES completion:nil];
            });
        }];
    }];
}

- (void)updateProgress
{
    self.mLabel.text = [NSString stringWithFormat:@"Progress:%d%%", (int)(movieFile.progress * 100)];
    [self.mLabel sizeToFit];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
