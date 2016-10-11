//
//  QHQLoadingView.m
//  LoadingAnimation
//
//  Created by PC-1269 on 16/10/10.
//  Copyright © 2016年 qihaiquan. All rights reserved.
//

#import "QHQLoadingView.h"

#define kLineColor_loading 
#define kLineCircleBackgroundColor  [UIColor colorWithRed:1 green:1 blue:1 alpha:0.53].CGColor

#define kLineWidth 1.5f
#define kAnimationType @"kAnimationType"
#define kHeadAnimation @"kHeadAnimation"
#define kFootAnimation @"kFootAnimation"
#define kSuccessAnimation @"kSuccessAnimation"
#define kFailAnimation @"kFailAnimation"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define kSelfWeak __weak typeof(self) weakSelf = self

@interface  QHQLoadingView()<CAAnimationDelegate>
{

    float _delayTime; // 延迟时间
    float _headTime;  // 伸展动画时间
    float _footTime;  // 收缩动画时间
    float _successTime; // 画勾动画时间
    float _failTime;    // 画×动画时间
    float _headStartAngle; // 伸展开始弧度
    float _headEndAngle;   // 伸展结束弧度
    float _maxAngle;       // 最大弧度
    float _minAngle;       // 最小弧度
    CGPoint _arcCenter;    // 圆圈中心点
    float _radius;         // 半径
    float _stop;           // 是否停止伸展收缩
    float _isSuccess;      // YES 成功 NO 失败
    float _isLoading;      // 是否正在进行动画
}

@property (nonatomic, strong) CAShapeLayer * backLayer; // 淡色圆圈

@property (nonatomic, strong) CAShapeLayer * headLayer; // 伸展Layer

@property (nonatomic, strong) CAShapeLayer * footLayer; // 收缩Layer

@property (nonatomic, strong) CAShapeLayer * successLayer; // 成功Layer

@property (nonatomic, strong) CAShapeLayer * failedLayer; // 失败Layer

@property (nonatomic, copy) void (^currentSuccessBlock)();

@property (nonatomic, copy) void (^currentFailedBlock)();


@end

@implementation QHQLoadingView

#pragma mark -控制接口
- (void)loading {
    if (_isLoading) {
        return;
    }
    _stop = NO;
    _isLoading = YES;
    [self prepareAnimation];
    [self drawBackgroundCircle];
    [self drawHeadCircle];
    [self headAnimation:_headLayer];
}

- (void)loadSuccessCompleted:(void (^)())block {

    _stop = YES;
    _isSuccess = YES;
    _currentSuccessBlock = block;
}

- (void)loadFailedCompleted:(void (^)())block {
    
    _stop = YES;
    _isSuccess = NO;
    _currentFailedBlock = block;
}

#pragma mark -CAAnimationDelegate methods

- (void)animationDidStart:(CAAnimation *)anim {


}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

    NSString * type = [anim valueForKey:kAnimationType];
    
    if ([type isEqualToString:kHeadAnimation]) {
        
        if (_stop) {
            // 停止伸展收缩
            _backLayer.strokeColor = [UIColor whiteColor].CGColor;
            
            // 根据结果画勾话×
            if (_isSuccess) {
                [self drawSuccessLayer];
            }else {
                [self drawFailLayer];
            }
            return;
        }
        
        // 结束弧度变开始
        _headStartAngle = _headEndAngle;
        
        // 再次获取结束弧度
        _headEndAngle = 2 * M_PI - [self getHeadRadians];
        
        // 重置延迟时间
        _delayTime = arc4random_uniform(3) / 10.;
        
        // 伸展变收缩
        _footLayer = _headLayer;
        [self footAnimation:_footLayer];
        
        kSelfWeak;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 增加新的伸展
            [weakSelf drawHeadCircle];
            [weakSelf headAnimation:_headLayer];
            
        });
        
    }else if ([type isEqualToString:kFootAnimation]){
        // 收缩后置nil
        _footLayer.hidden = YES;
        _footLayer = nil;
        
    }else if ([type isEqualToString:kSuccessAnimation] || [type isEqualToString:kFailAnimation]){
        // 画完勾×后的回调
        kSelfWeak;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_isSuccess){
                weakSelf.currentSuccessBlock();
                weakSelf.currentSuccessBlock = nil;}
            else{
                weakSelf.currentFailedBlock();
                weakSelf.currentFailedBlock = nil;}
            [weakSelf hideAllLayer];
            _isLoading = NO;
        });
    }
    
}



#pragma mark -动画

