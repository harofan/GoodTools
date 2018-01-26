//
//  FYQRCodeView.m
//  CreditCat
//
//  Created by 范杨 on 2018/1/24.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYQRCodeView.h"
#import "SGQRCode.h"

@interface FYQRCodeView()
@property (strong, nonatomic) UIViewController *currentVC;

/**
 背景view,解决动画完成后view点击无法返回的问题
 */
@property (strong, nonatomic) UIView *bgView;

@end
@implementation FYQRCodeView

#pragma mark - public
- (instancetype)initWithqrCodeStr:(NSString *)qrCodeStr frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *qrCodeImageView = [UIImageView new];
        [self addSubview:qrCodeImageView];
        [qrCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        qrCodeImageView.image = [SGQRCodeGenerateManager generateWithDefaultQRCodeData:qrCodeStr imageViewWidth:frame.size.width]; 
    }
    return self;
}

- (void)startScale{
    UIViewController *currentVC = [self p_getCurrentController];
    self.currentVC = currentVC;
    [currentVC.view addSubview:self.bgView];
    [self.bgView insertSubview:self belowSubview:self.bgView];
    [self p_viewScaleAnimationWithNeedScale:YES scaleView:self];
}

- (void)finishScale{
    [self p_viewScaleAnimationWithNeedScale:NO scaleView:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bgView removeFromSuperview];
        [self.currentVC.view addSubview:self];
        self.bgView = nil;
        self.currentVC = nil;
    });
}

#pragma mark - private
- (UIViewController *)p_getCurrentController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)p_viewScaleAnimationWithNeedScale:(BOOL)isNeedScale scaleView:(UIView *)scaleView{
    
    if (isNeedScale && self.fyQRCodeViewDelegate && [self.fyQRCodeViewDelegate respondsToSelector:@selector(qrCodeViewStartScaleWithView:)]) {
        [self.fyQRCodeViewDelegate qrCodeViewStartScaleWithView:self];
    }
    
    if (!isNeedScale && self.fyQRCodeViewDelegate && [self.fyQRCodeViewDelegate respondsToSelector:@selector(qrCodeViewFinishScaleWithView:)]) {
        [self.fyQRCodeViewDelegate qrCodeViewFinishScaleWithView:self];
    }
    
    CGPoint oldCenterPoint = scaleView.center;
    CGPoint newCenterPoint = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    
    
    //缩放
    CABasicAnimation* rotationAnimation2= [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    rotationAnimation2.fromValue = [NSNumber numberWithFloat:isNeedScale? 1.0:2.5];
    rotationAnimation2.toValue = [NSNumber numberWithFloat:isNeedScale? 2.5:1.0];
    
    //中心位移
    CABasicAnimation *rotationAnimation3 =
    [CABasicAnimation animationWithKeyPath:@"position"];
    rotationAnimation3.fromValue = [NSValue valueWithCGPoint:isNeedScale?oldCenterPoint:newCenterPoint ];
    rotationAnimation3.toValue = [NSValue valueWithCGPoint: isNeedScale?newCenterPoint:oldCenterPoint ]; // 終点
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    // 动画选项设定
    group.duration = 0.3;
    group.repeatCount = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations = [NSArray arrayWithObjects:rotationAnimation2,rotationAnimation3,nil];
    [scaleView.layer addAnimation:group forKey:@"move-rotate-layer"];
}

#pragma mark - set && get
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _bgView.backgroundColor = [UIColor whiteColor];
        @weakify(self);
        [_bgView addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            @strongify(self);
            [self finishScale];
        }];
    }
    return _bgView;
}
@end
