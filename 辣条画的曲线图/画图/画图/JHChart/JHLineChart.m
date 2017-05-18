//
//  JHLineChart.m
//  JHChartDemo
//
//  Created by cjatech-简豪 on 16/4/10.
//  Copyright © 2016年 JH. All rights reserved.
//

#import "JHLineChart.h"
#define kXandYSpaceForSuperView 20.0

@interface JHLineChart ()

@property (assign, nonatomic)   CGFloat  xLength;
@property (assign , nonatomic)  CGFloat  yLength;
@property (assign , nonatomic)  CGFloat  perXLen ;
@property (assign , nonatomic)  CGFloat  perYlen ;
@property (assign , nonatomic)  CGFloat  perValue ;
@property (nonatomic,strong)    NSMutableArray * drawDataArr;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (assign , nonatomic) BOOL  isEndAnimation ;
@property (nonatomic,strong) NSMutableArray * layerArr;

@property(nonatomic,strong)UIBezierPath *firstPath;

@property(nonatomic,strong)UIBezierPath *secondPath;


@end

@implementation JHLineChart



/**
 *  重写初始化方法
 *
 *  @param frame         frame
 *  @param lineChartType 折线图类型
 *
 *  @return 自定义折线图
 */
-(instancetype)initWithFrame:(CGRect)frame andLineChartType:(JHLineChartType)lineChartType{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _lineType = lineChartType;
        _lineWidth = 0.5;
        
       
        _yLineDataArr  = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
        _xLineDataArr  = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7"];

        _pointNumberColorArr = @[[UIColor redColor]];
        _positionLineColorArr = @[[UIColor darkGrayColor]];
        _pointColorArr = @[[UIColor orangeColor]];
        _xAndYNumberColor = [UIColor darkGrayColor];
        _valueLineColorArr = @[[UIColor redColor]];
        _layerArr = [NSMutableArray array];
        _showYLine = YES;
        //_showYLevelLine = NO;
        _showYLevelLine = YES;
        _showValueLeadingLine = YES;
        _valueFontSize = 8.0;
        
        [self configChartXAndYLength];
        [self configChartOrigin];
        [self configPerXAndPerY];
}
    return self;
    
}

/**
 *  清除图标内容
 */
-(void)clear{
    
    _valueArr = nil;
    _drawDataArr = nil;
    
    for (CALayer *layer in _layerArr) {
        
        [layer removeFromSuperlayer];
    }
    [self showAnimation];
    
}

/**
 *  获取每个X或y轴刻度间距
 */
- (void)configPerXAndPerY{
    
   
    switch (_lineChartQuadrantType) {
        case JHLineChartQuadrantTypeFirstQuardrant:
        {
            _perXLen = (_xLength-kXandYSpaceForSuperView)/(_xLineDataArr.count-1);//49.14....
            _perYlen = (_yLength-kXandYSpaceForSuperView)/_yLineDataArr.count; //22.85...
        }
            break;
        default:
            break;
    }
    
}


/**
 *  重写LineChartQuardrantType的setter方法 动态改变折线图原点
 *
 */
-(void)setLineChartQuadrantType:(JHLineChartQuadrantType)lineChartQuadrantType{
    
    _lineChartQuadrantType = lineChartQuadrantType;
    [self configChartOrigin];
    
}



/**
 *  获取X与Y轴的长度
 */
- (void)configChartXAndYLength{
    
    //7plus的情况下x是 414  这个_xLength = 364 (前后间距分别是 10 10 )
    _xLength = CGRectGetWidth(self.frame)-self.contentInsets.left-self.contentInsets.right;
    
    //7plus的情况下 _yLength = 180   (左右边距都是 10 )
    _yLength = CGRectGetHeight(self.frame)-self.contentInsets.top-self.contentInsets.bottom;
}


/**
 *  重写ValueArr的setter方法 赋值时改变Y轴刻度大小
 *
 */
-(void)setValueArr:(NSArray *)valueArr{
    
    _valueArr = valueArr;
    
    [self updateYScale];
    
    
}


/**
 *  更新Y轴的刻度大小
 */
