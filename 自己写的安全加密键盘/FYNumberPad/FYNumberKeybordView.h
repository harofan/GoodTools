//
//  FYNumberKeybordView.h
//  CreditCat
//
//  Created by 范杨 on 2018/2/2.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FYNumberPadType){
    //普通键盘
    normalNumberPadType = 0,
    //随机乱序键盘
    randomNumberPadType,
};

@class FYNumberKeybordView;
@protocol FYNumberKeybordViewDelegate <NSObject>
@required
- (void)fyNumberKeybordView:(FYNumberKeybordView *)numberKeybordView clickNumberStr:(NSString *)clickNumberStr;
- (void)clickDeleteButtonWithFYNumberKeybordView:(FYNumberKeybordView *)numberKeybordView;
@end
@interface FYNumberKeybordView : UIView
@property (weak, nonatomic) id<FYNumberKeybordViewDelegate>fyNumberKeybordDelegate;
- (instancetype)initWithNumberPadType:(FYNumberPadType)numberPadType;
@end
