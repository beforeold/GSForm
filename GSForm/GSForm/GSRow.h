//
//  GSRowItem.h
//  GS3PL
//
//  Created by Brook on 2017/4/22.
//  Copyright © 2017年 Brook. All rights reserved.
//  描述 row 的数据源

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *kGSHTTPPropertyKey;
extern NSString *kGSHTTPValueKey;

extern NSString *kValidateRetKey;
extern NSString *kValidateMsgKey;


typedef void(^GSRowConfigCompletion)();

///
static inline NSDictionary *rowError(NSString *msg) {
    return @{kValidateMsgKey: msg ?: @"",
             kValidateRetKey:@NO};
}

static inline NSDictionary *rowOK() {
    return @{kValidateRetKey:@YES};
}

@class GSSection;
@interface GSRow : NSObject

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, assign, readonly) UITableViewCellStyle style;
@property (nonatomic, copy, readonly) NSString *reuseIdentifier;
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, copy) NSString *nibName;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, strong) id value;
@property (nonatomic, copy) NSString *noValueDisplayText;
@property (nonatomic, assign) BOOL hasTopSep;
@property (nonatomic, assign) BOOL hasBottomSep;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

/*
 * 下面两个二选一
 */

@property (nullable, nonatomic, copy) void(^rowConfigBlock)(id cell, id value, NSIndexPath *indexPath); // cellForRow
@property (nullable, nonatomic, copy) GSRowConfigCompletion(^rowConfigBlockWithCompletion)(id cell, id value, NSIndexPath *indexPath); // final row config at cellForRow

@property (nullable, nonatomic, copy) void(^cellExtraInitBlock)(id cell, id value, NSIndexPath *indexPath); // if(!cell) { extraInitBlock };

/// check isValid
@property (nullable, nonatomic, copy) NSDictionary *(^valueValidateBlock)(id value);
@property (nullable, nonatomic, copy) void(^didSelectBlock)(NSIndexPath *indexPath, id value); // didSelectRow
@property (nullable, nonatomic, copy) void(^didSelectCellBlock)(NSIndexPath *indexPath, id value, id cell); // didSelectRow with Cell
@property (nullable, nonatomic, copy) void(^reformRespRetBlock)(id ret, id value);      // 外部传值处理
@property (nullable, nonatomic, copy) id(^httpParamConfigBlock)(id value); // get param for http request

/// 判断是否【启用】 row 的条件 block，如果返回YES，则 cell 激活，返回NO，则会被禁用
/// 配合 GSForm 的全局 disable 一起使用
/// didSelect 变量是 判断该block的调用是否为点击事件的调用
@property (nullable, nonatomic, copy) NSDictionary *(^enableValidateBlock)(id value, BOOL didClick);

/// 判断是否【禁用】 row 的条件block，如果返回YES，则 cell 激活，返回NO，则会被禁用
/// 当全局的 disable 存在时，此 block 不执行
/// didSelect 变量是 判断该block的调用是否为点击事件的调用
@property (nullable, nonatomic, copy) NSDictionary *(^disableValidateBlock)(id value, BOOL didClick);

/// 指向所在 section
@property (nullable, nonatomic, weak) GSSection *section;

@end

NS_ASSUME_NONNULL_END

/*
 *  因为控制器会持有row对象
 *  注意循环引用，在block内部调用 section 或者 控制器时使用弱引用
 *  由于在 cellConfigBlock 内有调用 cell 的回调 delegate 的可能，因此需要在 block 内部进行再一次的 weak 处理
 *  示例见下方
 */

/*
 
 WEAK_SELF
 row.cellConfigBlock = ^(GSTCodeScanCell *cell, id value) {
     STRONG_SELF
 
    __weak typeof(cell) weakCell = cell;
    __weak typeof(strongSelf) weakWeakSelf = strongSelf;
    cell.scanClickBlock = ^(){
        GSQRCodeController *scanVC = [[GSQRCodeController alloc] init];
            scanVC.returnScanBarCodeValue = ^(NSString *str) {
            value[kCellRightContent] = str;
            NSIndexPath *indexPath = [weakWeakSelf.tableView indexPathForCell:weakCell];
            [weakWeakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [weakWeakSelf.navigationController pushViewController:scanVC animated:YES];
    };
 };
 
 */