- (void)updateYScale{
        switch (_lineChartQuadrantType) {
        
        default:{
            if (_valueArr.count) {
                
                NSInteger max=0;
                
                for (NSArray *arr in _valueArr) {
                    for (NSString * numer  in arr) {
                        NSInteger i = [numer integerValue];
                        if (i>=max) {
                            max = i;
                        }
                        
                    }
                    
                }

                //mark---改的...
                if (max%1==0) {
                    max = max;
                }else
                    max = (max/1+1)*1;
                _yLineDataArr = nil;
                NSMutableArray *arr = [NSMutableArray array];
                if (max<=4) {
                    for (NSInteger i = 0; i<max+1; i++) {
                        
                        [arr addObject:[NSString stringWithFormat:@"%ld",(i+1)*1]];
                        
                    }
                }
                
                if (max<=8&&max>4) {
                    
                    
                    for (NSInteger i = 0; i<max/2+1; i++) {
                        
                        [arr addObject:[NSString stringWithFormat:@"%ld",(i+1)*2]];
                        
                    }
                    
                }else if(max>8&&max<=16){
                    
                    for (NSInteger i = 0; i<max/4+1; i++) {
                        [arr addObject:[NSString stringWithFormat:@"%ld",(i+1)*4]];
                        
                        
                    }
                    
                }else if(max<=100){
                    
                    for (NSInteger i = 0; i<max/10; i++) {
                        [arr addObject:[NSString stringWithFormat:@"%ld",(i+1)*10]];
                        
                        
                    }
                    
                }else if(max > 100){
                    
                    NSInteger count = max / 10;
                    
                    for (NSInteger i = 0; i<10+1; i++) {
                        [arr addObject:[NSString stringWithFormat:@"%ld",(i+1)*count]];
                        
                    }
                }

                
                _yLineDataArr = [arr copy];
                
                [self setNeedsDisplay];
                
                
            }

        }
            break;
    }
    
    
    
}


/**
 *  构建折线图原点
 */
- (void)configChartOrigin{
    
    switch (_lineChartQuadrantType) {
        case JHLineChartQuadrantTypeFirstQuardrant:
        {
            self.chartOrigin = CGPointMake(self.contentInsets.left, self.frame.size.height-self.contentInsets.bottom);
        }
            break;
        default:
            break;
    }
    
}




/* 绘制x与y轴 */
- (void)drawXAndYLineWithContext:(CGContextRef)context{

    switch (_lineChartQuadrantType) {
        case JHLineChartQuadrantTypeFirstQuardrant:{
            
            [self drawLineWithContext:context andStarPoint:self.chartOrigin andEndPoint:P_M(self.contentInsets.left+_xLength, self.chartOrigin.y) andIsDottedLine:NO andColor:self.xAndYLineColor];
            if (_showYLine) {
                  [self drawLineWithContext:context andStarPoint:self.chartOrigin andEndPoint:P_M(self.chartOrigin.x,self.chartOrigin.y-_yLength) andIsDottedLine:NO andColor:self.xAndYLineColor];
            }
          
            if (_xLineDataArr.count>0) {
                CGFloat xPace = (_xLength-kXandYSpaceForSuperView)/(_xLineDataArr.count-1);
                
                for (NSInteger i = 0; i<_xLineDataArr.count;i++ ) {
                    //mark---改的.... 如果X的数据为空,不画点
                    if ([_xLineDataArr[i] isKindOfClass:[NSString class]]) {
                        if (![_xLineDataArr[i] isEqualToString:@""]){
                            CGPoint p = P_M(i*xPace+self.chartOrigin.x, self.chartOrigin.y);
                            CGFloat len = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:self.xDescTextFontSize aimString:_xLineDataArr[i]].width;
                            [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x, p.y-3) andIsDottedLine:NO andColor:self.xAndYLineColor];
                            
                            [self drawText:[NSString stringWithFormat:@"%@",_xLineDataArr[i]] andContext:context atPoint:P_M(p.x-len/2, p.y+2) WithColor:_xAndYNumberColor andFontSize:self.xDescTextFontSize];
                            
                            //mark---改的.... 绘制竖线
                            [self drawXLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x, 10) andIsDottedLine:NO andColor:self.xAndYLineColor];
                        }
                    }else if([_xLineDataArr[i] isKindOfClass:[NSNumber class]]){
                        if ([_xLineDataArr[i] floatValue]!=0){
                            CGPoint p = P_M(i*xPace+self.chartOrigin.x, self.chartOrigin.y);
                            CGFloat len = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:self.xDescTextFontSize aimString:_xLineDataArr[i]].width;
                            [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x, p.y-3) andIsDottedLine:NO andColor:self.xAndYLineColor];
                            
                            [self drawText:[NSString stringWithFormat:@"%@",_xLineDataArr[i]] andContext:context atPoint:P_M(p.x-len/2, p.y+2) WithColor:_xAndYNumberColor andFontSize:self.xDescTextFontSize];
                            
                            //mark---改的...... 绘制竖线
                            [self drawXLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x, 10) andIsDottedLine:NO andColor:self.xAndYLineColor];
                        }
                    }
                    
                }
              
                
                
            }
            
            if (_yLineDataArr.count>0) {
                CGFloat yPace = (_yLength - kXandYSpaceForSuperView)/(_yLineDataArr.count);
                for (NSInteger i = 0; i<_yLineDataArr.count; i++) {
                    CGPoint p = P_M(self.chartOrigin.x, self.chartOrigin.y - (i+1)*yPace);
                    
                    CGFloat len = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:self.yDescTextFontSize aimString:_yLineDataArr[i]].width;
                    CGFloat hei = [self sizeOfStringWithMaxSize:CGSizeMake(CGFLOAT_MAX, 30) textFont:self.yDescTextFontSize aimString:_yLineDataArr[i]].height;
                    if (_showYLevelLine) {
                        // mark---改的.....   原文是虚线 andIsDottedLine:YES
                         [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(self.contentInsets.left+_xLength, p.y) andIsDottedLine:NO andColor:self.xAndYLineColor];
                        
                        
                    }else{
                        [self drawLineWithContext:context andStarPoint:p andEndPoint:P_M(p.x+3, p.y) andIsDottedLine:NO andColor:self.xAndYLineColor];
                    }
                    [self drawText:[NSString stringWithFormat:@"%@",_yLineDataArr[i]] andContext:context atPoint:P_M(p.x-len-3, p.y-hei / 2) WithColor:_xAndYNumberColor andFontSize:self.yDescTextFontSize];
                }
            }
            
        }break;
    

        default:
            break;
    }
    

}

