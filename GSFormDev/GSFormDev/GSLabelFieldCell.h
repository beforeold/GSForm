//
//  GSLabelFieldCell.h
//  GS3PL
//
//  Created by Brook on 2017/4/22.
//  Copyright © 2017年 Brook. All rights reserved.

#import <UIKit/UIKit.h>

@interface GSLabelFieldCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftlabel;
@property (nonatomic, strong) UITextField *rightField;

@property (nonatomic, copy) void(^textChangeBlock)(NSString *text);

@end
