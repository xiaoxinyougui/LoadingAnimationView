//
//  ViewController.m
//  LoadingAnimation
//
//  Created by PC-1269 on 16/10/10.
//  Copyright © 2016年 qihaiquan. All rights reserved.
//

#import "ViewController.h"
#import "QHQLoadingView.h"

@interface ViewController ()

@property (nonatomic, strong) QHQLoadingView * qhqView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    QHQLoadingView * view = [[QHQLoadingView alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor blackColor];
    _qhqView = view;
    
}

- (IBAction)loading:(id)sender {

    [_qhqView loading];

}

- (IBAction)success:(id)sender {
    [_qhqView loadSuccessCompleted:^{
        NSLog(@"加载成功");
    }];

}

- (IBAction)failed:(id)sender {

    [_qhqView loadFailedCompleted:^{
        
        NSLog(@"加载失败");

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
