//
//  UIElementViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/16.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "UIElementViewController.h"
#import "GPUImage.h"
#import <Photos/Photos.h>

@interface UIElementViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@property (nonatomic , strong) UILabel  *mLabel;

@end

@implementation UIElementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"水印";
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.view = filterView;
    
    self.mLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 100, 100)];
    self.mLabel.textColor = [UIColor redColor];
    [self.view addSubview:self.mLabel];
    
    // 滤镜
    filter = [[GPUImageDissolveBlendFilter alloc] init];
    //混合度
    [(GPUImageDissolveBlendFilter *)filter setMix:0.5];
   
    // 播放
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"IMG_4278" withExtension:@"MOV"];
    AVAsset *asset = [AVAsset assetWithURL:sampleURL];
    CGSize size = self.view.bounds.size;
    //设置moive源头
    movieFile = [[GPUImageMovie alloc] initWithAsset:asset];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    
    // 水印
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    label.text = @"我是水印";
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor redColor];
    [label sizeToFit];
    UIImage *image = [UIImage imageNamed:@"watermark.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    imageView.center = CGPointMake(subView.bounds.size.width / 2, subView.bounds.size.height / 2);
    [subView addSubview:imageView];
    [subView addSubview:label];
    //设置UI源头
    GPUImageUIElement *uielement = [[GPUImageUIElement alloc] initWithView:subView];
//    GPUImageTransformFilter 动画的filter
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    //为调整视频方向添加一个空白滤镜
    GPUImageFilter* progressFilter = [[GPUImageFilter alloc] init];
    [movieFile addTarget:progressFilter];
    //设置输出方向
    [progressFilter setInputRotation:kGPUImageRotateRight atIndex:0];
    
    [progressFilter addTarget:filter];
    [uielement addTarget:filter];
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    // 显示到界面
    [filter addTarget:filterView];
    [filter addTarget:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    CADisplayLink* dlink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
    [dlink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [dlink setPaused:NO];
    
    __weak typeof(self) weakSelf = self;
//    __block NSInteger count = 0;
    //每一帧处理完成 大约30帧/秒
    [progressFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//        NSLog(@"second===%lld",time.value/time.timescale);
//        NSLog(@"count===%ld",count++);
        CGRect frame = imageView.frame;
        frame.origin.x += 1;
        frame.origin.y += 1;
        imageView.frame = frame;
        //更新UIElement
        [uielement updateWithTimestamp:time];
    }];
    
    [movieWriter setCompletionBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->movieWriter];
        [strongSelf->movieWriter finishRecording];
        
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            //写入图片到相册,拿到的视频是filter处理后的
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
//判断视频方向
- (NSInteger)getRotionWithPath:(NSURL*)path{
    
    AVAsset *ass  = [AVAsset assetWithURL:path];
    NSInteger degress = 90;
    
    NSArray *tracks = [ass tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count]>0){
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
                // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    return degress;
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
