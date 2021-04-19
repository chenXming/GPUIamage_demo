//
//  GPUImageFliterGroupViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/14.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "GPUImageFliterGroupViewController.h"
#import <GPUImage.h>
#import <Photos/Photos.h>

@interface GPUImageFliterGroupViewController ()
@property (weak, nonatomic)  IBOutlet UIButton   *catchBtn;
@property (nonatomic,strong) GPUImageStillCamera *stillCamera;
@property (nonatomic,strong) GPUImageFilter      *lastFilter;
@end

@implementation GPUImageFliterGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"滤镜组";
    
    self.view.backgroundColor = [UIColor blackColor];
    //创建摄像头视图
    GPUImageView *filterView = [[GPUImageView alloc]initWithFrame:self.view.bounds];
    //显示模式充满整个边框
    filterView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.view addSubview:filterView];

    self.stillCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
     //输出图像旋转方式
    self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

    //反色滤镜
    GPUImageColorInvertFilter *filter1 = [[GPUImageColorInvertFilter alloc]init];
    //浮雕滤镜
    GPUImageEmbossFilter *filter2 = [[GPUImageEmbossFilter alloc]init];
   // GPUImageToonFilter *filter3 = [[GPUImageToonFilter alloc] init];
    GPUImageFilterGroup *groupFilter = [[GPUImageFilterGroup alloc]init];

    [groupFilter addFilter:filter1];
    [groupFilter addFilter:filter2];
//    [groupFilter addFilter:filter3];
    
    [filter1 addTarget:filter2];
//    [filter2 addTarget:filter3];
    
    //定义了一个变量来保存filter-chain上的最后一个filter,后面保存图片时调用的方法里要用到。
    self.lastFilter = filter2;
    //设置第一个滤镜
    groupFilter.initialFilters = @[filter1];
    //设置最后一个滤镜
    groupFilter.terminalFilter = filter2;

    [self.stillCamera addTarget:groupFilter];
    [groupFilter addTarget:filterView];
    //解决第一帧黑屏,音频缓冲区是在视频缓冲区之前写入的。
    [self.stillCamera addAudioInputsAndOutputs];
    [self.view bringSubviewToFront:self.catchBtn];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //开始捕捉
        [self.stillCamera startCameraCapture];
    });

}
- (IBAction)catchBtnDown:(id)sender {
        
    [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.lastFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            //写入图片到相册,拿到的图片是filter处理后的
           [PHAssetChangeRequest creationRequestForAssetFromImage:processedImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alertVc addAction:sureAction];
                [self presentViewController:alertVc animated:YES completion:nil];
            });
           
        }];
    }];
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