/**
 *  动画展示路径
 */
-(void)showAnimation{
    [self configPerXAndPerY];
    [self configValueDataArray];
    [self drawAnimation];
}


- (void)drawRect:(CGRect)rect {
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawXAndYLineWithContext:context];
    
    
    if (!_isEndAnimation) {
        return;
    }
    
    if (_drawDataArr.count) {
        [self drawPositionLineWithContext:context];
    }
    
}



/**
 *  装换值数组为点数组
 */
- (void)configValueDataArray{
    _drawDataArr = [NSMutableArray array];
    
    if (_valueArr.count==0) {
        return;
    }
    
    switch (_lineChartQuadrantType) {
        case JHLineChartQuadrantTypeFirstQuardrant:{
            _perValue = _perYlen/[[_yLineDataArr firstObject] floatValue];
            
            for (NSArray *valueArr in _valueArr) {
                NSMutableArray *dataMArr = [NSMutableArray array];
                for (NSInteger i = 0; i<valueArr.count; i++) {
                    
                    CGPoint p = P_M(i*_perXLen+self.chartOrigin.x,self.contentInsets.top + _yLength - [valueArr[i] floatValue]*_perValue);
                    NSValue *value = [NSValue valueWithCGPoint:p];
                    [dataMArr addObject:value];
                }
                [_drawDataArr addObject:[dataMArr copy]];
                
            }

            
        }break;
            default:
            break;
    }
}

//------------------------蒋双寿--------------------------
//执行动画
- (void)drawAnimation{
    
    [_shapeLayer removeFromSuperlayer];
    _shapeLayer = [CAShapeLayer layer];
    if (_drawDataArr.count==0) {
        return;
    }
    
   
    
    //第一、UIBezierPath绘制线段
    [self configPerXAndPerY];
 
    
    for (NSInteger i = 0;i<_drawDataArr.count;i++) {
        
        _firstPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)];
        
        _secondPath = [UIBezierPath bezierPath];

//        if (_drawDataArr[i]) {
//            _firstPath.lineWidth = 1;
//        }else{
//            _firstPath.lineWidth = 5;
//        }
//        if (_drawDataArr[i]) {
//            if (i == 0) {
//              _firstPath.lineWidth = 2.0;
//            }else{
//                _firstPath.lineWidth = 5.0;
//            }
//        }
        NSArray *dataArr = _drawDataArr[i];
        
        [self drawPathWithDataArr:dataArr andIndex:i];
        
    }
    

    
}




