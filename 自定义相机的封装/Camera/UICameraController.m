//
//  UIViewCameraController.m
//  自定义相机的封装
//
//  Created by 柯木超 on 2019/10/22.
//  Copyright © 2019 柯木超. All rights reserved.
//

#import "UICameraController.h"
#import "MKPreviewView.h"
#import "CameraController.h"

#define kBottomViewHeight 120

typedef enum : NSUInteger {
    CameraTypeVideo,
    CameraTypePhoto,
} CameraType;

@interface UICameraController ()<MKPreviewViewDelegate, CameraControllerDelegate>

@property (strong, nonatomic) MKPreviewView *previewView;
@property (strong, nonatomic) CameraController *cameraController;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIView *bottomBgView;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *photoButton;
@property (strong, nonatomic) UIImageView *layerImageView;
@property (strong, nonatomic) UIButton *actionButton;
@property (strong, nonatomic) UIButton *changeCameraButton;
@property (assign, nonatomic) CameraType cameraType;
@property (strong, nonatomic) UILabel *timeLabel;
/** 时间控制定时器 */
@property (nonatomic, strong) NSTimer *videoTimer;
@property (nonatomic, assign) int timeNumber;
@end

@implementation UICameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cameraController = [[CameraController alloc]init];
    self.cameraController.delegate = self;
    [self.cameraController setupSession];
    self.previewView = [[MKPreviewView alloc]initWithFrame:self.view.bounds];
    [self.previewView setSession:self.cameraController.captureSession];
    self.previewView.delegate = self;
    [self.view addSubview:self.previewView];
    self.cameraType = CameraTypeVideo;
    [self createUI];
}


- (NSTimer *)videoTimer {
    if (!_videoTimer) {
        _videoTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_videoTimer forMode:NSRunLoopCommonModes];
    }
    return _videoTimer;
}

-(void)createUI {
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - kBottomViewHeight, self.view.frame.size.width, kBottomViewHeight)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    self.bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kBottomViewHeight)];
    self.bottomBgView.alpha = 0.3;
    self.bottomBgView.backgroundColor = [UIColor blackColor];
    [self.bottomView addSubview:self.bottomBgView];
    [self.view addSubview:self.bottomView];
    
    self.videoButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 90, 0, 60, 35)];
    [self.videoButton setTitle:@"视频" forState:UIControlStateNormal];
    [self.videoButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.videoButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.videoButton addTarget:self action:@selector(videoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.videoButton];
    
    self.photoButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 + 30, 0, 60, 35)];
    [self.photoButton addTarget:self action:@selector(photoButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.photoButton setTitle:@"照片" forState:UIControlStateNormal];
    [self.photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.photoButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.bottomView addSubview:self.photoButton];

    self.layerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 35+10, 70, kBottomViewHeight - 35 - 10*2)];
    self.layerImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.bottomView addSubview:self.layerImageView];
    
    self.actionButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - (kBottomViewHeight - 35 - 10)/2, self.view.frame.size.height - kBottomViewHeight + 35 + 10, kBottomViewHeight - 35 - 10, kBottomViewHeight - 35 - 10)];
    [self.actionButton setImage:[UIImage imageNamed:@"shipinluzhi-3"] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actionButton];
    
    self.changeCameraButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 90, 40 + 10, kBottomViewHeight - 35 - 10, 35)];
    [self.changeCameraButton setImage:[UIImage imageNamed:@"qiehuanshexiangtou"] forState:UIControlStateNormal];
    [self.changeCameraButton addTarget:self action:@selector(changeDeviceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.changeCameraButton];
    
    self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, 50, 100, 20)];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.font = [UIFont boldSystemFontOfSize:13];
    [self.view addSubview:self.timeLabel];
}

-(void)changeDeviceAction {
    [self.cameraController changeCamera];
}

-(void)videoButtonAction {
    [self.videoButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomBgView.alpha = 0.3;
    // 录制视频
    [self.actionButton setImage:[UIImage imageNamed:@"shipinluzhi-3"] forState:UIControlStateNormal];
    self.timeLabel.hidden = NO;
    self.cameraType = CameraTypeVideo;
}

-(void)photoButtonAction {
    self.bottomBgView.alpha = 1;
    [self.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.photoButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    [self.actionButton setImage:[UIImage imageNamed:@"paizhao"] forState:UIControlStateNormal];
    self.timeLabel.hidden = YES;
    self.cameraType = CameraTypePhoto;
}

-(void)cameraAction {
    switch (self.cameraType) {
        case CameraTypeVideo:{
                // 录制视频
                if([self.cameraController isRecording]) {
                    [self.cameraController stopRecording];
                    [self.videoTimer invalidate];
                    self.videoTimer = nil;
                    self.timeLabel.text = @"00:00";
                    [self.actionButton setImage:[UIImage imageNamed:@"shipinluzhi-3"] forState:UIControlStateNormal];
                    [UIView animateWithDuration:1 animations:^{
                        self.bottomBgView.alpha = 0.3;
                        self.bottomView.alpha = 1;
                    }];
                }else {
                    
                    [self.actionButton setImage:[UIImage imageNamed:@"shipinluzhi-4"] forState:UIControlStateNormal];
                    [self.cameraController startRecording];
                    [self.videoTimer fire];
                    [UIView animateWithDuration:1 animations:^{
                        self.bottomView.alpha = 0;
                        self.bottomBgView.alpha = 0;
                    }];
                }
            }
            break;
        case CameraTypePhoto:
            [self.cameraController getPhoto];
            break;
    }
}

-(void)showTime {
    self.timeNumber = self.timeNumber + 1;
    self.timeLabel.text = [self getMMSSFromSS:[NSString stringWithFormat:@"%d",self.timeNumber]];
}

//传入 秒 得到 xx:xx:xx
-(NSString *)getMMSSFromSS:(NSString *)totalTime{
    NSInteger seconds = [totalTime integerValue];
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}
    
#pragma MKPreviewViewDelegate
// 聚焦
- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController tappedToFocusAtPoint:point];
}

#pragma CameraControllerDelegate
-(void)inputPhoto:(UIImage *)image {
    self.layerImageView.image = image;
}

@end
