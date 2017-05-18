//
//  JSSCircleView.h
//  CircleView(自定义圆环)
//
//  Created by jss on 17/5/16.
//  Copyright © 2017年 jss. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface JSSCircleView : UIView

//线宽
@property(nonatomic,assign)CGFloat lineWidth;

//初始化的时候值
@property(nonatomic,assign)CGFloat rawValue;

//初始值的比较
@property(nonatomic,assign)CGFloat raValue1;

//圆弧半径
@property(nonatomic,assign)CGFloat radius;

//中心点坐标
@property(nonatomic,assign)CGPoint point;


@property(nonatomic)CAShapeLayer * shapelayer;

@property(nonatomic)UIBezierPath * apath;

@property(nonatomic)CABasicAnimation *animation;

@property (nonatomic)float toValue;//好信分比例
//圆环view
//@property(nonatomic,strong)JSSDrawRectCircleView *drawView;

//外界赋值设置JSSDrawRectCircleView显示的位置
@property(nonatomic,assign)CGFloat progress;

//开始动画
-(void)startAnimation;
@end
