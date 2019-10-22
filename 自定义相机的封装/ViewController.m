//
//  ViewController.m
//  自定义相机的封装
//
//  Created by 柯木超 on 2019/10/22.
//  Copyright © 2019 柯木超. All rights reserved.
//

#import "ViewController.h"
#import "UICameraController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *actionButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 -50, 100, 100, 50)];
    [actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [actionButton setTitle:@"打开相机" forState:UIControlStateNormal];
    [actionButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:actionButton];
}

-(void)cameraAction {
    UICameraController *cameraController = [[UICameraController alloc]init];
    [self presentViewController:cameraController animated:YES completion:nil];
}

@end
