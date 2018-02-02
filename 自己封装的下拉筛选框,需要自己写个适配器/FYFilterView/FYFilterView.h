//
//  FYFilerView.h
//  CreditCat
//
//  Created by 范杨 on 2018/1/26.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYFilterModel;
@class FYFilterView;
@protocol FYFilterViewDelegate <NSObject>
@optional
- (void)fyFilterView:(FYFilterView *)filterView selectIndex:(NSInteger)selectIndex selectArray:(NSArray<FYFilterModel *> *)selectArray;
@end
@interface FYFilterView : UIView

/**
 弹窗的数据源
 */
@property (copy, nonatomic) NSArray<NSArray <FYFilterModel *>*> *dataArray;

/**
 默认展示
 */
@property (copy, nonatomic) NSArray<NSString *> *showStrArray;

/**
 默认答案
 */
@property (copy, nonatomic) NSArray<FYFilterModel *> *answerStrArray;
@property (weak, nonatomic) id<FYFilterViewDelegate> delegate;

- (instancetype)initWithDataArray:(NSArray<NSArray <FYFilterModel *>*> *)dataArray showStrArray:(NSArray<NSString *> *)showStrArray answerStrArray:(NSArray<FYFilterModel *> *)answerStrArray;
@end
