//
//  ViewController.m
//  画图
//
//  Created by tacker on 2017/4/27.
//  Copyright © 2017年 Xundong. All rights reserved.
//

#import "ViewController.h"
#import "JHChartHeader.h"
#define k_MainBoundsWidth [UIScreen mainScreen].bounds.size.width
#define k_MainBoundsHeight [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) JHLineChart *lineChart;  //线条1


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    
    imageView.image = [UIImage imageNamed:@"bg"];
    
    [self.view addSubview:imageView];
    
    [self showFirstQuardrant];
    
}

- (void)showFirstQuardrant{
    
    //创建表对象
    JHLineChart *lineChart = [[JHLineChart alloc] initWithFrame:CGRectMake(10, 340, k_MainBoundsWidth-20, 200) andLineChartType:JHChartLineValueNotForEveryX];
    
//    lineChart.backgroundColor = [UIColor clearColor];
    self.lineChart = lineChart;
    // X轴的刻度值 可以传入NSString或NSNumber类型
    lineChart.xLineDataArr = @[@"",@"",@"",@"03/22",@"",@"",@"03/22",@"",@"03/29",@"",@"",@"04/18"];
    lineChart.contentInsets = UIEdgeInsetsMake(0, 25, 20, 10);

    //第一象限
    lineChart.lineChartQuadrantType = JHLineChartQuadrantTypeFirstQuardrant;
    
    //Y值
//    lineChart.valueArr = @[@[@"4",@"3",@"4",@"4.5",@"3",@"4",@"3.5",@"1.6",@"4",@"3.4",@"4",@"3.9"]];
    
    lineChart.valueArr = @[@[@"20",@"60",@"40",@"45",@"30",@"14",@"35",@"16",@"24",@"34",@"14",@"39"],@[@"19",@"59",@"39",@"44",@"29",@"13",@"34",@"15",@"23",@"33",@"13",@"38"]];
    
//    lineChart.valueArr = @[@[@"15",@"55",@"35",@"40",@"25",@"9",@"30",@"11",@"19",@"29",@"9",@"34"]];
    //显示横线
    lineChart.showYLevelLine = YES; //原来是 Yes
    
    //是否显示Y轴
    lineChart.showYLine = NO; //原来是 NO
    
    //功能未知(设置暂时没效果)
    lineChart.showValueLeadingLine = NO; //原来是NO
    
    //功能未知(修改暂时也没效果)
    lineChart.valueFontSize = 9.0;
    
    //设置线宽
     lineChart.animationPathWidth = 3;
    //背景色
   // lineChart.backgroundColor = [UIColor whiteColor];
    lineChart.backgroundColor = [UIColor clearColor];
    
    //线条颜色(加两条线调整透明度 达到阴影效果)
   // lineChart.valueLineColorArr =@[[UIColor redColor],[[UIColor redColor]colorWithAlphaComponent:0.3]];
    
    lineChart.valueLineColorArr =@[[UIColor whiteColor],[[UIColor blackColor]colorWithAlphaComponent:0.18]];
    //功能未知
    lineChart.pointColorArr = @[[UIColor orangeColor]];
    
    //蒋双寿
    //XY轴颜色(XY轴的线条颜色)
//    lineChart.xAndYLineColor = [UIColor blackColor]; //原先是 blackColor
    lineChart.xAndYLineColor = [UIColor clearColor];
    /* XY axis scale color */
//    lineChart.xAndYNumberColor = [UIColor darkGrayColor];
    
    //设置 线条X轴和Y轴的的文字颜色
    lineChart.xAndYNumberColor = [UIColor darkGrayColor];
    /* Dotted line color of the coordinate point */
    lineChart.positionLineColorArr = @[[UIColor blueColor]];
    /*        Set whether to fill the content, the default is False         */
    //未知功能(暂时设置没效果)
    lineChart.contentFill = YES; //原先是YES
    
    //是否曲线
    lineChart.pathCurve = YES;//原先是YES
    /*        Set fill color array         */
//    lineChart.contentFillColorArr = @[[UIColor colorWithRed:0 green:1 blue:0 alpha:0.468]];
    [self.view addSubview:lineChart];
    /*       Start animation        */
    [lineChart showAnimation];
    
}

@end
