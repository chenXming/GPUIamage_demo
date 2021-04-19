//
//  ViewController.m
//  LearnOpenGLESWithGPUImage
//
//  Created by chenxiaoming on 21/4/13.
//  Copyright © 2021年 chenxiaoming. All rights reserved.
//

#import "ViewController.h"
#import <GPUImageView.h>
#import <GPUImage/GPUImageSepiaFilter.h>
#import "GUPImagePictureViewController.h"
#import "GPUImageCameraUIViewController.h"
#import "GPUImageFliterGroupViewController.h"
#import "GPUImageMovieWriterViewController.h"
#import "DissolveBlendFilterViewController.h"
#import "UIElementViewController.h"
#import "CustomFilterViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UIImageView    *mImageView;
@property (nonatomic , strong) UITableView    *mTableView;
@property (nonatomic , strong) NSMutableArray *mDataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    [_mDataArr addObjectsFromArray:@[@"图片添加滤镜",@"Crame采集视频添加滤镜",@"GPUImageMovieWriter 使用",@"混合滤镜",@"视频添加水印",@"多滤镜组合",@"自定义滤镜"]];

    _mTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.backgroundColor = [UIColor whiteColor];
    UIView *footView = [[UIView alloc] init];
    _mTableView.tableFooterView = footView;
    [self.view addSubview:self.mTableView];
    [self.mTableView reloadData];
}

#pragma mark - TableView Delegate&DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _mDataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *indenifer = @"Cell_Indentifer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indenifer];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indenifer];
    }
    cell.textLabel.text = _mDataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            GUPImagePictureViewController *picVc = [[GUPImagePictureViewController alloc] init];
            [self.navigationController pushViewController:picVc animated:YES];
        }
            break;
        case 1:
        {
            GPUImageCameraUIViewController *cameraVc = [[GPUImageCameraUIViewController alloc] init];
            [self.navigationController pushViewController:cameraVc animated:YES];
        }
            break;
        case 2:
        {
            GPUImageMovieWriterViewController *cameraVc = [[GPUImageMovieWriterViewController alloc] init];
            [self.navigationController pushViewController:cameraVc animated:YES];
        }
            break;
        case 3:
        {
            DissolveBlendFilterViewController *cameraVc = [[DissolveBlendFilterViewController alloc] init];
            [self.navigationController pushViewController:cameraVc animated:YES];
        }
            break;
        case 4:
        {
            UIElementViewController *cameraVc = [[UIElementViewController alloc] init];
            [self.navigationController pushViewController:cameraVc animated:YES];
        }
            break;
        case 5:
        {
            GPUImageFliterGroupViewController *fliterGroupVc = [[GPUImageFliterGroupViewController alloc] init];
            [self.navigationController pushViewController:fliterGroupVc animated:YES];
        }
            break;
        case 6:
        {
            CustomFilterViewController *fliterVc = [[CustomFilterViewController alloc] init];
            [self.navigationController pushViewController:fliterVc animated:YES];
        }
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
