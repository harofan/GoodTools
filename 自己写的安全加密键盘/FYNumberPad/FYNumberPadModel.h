//
//  FYNumberPadModel.h
//  CreditCat
//
//  Created by 范杨 on 2018/2/2.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYNumberPadModel : NSObject
@property (assign, nonatomic, readonly) NSInteger keybordNumber;
@property (copy, nonatomic, readonly) NSString *secretNumberStr;
- (instancetype)initWithKeybordNumber:(NSInteger)keybordNumber;
@end
