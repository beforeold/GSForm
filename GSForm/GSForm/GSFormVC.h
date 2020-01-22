//
//  GSFormVC.h
//
//  Created by Brook on 2017/4/24.
//  Copyright © 2017年 Brook. All rights reserved.
//  表单控制器的基类

#import <UIKit/UIKit.h>
#import "GSForm.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSFormVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) GSForm *form;

@end

NS_ASSUME_NONNULL_END
