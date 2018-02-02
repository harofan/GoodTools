//
//  FYFilterModel.h
//  CreditCat
//
//  Created by 范杨 on 2018/1/26.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYFilterModel : NSObject
/**
 view上的label展示
 */
@property (copy, nonatomic) NSString *showLabelStr;

/**
 view上展示的str对应要传给后台的东西
 */
@property (copy, nonatomic) NSString *answerValue;

/**
 是否选中
 */
@property (assign, nonatomic) BOOL isSelected;
/**
 初始化
 */
- (instancetype)initWithShowLabelStr:(NSString *)showLabelStr answerValue:(NSString *)answerValue isSelected:(BOOL)isSelected;
@end