- (void)drawPathWithDataArr:(NSArray *)dataArr andIndex:(NSInteger )colorIndex{
    
//    UIBezierPath *firstPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 0, 0)];
//    
//    UIBezierPath *secondPath = [UIBezierPath bezierPath];
    
    for (NSInteger i = 0; i<dataArr.count; i++) {
        
        NSValue *value = dataArr[i];
        
        CGPoint p = value.CGPointValue;
        
        if (_pathCurve) {
            if (i==0) {
                
                if (_contentFill) {

                    [_secondPath moveToPoint:P_M(p.x, self.chartOrigin.y)];
                    [_secondPath addLineToPoint:p];
                }

                [_firstPath moveToPoint:p];
            }else{
                CGPoint nextP = [dataArr[i-1] CGPointValue];
                CGPoint control1 = P_M(p.x + (nextP.x - p.x) / 2.0, nextP.y );
                CGPoint control2 = P_M(p.x + (nextP.x - p.x) / 2.0, p.y);
                 [_secondPath addCurveToPoint:p controlPoint1:control1 controlPoint2:control2];
                [_firstPath addCurveToPoint:p controlPoint1:control1 controlPoint2:control2];
            }
        }else{
            
              if (i==0) {
                  if (_contentFill) {
                      [_secondPath moveToPoint:P_M(p.x, self.chartOrigin.y)];
                      [_secondPath addLineToPoint:p];
                  }
                  [_firstPath moveToPoint:p];
//                   [secondPath moveToPoint:p];
              }else{
                   [_firstPath addLineToPoint:p];
                   [_secondPath addLineToPoint:p];
            }

        }

        if (i==dataArr.count-1) {
            
            [_secondPath addLineToPoint:P_M(p.x, self.chartOrigin.y)];
            
        }
    }
    
    
    
    if (_contentFill) {
        [_secondPath closePath];
    }
    
    //第二、UIBezierPath和CAShapeLayer关联
    
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = self.bounds;
    shapeLayer.path = _firstPath.CGPath;
    UIColor *color = (_valueLineColorArr.count==_drawDataArr.count?(_valueLineColorArr[colorIndex]):([UIColor orangeColor]));
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
//    if (_drawDataArr[0]) {
//         shapeLayer.lineWidth = (_animationPathWidth<=0?2:_animationPathWidth);
//        }else{
//             shapeLayer.lineWidth = (_animationPathWidth<=0?8:_animationPathWidth);
//        }
    

    shapeLayer.lineWidth = (_animationPathWidth<=0?2:_animationPathWidth);
    
    //mark---改的..... 去除动画
    //第三，动画
    
//    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
//    
//    ani.fromValue = @0;
//    
//    ani.toValue = @1;
//    
//    ani.duration = 2.0;
//    
//    ani.delegate = self;
//    
//    [shapeLayer addAnimation:ani forKey:NSStringFromSelector(@selector(strokeEnd))];
    
    
    [self.layer addSublayer:shapeLayer];
    [_layerArr addObject:shapeLayer];
    
    weakSelf(weakSelf)
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ani.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        CAShapeLayer *shaperLay = [CAShapeLayer layer];
        shaperLay.frame = weakself.bounds;
        shaperLay.path = _secondPath.CGPath;
        if (weakself.contentFillColorArr.count == weakself.drawDataArr.count) {
            
            shaperLay.fillColor = [weakself.contentFillColorArr[colorIndex] CGColor];
        }else{
            shaperLay.fillColor = [UIColor clearColor].CGColor;
        }
        
        [weakself.layer addSublayer:shaperLay];
        [_layerArr addObject:shaperLay];
        
//    });
    
    
}



/**
 *  设置点的引导虚线
 *
 *  @param context 图形面板上下文
 */
- (void)drawPositionLineWithContext:(CGContextRef)context{
    
    
    
    if (_drawDataArr.count==0) {
        return;
    }
    
    
    
    for (NSInteger m = 0;m<_valueArr.count;m++) {
        NSArray *arr = _drawDataArr[m];
        
        for (NSInteger i = 0 ;i<arr.count;i++ ) {
            
            CGPoint p = [arr[i] CGPointValue];
            UIColor *positionLineColor;
            if (_positionLineColorArr.count == _valueArr.count) {
                positionLineColor = _positionLineColorArr[m];
            }else
                positionLineColor = [UIColor orangeColor];

            
            if (_showValueLeadingLine) {
                [self drawLineWithContext:context andStarPoint:P_M(self.chartOrigin.x, p.y) andEndPoint:p andIsDottedLine:YES andColor:positionLineColor];
                [self drawLineWithContext:context andStarPoint:P_M(p.x, self.chartOrigin.y) andEndPoint:p andIsDottedLine:YES andColor:positionLineColor];
            }
          
            
            if (p.y!=0) {
                UIColor *pointNumberColor = (_pointNumberColorArr.count == _valueArr.count?(_pointNumberColorArr[m]):([UIColor orangeColor]));
                
                switch (_lineChartQuadrantType) {
                       
                        
                    case JHLineChartQuadrantTypeFirstQuardrant:
                    {
                        NSString *aimStr = [NSString stringWithFormat:@"(%@,%@)",_xLineDataArr[i],_valueArr[m][i]];
                        CGSize size = [self sizeOfStringWithMaxSize:CGSizeMake(100, 25) textFont:self.valueFontSize aimString:aimStr];
                        CGFloat length = size.width;
                        
                        [self drawText:aimStr andContext:context atPoint:P_M(p.x - length / 2, p.y - size.height / 2 -10) WithColor:pointNumberColor andFontSize:self.valueFontSize];
                    }
                        break;
                        
                    default:
                        break;
                }
                
            }
            
            
        }
    }
    
     _isEndAnimation = NO;
    
    
}


@end
