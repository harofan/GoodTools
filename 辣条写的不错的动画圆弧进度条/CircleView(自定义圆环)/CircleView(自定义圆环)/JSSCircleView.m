//
//  JSSCircleView.m
//  CircleView(自定义圆环)
//
//  Created by jss on 17/5/16.
//  Copyright © 2017年 jss. All rights reserved.
//

#import "JSSCircleView.h"
#import "UIColor+Hex.h"

@implementation JSSCircleView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    //初始化界面
    [self setupUI];
    
    return self;
}

-(void)setupUI{
    
    _lineWidth = 10;
}

-(void)drawRect:(CGRect)rect{
    
    [self drawCircleView:rect];
}

-(void)drawCircleView:(CGRect)rect{
    
    _radius = (rect.size.height>rect.size.width?rect.size.width/2:rect.size.height/2) - _lineWidth/2;
    
    _point = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    //背景圆圈
    [self addBackgroundCircle];
    
    //最上层显示的圆弧
    [self addMainCircleView];
}

//添加背景圆弧
-(void)addBackgroundCircle{
    
    CAShapeLayer *backgrounLayer = [CAShapeLayer layer];
    
    backgrounLayer.lineJoin = kCALineJoinRound;
    
    backgrounLayer.lineCap = kCALineCapRound;
    
    backgrounLayer.frame = CGRectMake(0, 0, 0, 0);
    
    UIBezierPath *pathT = [UIBezierPath bezierPath];
    
    [pathT addArcWithCenter:_point radius:_radius-2 startAngle:M_PI*2.95/4 endAngle:M_PI*1.05/4 clockwise:YES];
    
    backgrounLayer.path = pathT.CGPath;
    
    backgrounLayer.fillColor = [UIColor clearColor].CGColor;
    
    backgrounLayer.lineWidth = _lineWidth;
    
    backgrounLayer.strokeColor = [UIColor colorWithHex:0x0270af].CGColor;
    
    [self.layer addSublayer:backgrounLayer];

}

 //最上层显示的圆弧
-(void)addMainCircleView{
    
    _apath = [UIBezierPath bezierPath];
    
    [_apath addArcWithCenter:_point radius:_radius-2 startAngle:M_PI*2.95/4 endAngle:M_PI*1.05/4 clockwise:YES];
    
    _shapelayer = [[CAShapeLayer alloc] init];
    
    _shapelayer.strokeColor = [UIColor whiteColor].CGColor;
    
    _shapelayer.fillColor = [UIColor clearColor].CGColor;
    
    _shapelayer.lineWidth = _lineWidth;
    
    _shapelayer.lineJoin = kCALineJoinRound;
    
    _shapelayer.lineCap = kCALineCapRound;
    
    _shapelayer.path = _apath.CGPath;
    
    if(_rawValue>_raValue1){
        
        _raValue1 = 0.001+_rawValue>0.999?1:0.001+_rawValue;
        
    }else {
        
        _raValue1 = 0.001+_rawValue<0?0.001:0.001+_rawValue;
    }
    
    _shapelayer.strokeEnd = _raValue1;
    
    [self.layer addSublayer:_shapelayer];
}

#pragma mark 懒加载
-(void)setLineWidth:(CGFloat)lineWidth{
    
    _lineWidth = lineWidth>10 ? 10 : lineWidth;
    
    [self setNeedsDisplay];
}


-(void)setRawValue:(CGFloat)rawValue{
    
    _rawValue = rawValue;
    
    [self setNeedsDisplay];
}


-(void)setProgress:(CGFloat)progress{
    
    _progress = progress;
    
    _toValue = progress;
    
    [self setNeedsDisplay];
}


//开始动画
-(void)startAnimation{
    
    CABasicAnimation * ani = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    
    ani.fromValue = @0.0;
    
    ani.toValue = [NSNumber numberWithFloat:self.toValue];
    
    ani.duration = 1.5;
    
    ani.fillMode=kCAFillModeForwards;
    
    ani.removedOnCompletion=NO;
    
    [_shapelayer addAnimation:ani forKey:nil];

}

@end