- (void)prepareAnimation {

    _delayTime = 0.1f;
    _headTime = 0.5f;
    _footTime = 0.3f;
    _successTime = 0.5f;
    _failTime = 0.5f;
    _maxAngle = 270.f;
    _minAngle = 90.f;
    _headStartAngle = 0.f;
    _headEndAngle = [self getHeadRadians];
    _arcCenter = CGPointMake(self.bounds.size.width / 2., self.bounds.size.height / 2.);
    _radius = self.bounds.size.width / 2.;
    
}

- (void)drawBackgroundCircle{

    UIBezierPath * path = [UIBezierPath bezierPath];
    
    [path addArcWithCenter:_arcCenter radius:_radius - kLineWidth / 2. startAngle:0 endAngle:DEGREES_TO_RADIANS(360) clockwise:YES];
    
    CAShapeLayer * backLayer = [CAShapeLayer layer];
    backLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    backLayer.lineWidth = kLineWidth;
    backLayer.fillColor = [UIColor clearColor].CGColor;
    backLayer.strokeColor = kLineCircleBackgroundColor;
    backLayer.path = path.CGPath;
    
    [self.layer addSublayer:backLayer];
    self.backLayer = backLayer;
    
}

- (void)drawHeadCircle{

    UIBezierPath * path = [UIBezierPath bezierPath];
    
    [path addArcWithCenter:_arcCenter radius:_radius - kLineWidth / 2. startAngle:_headStartAngle endAngle:_headEndAngle clockwise:YES];
    
    CAShapeLayer * backLayer = [CAShapeLayer layer];
    backLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    backLayer.lineWidth = kLineWidth;
    backLayer.lineCap = kCALineCapRound;
    backLayer.fillColor = [UIColor clearColor].CGColor;
    backLayer.strokeColor = [UIColor whiteColor].CGColor;
    backLayer.path = path.CGPath;
    [self.layer addSublayer:backLayer];
    self.headLayer = backLayer;
    
}

- (void)drawSuccessLayer {

    UIBezierPath * path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake( 1. / 6. * self.bounds.size.width + kLineWidth, self.bounds.size.height / 2)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width * 3. / 8., self.bounds.size.height * 7. / 8. - kLineWidth)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width * 0.75 - kLineWidth, self.bounds.size.height * 0.35 - kLineWidth)];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = kLineWidth;
    layer.lineCap = kCALineCapRound;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.layer addSublayer:layer];
    self.successLayer = layer;
    
    [self layerAnimation:layer duration:_successTime key:kSuccessAnimation];
    
}

- (void)drawFailLayer {

    UIBezierPath * path = [UIBezierPath bezierPath];
    
    float fixWidth = 0.3;
    
    [path moveToPoint:CGPointMake(self.bounds.size.width * fixWidth, self.bounds.size.height * fixWidth)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width * (1 - fixWidth), self.bounds.size.height * (1 - fixWidth))];
    
    [path moveToPoint:CGPointMake(self.bounds.size.width * (1 - fixWidth), self.bounds.size.height * fixWidth)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width * fixWidth, self.bounds.size.height * (1 - fixWidth))];
    
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = kLineWidth;
    layer.lineCap = kCALineCapRound;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self.layer addSublayer:layer];

    [self layerAnimation:layer duration:_failTime key:kFailAnimation];
    _failedLayer = layer;
}

- (float)getHeadRadians{

    float angle = arc4random_uniform(_maxAngle);
    
    if (angle < _minAngle) {
        angle = _minAngle + angle;
    }
    return DEGREES_TO_RADIANS(angle);
    
}

- (void)hideAllLayer{

    if (_backLayer) {
        _backLayer.hidden = YES;
        _backLayer = nil;
        
    }
    if (_successLayer) {
        _successLayer.hidden = YES;
        _successLayer = nil;
        
    }if (_failedLayer) {
        _failedLayer.hidden = YES;
        _failedLayer = nil;
        
    }if (_headLayer) {
        _headLayer.hidden = YES;
        _headLayer = nil;
        
    }if (_footLayer) {
        _footLayer.hidden = YES;
        _footLayer = nil;
        
    }
    

    
}

#pragma mark -Animation

- (void)headAnimation:(CALayer *)layer {

    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = _headTime;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setValue:kHeadAnimation forKey:kAnimationType];
    [layer addAnimation:animation forKey:kHeadAnimation];
    
}

- (void)footAnimation:(CALayer *)layer {

    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    animation.duration = _footTime;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.delegate = self;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [animation setValue:kFootAnimation forKey:kAnimationType];
    [layer addAnimation:animation forKey:kFootAnimation];
}

- (void)layerAnimation:(CALayer *)layer duration:(float)duration key:(NSString *)key{
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.delegate = self;
    animation.duration = duration;
    animation.fromValue = @0;
    animation.toValue = @1;
    [animation setValue:key forKey:kAnimationType];
    [layer addAnimation:animation forKey:key];
    
}
@end
