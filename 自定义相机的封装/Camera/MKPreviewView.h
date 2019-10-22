//
//  PreviewView.h
//  摄像机画面的捕捉和预览
//
//  Created by 柯木超 on 2019/9/3.
//  Copyright © 2019 柯木超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol MKPreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;//聚焦
@end
// 相机画面捕捉预览的类
@interface MKPreviewView : UIView
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<MKPreviewViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
