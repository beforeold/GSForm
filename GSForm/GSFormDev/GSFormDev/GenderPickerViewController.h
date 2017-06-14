//
//  GenderPickerViewController.h
//  GSFormDev
//
//  Created by Brook on 2017/6/15.
//  Copyright © 2017年 Brook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenderPickerViewController : UIViewController

@property (nonatomic, copy) void(^pickBlock)(BOOL isMale);

@end
