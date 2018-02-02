//
//  FYNumberPadModel.m
//  CreditCat
//
//  Created by 范杨 on 2018/2/2.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYNumberPadModel.h"

@interface FYNumberPadModel()
@property (assign, nonatomic, readwrite) NSInteger keybordNumber;
@property (copy, nonatomic, readwrite) NSString *secretNumberStr;//加密规则需要制定
@end
@implementation FYNumberPadModel
- (instancetype)initWithKeybordNumber:(NSInteger)keybordNumber{
    if (self = [super init]) {
        self.keybordNumber = keybordNumber;
    }
    return self;
}
- (NSString *)secretNumberStr{
    return [NSString stringWithFormat:@"%ld",self.keybordNumber];
}
@end
