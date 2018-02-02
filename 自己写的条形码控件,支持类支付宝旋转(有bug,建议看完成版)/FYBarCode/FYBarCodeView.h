//
//  FYBarCodeView.h
//  CreditCat
//
//  Created by 范杨 on 2018/1/24.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYBarCodeView;
@protocol FYBarCodeViewDelegate <NSObject>
@optional
/**
 开始旋转时调用
 */
- (void)barCodeViewStartRotationWithView:(FYBarCodeView *)barCodeView;

/**
 条形码回归原位时调用
 */
- (void)barCodeViewFinishRotationWithView:(FYBarCodeView *)barCodeView;
@end
@interface FYBarCodeView : UIView

@property (weak, nonatomic) id<FYBarCodeViewDelegate> fyBarCodeDelegate;
/**
 条形码不要缩放,是什么尺寸就是什么尺寸!
 */
- (instancetype)initWithBarCodeStr:(NSString *)barCodeStr frame:(CGRect)frame;

/**
 开始旋转
 */
- (void)startRotation;

/**
 停止旋转
 */
- (void)finishRotation;

@end
