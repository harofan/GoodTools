//
//  ViewController.m
//  CircleView(自定义圆环)
//
//  Created by jss on 17/5/16.
//  Copyright © 2017年 jss. All rights reserved.
//

#import "ViewController.h"
#import "JSSCircleView.h"
#import "Masonry.h"
#import "UICountingLabel.h"
#import "UIColor+Hex.h"

@interface ViewController ()
//绘制的圆环的整个一块view
@property (nonatomic,strong) JSSCircleView *progressView;
//背景圆环图
@property (nonatomic,strong) UIImageView *boardImgView;
//分数
@property (nonatomic,strong) UICountingLabel *pointLab;
//评价等级
@property (nonatomic,strong) UILabel *judgeLab;

@property (nonatomic,assign) int point;

@property (nonatomic,strong) UIButton *checkBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self initCircleView];
    
    //为了防止运行速度过快 导致不能看到效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self startAnim];
    });
}

-(void)initCircleView{
    
    //设置view的背景颜色
    self.view.backgroundColor = [UIColor colorWithHex:0x0d87cd];
    
    //添加背景圆环图
    [self.view addSubview:self.boardImgView];
    
    //添加整个一块圆环view
    [self.view addSubview:self.progressView];
    
    //添加圆圈上班显示的大文字(self.point = 800 这里文字就是表示 800 )
    [self.progressView addSubview:self.pointLab];
    
    //添加数值下边的描述文字
    [self.progressView addSubview:self.judgeLab];
    
    //添加开始动画按钮
    [self.view addSubview:self.checkBtn];
    
    //设置圆环的数值
    self.point = 500;
    
    //计算设置圆环显示到的位置
    //    self.progressView.progress = (800.0-300)/(850-300.0);
    self.progressView.progress = (500.0 - 0)/(1000 - 0);
    
    //设置背景图的颜色(我这里设置了测试颜色 更加直观看出结构)
//    self.boardImgView.backgroundColor = [UIColor redColor];
    
    //把progressView 调整到父view的最上方
    [self.view bringSubviewToFront:self.progressView];
    
    //添加子控件约束
    [self constraintsForSubView];
}

#pragma mark 控件约束

-(void)constraintsForSubView{
    
    //背景圆环图约束(比内部的progressview各大了宽高30)
    [self.boardImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.mas_equalTo(self.progressView.mas_centerX);
        
        make.centerY.mas_equalTo(self.progressView.mas_centerY);
        
        make.width.mas_equalTo(330);
        
        make.height.mas_equalTo(330);

    }];
    
    //圆环view约束(圆环view比背景BoardImgView宽高各少了30)
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        //make.size.mas_equalTo(CGSizeMake(AUTO_3PX(980), AUTO_3PX(980)));
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        
        make.top.mas_equalTo(140);
        
        make.width.mas_equalTo(self.boardImgView).mas_offset(-30);
        
        make.height.mas_equalTo(self.boardImgView).mas_offset(-30);
    }];
    
    //圆圈上班显示的大文字约束
    [self.pointLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(self.progressView.mas_width).mas_offset(-30);
        
        make.height.mas_equalTo(60);
        
        make.centerX.equalTo(self.progressView.mas_centerX);
        
        make.centerY.equalTo(self.progressView.mas_centerY).mas_offset(-10);
    }];
    
    //描述文字约束
    [self.judgeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(self.progressView);
        
        make.top.mas_equalTo(self.pointLab.mas_bottom);
        
        make.left.mas_equalTo(self.progressView.mas_left);
    }];
    
    //开始动画按钮约束
    [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-178);
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        
        make.width.mas_equalTo(250);
        
        make.height.mas_equalTo(66);
    }];
}

#pragma mark 点击事件

//开始动画按钮
-(void)startAnim{
    
    self.pointLab.method = UILabelCountingMethodLinear;
    
    self.pointLab.format = @"%d";
    
    [self.pointLab countFrom:1 to:self.point withDuration:1.5];
    
    [self.progressView startAnimation];
}


#pragma mark - property懒加载

//开始按钮
-(UIButton *)checkBtn{
    
    if (_checkBtn == nil) {
        
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_checkBtn setBackgroundImage:[UIImage imageNamed:@"whiteBtn"] forState:UIControlStateNormal];
        
        [_checkBtn setTitle:@"开始动画" forState:UIControlStateNormal];
        
        [_checkBtn setTitleColor:[UIColor colorWithHex:0x0d87cd] forState:UIControlStateNormal];
        
        _checkBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        
        _checkBtn.backgroundColor = [UIColor clearColor];
        
        _checkBtn.titleEdgeInsets = UIEdgeInsetsMake(-18, 0, 0, 0);
        
        [_checkBtn addTarget:self action:@selector(startAnim) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _checkBtn;
}


//整个一块进度view(比背景progressview的宽高都要小30)
-(JSSCircleView*)progressView{
    
    if (_progressView  == nil) {
        
        _progressView = [[JSSCircleView alloc]init];
        
        _progressView.backgroundColor = [UIColor clearColor];
    }
    
    return _progressView;
}


//圆圈中间大的显示文字(800)
-(UICountingLabel *)pointLab{
    
    if (!_pointLab) {
        
        _pointLab = [[UICountingLabel alloc]init];
        
        _pointLab.textAlignment = NSTextAlignmentCenter;
        
        _pointLab.font = [UIFont systemFontOfSize:60];
        
        _pointLab.textColor = [UIColor whiteColor];
        
        //测试代码
        _pointLab.backgroundColor = [UIColor grayColor];
    }
    
    return _pointLab;
}

//描述文字
-(UILabel *)judgeLab{
    
    if (!_judgeLab) {
        
        _judgeLab = [[UILabel alloc]init];
        
        _judgeLab.textAlignment = NSTextAlignmentCenter;
        
        _judgeLab.font = [UIFont systemFontOfSize:16];
        
        _judgeLab.textColor = [UIColor whiteColor];
        
        _judgeLab.text = @"啦啦啦啦";
    }
    
    return _judgeLab;
}

//圆环背景图
-(UIImageView*)boardImgView{
    
    if (_boardImgView  == nil) {
        
        _boardImgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"board"]];
    }
    
    return _boardImgView;
}



@end
