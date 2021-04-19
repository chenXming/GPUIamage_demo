//
//  GUPImagePictureViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/13.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "GUPImagePictureViewController.h"
#import <GPUImage.h>

@interface GUPImagePictureViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *showImageView;
@property (weak, nonatomic) IBOutlet UIButton *originalBtn;
@property (weak, nonatomic) IBOutlet UIButton *gaussianBtn;
@property (weak, nonatomic) IBOutlet UIButton *classicsBtn;
@property (weak, nonatomic) IBOutlet UIButton *sketchBtn;

@end

@implementation GUPImagePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"图片滤镜";
    self.showImageView.image = [UIImage imageNamed:@"picOne.jpg"];
}

- (IBAction)originalBtnDown:(id)sender {
    self.showImageView.image = [UIImage imageNamed:@"picOne.jpg"];
}
- (IBAction)gaussianBtnDown:(id)sender {
    /**初始化滤镜源头*/
    GPUImagePicture *imagePic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"picOne.jpg"]];
    /**创建滤镜*/
    GPUImageGaussianBlurFilter *gaussianBlur = [[GPUImageGaussianBlurFilter alloc] init];
    gaussianBlur.blurRadiusInPixels = 10;
    /**添加接受者，即target*/
    [imagePic addTarget:gaussianBlur];
    /**增加frameBUffer 计数防止被移除*/
    [gaussianBlur useNextFrameForImageCapture];
    /**开始处理图片*/
    [imagePic processImage];
    /**根据frameBuffer 获取图片*/
    self.showImageView.image = [gaussianBlur imageFromCurrentFramebuffer];
}
- (IBAction)classicsBtnDown:(id)sender {
 
    GPUImageSepiaFilter *sepiaBlur = [[GPUImageSepiaFilter alloc] init];
    /**根据frameBuffer 获取图片*/
    self.showImageView.image = [self getImageWithFilter:sepiaBlur];
}
- (IBAction)sketchBtnDown:(id)sender {
  
    GPUImageSketchFilter *sketchBlur = [[GPUImageSketchFilter alloc] init];
    /**根据frameBuffer 获取图片*/
    self.showImageView.image = [self getImageWithFilter:sketchBlur];
}
- (IBAction)toonBtnDown:(id)sender {
   
    GPUImageEmbossFilter *embossBlur = [[GPUImageEmbossFilter alloc] init];
    /**根据frameBuffer 获取图片*/
    self.showImageView.image = [self getImageWithFilter:embossBlur];

}
- (UIImage*)getImageWithFilter:(GPUImageFilter*)fliter{
    
    /**初始化滤镜源头*/
    GPUImagePicture *imagePic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"picOne.jpg"]];
    /**创建滤镜*/
    /**添加接受者，即target*/
    [imagePic addTarget:fliter];
    /**增加frameBUffer 计数防止被移除*/
    [fliter useNextFrameForImageCapture];
    /**开始处理图片*/
    [imagePic processImage];
    /**根据frameBuffer 获取图片*/
    return  [fliter imageFromCurrentFramebuffer];
}
- (void)dealloc{
    //释放帧缓存内存
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
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
