//
//  FYFilterTableViewCell.m
//  CreditCat
//
//  Created by 范杨 on 2018/1/26.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "FYFilterTableViewCell.h"
#import "FYFilterModel.h"

@interface FYFilterTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;

@end
@implementation FYFilterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setCellModel:(FYFilterModel *)cellModel{
    _cellModel = cellModel;
    _menuTitleLabel.text = cellModel.showLabelStr;
    _menuTitleLabel.textColor = cellModel.isSelected ? [UIColor colorWithHexString:@"3FA9C4"] : [UIColor colorWithHexString:@"333333"];
}

@end
