//
//  FYQRCodeView.h
//  CreditCat
//
//  Created by 范杨 on 2018/1/24.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYQRCodeView;
@protocol FYQRCodeViewDelegate <NSObject>
@optional
/**
 开始旋转时调用
 */
- (void)qrCodeViewStartScaleWithView:(FYQRCodeView *)qrCodeView;

/**
 条形码回归原位时调用
 */
- (void)qrCodeViewFinishScaleWithView:(FYQRCodeView *)qrCodeView;
@end
@interface FYQRCodeView : UIView

@property (weak, nonatomic) id<FYQRCodeViewDelegate> fyQRCodeViewDelegate;
/**
 二维码不要缩放,是什么尺寸就是什么尺寸!
 */
- (instancetype)initWithqrCodeStr:(NSString *)qrCodeStr frame:(CGRect)frame;

/**
 开始缩放
 */
- (void)startScale;

/**
 停止缩放,恢复初始
 */
- (void)finishScale;

@end
