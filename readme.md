类似支付宝支付动画效果 美团外卖 其中有动态旋转 伸展动画 收缩动画 打钩 画× 动画
所有效果集成在QHQLoadingView中
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
