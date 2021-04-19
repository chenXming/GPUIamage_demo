//
//  CustomFilterViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by 陈小明 on 2021/4/18.
//  Copyright © 2021 陈小明. All rights reserved.
//

#import "CustomFilterViewController.h"
#import "GPUImage.h"

#import "SCGPUImageScaleFilter.h"
#import "SCGPUImageSoulOutFilter.h"
#import "SCGPUImageShakeFilter.h"
#import "SCGPUImageGlitchFilter.h"
#import "SCGPUImageVertigoFilter.h"
#import "SCGPUImageShineWhiteFilter.h"

@interface CustomFilterViewController ()

@property (weak, nonatomic) IBOutlet GPUImageView *gpuImageView;
@property (nonatomic, strong) CADisplayLink   *displayLink;  // 用来刷新时间
@property (nonatomic, weak)   GPUImageFilter  *currentEffectFilter;
@property (nonatomic, strong) GPUImagePicture *imagePic;

@end

@implementation CustomFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"自定义滤镜";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupDisplayLink];
}

- (void)setupDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                   selector:@selector(displayAction)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Action

- (IBAction)noneBtnDown:(id)sender {
    GPUImageFilter *filter = [[GPUImageFilter alloc] init];
    [self setImageWithFilter:filter];
}
- (IBAction)scaleBtnDown:(id)sender {
    SCGPUImageScaleFilter *customFilter = [[SCGPUImageScaleFilter alloc] init];
    [self setImageWithFilter:customFilter];
}
- (IBAction)soulOutBtnDown:(id)sender {
    SCGPUImageSoulOutFilter *customFilter = [[SCGPUImageSoulOutFilter alloc] init];
    [self setImageWithFilter:customFilter];
}
- (IBAction)shineWhiteBtnDown:(id)sender {
    SCGPUImageShineWhiteFilter *customFilter = [[SCGPUImageShineWhiteFilter alloc] init];
    [self setImageWithFilter:customFilter];
}
- (IBAction)glitchBtnDown:(id)sender {
    SCGPUImageGlitchFilter *customFilter = [[SCGPUImageGlitchFilter alloc] init];
    [self setImageWithFilter:customFilter];
}
- (IBAction)shakeBtnDown:(id)sender {
    SCGPUImageShakeFilter *customFilter = [[SCGPUImageShakeFilter alloc] init];
    [self setImageWithFilter:customFilter];
}
- (IBAction)vertigoBtnDown:(id)sender {
    SCGPUImageVertigoFilter *customFilter = [[SCGPUImageVertigoFilter alloc] init];
    [self setImageWithFilter:customFilter];
}

- (void)displayAction {
    if([self.currentEffectFilter isKindOfClass:[SCGPUImageBaseFilter class]]){
        SCGPUImageBaseFilter *filter = (SCGPUImageBaseFilter *)self.currentEffectFilter;
        filter.time = self.displayLink.timestamp - filter.beginTime;
        [self.imagePic processImage];
    }
}

- (void)endDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}
- (void)setImageWithFilter:(GPUImageFilter*)customFilter{
    self.imagePic = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"picOne.jpg"]];
    [self.imagePic addTarget:customFilter];
    [customFilter addTarget:self.gpuImageView];
    [self.imagePic processImage];
    self.currentEffectFilter = customFilter;
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
