//
//  QHQLoadingView.h
//  LoadingAnimation
//
//  Created by PC-1269 on 16/10/10.
//  Copyright © 2016年 qihaiquan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QHQLoadingView : UIView

/**
 正在加载
 */
- (void)loading;

/**
 加载成功
 */
- (void)loadSuccessCompleted:(void (^)())block;

/**
 加载失败
 */
- (void)loadFailedCompleted:(void (^)())block;

@end
