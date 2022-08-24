//
//  StepperCell.h
//  GSFormDev
//
//  Created by Brook on 2017/6/15.
//  Copyright © 2017年 Brook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepperCell : UITableViewCell

@property (nonatomic, copy) void(^stepperBlock)(double newValue);

- (void)updateValue:(double)value;

@end
