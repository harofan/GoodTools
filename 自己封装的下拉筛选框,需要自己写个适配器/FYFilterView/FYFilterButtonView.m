//
//  FYFilterButtonView.m
//  CreditCat
//
//  Created by 范杨 on 2018/2/1.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYFilterButtonView.h"
//普通图片
static NSString *const ARROWS_NORMAL_IMAGENAME = @"icon_wallet_filter_xl_n";
//下拉图片
static NSString *const ARROWS_SELECTED_IMAGENAME = @"icon_wallet_filter_xl_s";
@interface FYFilterButtonView()
@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowsImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@end
@implementation FYFilterButtonView

- (void)setMenuTitleStr:(NSString *)menuTitleStr{
    _menuTitleStr = menuTitleStr;
    _menuTitleLabel.text = menuTitleStr;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    _menuTitleLabel.textColor = isSelected ? [UIColor colorWithHexString:@"3FA9C4"] : [UIColor colorWithHexString:@"333333"];
    _arrowsImageView.image = isSelected ? [UIImage imageNamed:ARROWS_SELECTED_IMAGENAME] : [UIImage imageNamed:ARROWS_NORMAL_IMAGENAME];
    _bottomLineView.backgroundColor = isSelected ? [UIColor colorWithHexString:@"3FA9C4"] : [UIColor clearColor];
}
@end
