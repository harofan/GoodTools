//
//  FYFilerView.m
//  CreditCat
//
//  Created by 范杨 on 2018/1/26.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYFilerView.h"
#import "FYFilterTableViewCell.h"
#import "FYFilterModel.h"
@interface FYFilerView()<UITableViewDelegate, UITableViewDataSource>

/**
 上触摸容器
 */
@property (strong, nonatomic) UIView *topTapBGView;

/**
 下触摸容器
 */
@property (strong, nonatomic) UIView *bottomTapView;

/**
 下拉菜单
 */
@property (strong, nonatomic) UITableView *menuTableView;

/**
 标题label数组
 */
@property (copy, nonatomic) NSMutableArray *menuTitleLabelArray;
@end
@implementation FYFilerView{
    NSInteger _currentSelectIndex;//当前选中的弹窗下标
}

- (instancetype)initWithDataArray:(NSArray<NSArray<FYFilterModel *> *> *)dataArray showStrArray:(NSArray<NSString *> *)showStrArray answerStrArray:(NSArray<FYFilterModel *> *)answerStrArray{
    if (self = [super init]) {
        self.dataArray = dataArray;
        self.showStrArray = showStrArray;
        self.answerStrArray = answerStrArray;
        [self initButtonView];
    }
    return self;
}

#pragma mark - UI
- (void)initButtonView{
    if (self.dataArray.count != self.showStrArray.count) {
        NSLog(@"传入信息有误,请核对后重新上传");
        return;
    }
    
    //配置信息
    const NSInteger itemCount = self.showStrArray.count;
    const CGFloat itemBGViewWidth = ScreenWidth/itemCount;
    const CGFloat labelFont = 16;
    UIColor *labelColor = [UIColor blackColor];
    
    
    for (int i = 0; i < itemCount; i ++) {
        
        //容器
        UIView *bgView = [UIView new];
        bgView.backgroundColor = [UIColor greenColor];
        [self addSubview:bgView];
        CGFloat itemX = i * itemBGViewWidth;
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(itemX));
            make.top.bottom.equalTo(@0);
            make.width.equalTo(@(itemBGViewWidth));
        }];
        
        //文字
        UILabel *showLabel = [UILabel new];
        showLabel.text = self.showStrArray[i];
        showLabel.font = [UIFont systemFontOfSize:labelFont];
        showLabel.textColor = labelColor;
        [bgView addSubview:showLabel];
        [showLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerX.equalTo(bgView.mas_centerX);
           make.centerY.equalTo(bgView.mas_centerY);
        }];
        [self.menuTitleLabelArray addObject:showLabel];
        
        //触发按钮
        UIButton *button = [UIButton new];
        [bgView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
           make.edges.equalTo(@0);
        }];
        button.tag = i;
        [button addTarget:self action:@selector(didClickFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)showSelectTableViewWithIndex:(NSInteger)index{
    
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    
    //上部分遮罩
    [rootWindow addSubview:self.topTapBGView];
    //iphoneX是➕84
    CGFloat topBGVeiwBottom = self.frame.origin.y + self.frame.size.height + 64;
    CGFloat bgViewWidth = self.frame.size.width;
    self.topTapBGView.frame = CGRectMake(0, 0, bgViewWidth, topBGVeiwBottom);
    CGFloat viewHeight = 44 *self.dataArray[_currentSelectIndex].count;

    //下部分遮罩
    [rootWindow addSubview:self.bottomTapView];
    self.bottomTapView.frame = CGRectMake(0, topBGVeiwBottom, bgViewWidth, ScreenHeight - topBGVeiwBottom);
    
    //展示
    self.menuTableView.frame = CGRectMake(0, 0 - viewHeight, bgViewWidth, viewHeight);
    [self.menuTableView reloadData];
    [self.bottomTapView addSubview:self.menuTableView];
    [UIView animateWithDuration:0.3f animations:^{
        self.menuTableView.frame = CGRectMake(0, 0, bgViewWidth, viewHeight);
    } completion:nil];
}

- (void)hideSelectTableView{
    
    if (self.topTapBGView) {
        [self.topTapBGView removeFromSuperview];
        self.topTapBGView = nil;
    }
    
    if (self.bottomTapView) {
        [self.bottomTapView removeFromSuperview];
        self.bottomTapView = nil;
    }
}
#pragma mark - private
/**
 选择筛选答案
 */
- (void)p_selectFilterMenu:(NSInteger)selectIndex{
    
    [self hideSelectTableView];
    FYFilterModel *selectModel = self.dataArray[_currentSelectIndex][selectIndex];
    UILabel *selectMenuLabel = self.menuTitleLabelArray[_currentSelectIndex];
    selectMenuLabel.text = selectModel.showLabelStr;
    
    //更改传出数据源
    FYFilterModel *answerModel = self.answerStrArray[_currentSelectIndex];
    answerModel.showLabelStr = selectModel.showLabelStr;
    answerModel.answerValue = selectModel.answerValue;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(fyFilterView:selectIndex:selectArray:)]) {
        [self.delegate fyFilterView:self selectIndex:_currentSelectIndex selectArray:self.answerStrArray];
    }
}

#pragma mark - target action
- (void)didClickFilterButton:(UIButton *)filterButton{
    NSLog(@"点击了%ld",filterButton.tag);
    //记录弹窗坐标
    _currentSelectIndex = filterButton.tag;
    [self showSelectTableViewWithIndex:filterButton.tag];
}

#pragma mark - delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}
#pragma mark - datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray[_currentSelectIndex].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FYFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FYFilterTableViewCell" forIndexPath:indexPath];
    FYFilterModel *cellModel = self.dataArray[_currentSelectIndex][indexPath.row];
    @weakify(self);
    [cell addTapActionWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
        @strongify(self);
        [self p_selectFilterMenu:indexPath.row];
    }];
    cell.cellModel = cellModel;
    return cell;
}

#pragma mark - set && get

- (UITableView *)menuTableView{
    if (!_menuTableView) {
        _menuTableView = [UITableView new];
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        [_menuTableView registerNib:[UINib nibWithNibName:@"FYFilterTableViewCell" bundle:nil] forCellReuseIdentifier:@"FYFilterTableViewCell"];
    }
    return _menuTableView;
}
- (UIView *)topTapBGView{
    if (!_topTapBGView) {
        _topTapBGView = [UIView new];
        _topTapBGView.backgroundColor = [UIColor clearColor];
        //创建手势
        UITapGestureRecognizer *tap1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelectTableView)];
        tap1Gesture.numberOfTapsRequired = 1;
        tap1Gesture.numberOfTouchesRequired = 1;
        [_topTapBGView addGestureRecognizer:tap1Gesture];
    }
    return _topTapBGView;
}
- (UIView *)bottomTapView{
    if (!_bottomTapView) {
        _bottomTapView = [UIView new];
        _bottomTapView.backgroundColor = [UIColor blackColor];
        _bottomTapView.alpha = 0.6f;
        //创建手势
        UITapGestureRecognizer *tap1Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelectTableView)];
        tap1Gesture.numberOfTapsRequired = 1;
        tap1Gesture.numberOfTouchesRequired = 1;
        [_bottomTapView addGestureRecognizer:tap1Gesture];
        _bottomTapView.clipsToBounds = YES;
    }
    return _bottomTapView;
}

- (NSMutableArray *)menuTitleLabelArray{
    if (!_menuTitleLabelArray) {
        _menuTitleLabelArray = [NSMutableArray array];
    }
    return _menuTitleLabelArray;
}
@end

