//
//  FYFilterModel.m
//  CreditCat
//
//  Created by 范杨 on 2018/1/26.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYFilterModel.h"

@implementation FYFilterModel
- (instancetype)initWithShowLabelStr:(NSString *)showLabelStr answerValue:(NSString *)answerValue isSelected:(BOOL)isSelected{
    if (self = [super init]) {
        self.showLabelStr = showLabelStr;
        self.answerValue = answerValue;
        self.isSelected = isSelected;
    }
    return self;
}
@end
