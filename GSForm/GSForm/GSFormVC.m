//
//  GSFormVC.m
//
//  Created by Brook on 2017/4/24.
//  Copyright © 2017年 Brook. All rights reserved.
//

// controllers
#import "GSFormVC.h"

// views


@interface UITableViewCell (AddLine)

/**
 *  给UITableViewCell添加上划线下划线   在UITableViewDelegate的代理方法 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 调用
 *
 *  @param isTop     是否显示上划线
 *  @param isBottom  是否显示下划线
 */
- (void)gs_updateCellLine:(BOOL)isTop isBottom:(BOOL)isBottom;

- (void)gs_updateEnable:(NSIndexPath *)indexPath target:(id)target action:(SEL)action enable:(BOOL)enable;

@end

@interface GSFormVC ()

@end

@implementation GSFormVC

#pragma mark - lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self normalSetup];
    [self configureSubview];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - event response
/// 处理当 row 不可用时的点击响应
- (void)disableClick:(UIButton *)button {
    UITableViewCell *cell = (UITableViewCell *)[button superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    /// 当自身进行不可用判断时优先返回
    if (row.disableValidateBlock) {
        NSNumber *number = row.disableValidateBlock(row.value, NO)[kValidateRetKey];
        BOOL enable = number.boolValue;
        if (!enable) {
            row.disableValidateBlock(row.value, YES);
            return;
        }
    }

    // 如果全局判断为 disable
    if (self.form.disableBlock) {
        self.form.disableBlock(self.form);
    }
}

#pragma mark - protocol
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier];
    if (!cell) {
        if (row.cellClass) {
            cell = [[row.cellClass alloc] initWithStyle:row.style reuseIdentifier:row.reuseIdentifier];
        } else {
            cell = [[[NSBundle mainBundle] loadNibNamed:row.nibName owner:nil options:nil] lastObject];
        }
        
        !row.cellExtraInitBlock ?: row.cellExtraInitBlock(cell, row.value, indexPath);
    }
    
    NSAssert(!(row.rowConfigBlockWithCompletion && row.rowConfigBlock), @"row config block 二选一");
    
    GSRowConfigCompletion completion = nil;
    if (row.rowConfigBlock) {
        row.rowConfigBlock(cell, row.value, indexPath);
        
    } else if (row.rowConfigBlockWithCompletion) {
        completion = row.rowConfigBlockWithCompletion(cell, row.value, indexPath);
    }
    
    [self handleEnableForCell:cell gsRow:row atIndexPath:indexPath];
    
    !completion ?: completion();
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
        willDisplayCell:(UITableViewCell *)cell
        forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    [cell gs_updateCellLine:row.hasTopSep isBottom:row.hasBottomSep];
}

- (CGFloat)tableView:(UITableView *)tableView
        heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    return row.rowHeight == 0 ? UITableViewAutomaticDimension : row.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return [self.form[section] headerHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self.form[section] footerHeight];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    for (GSSection *section in self.form.sectionArray) {
        if(!section.isHidden) count++;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GSSection *fSection = self.form[section];
    NSInteger count = 0;
    for (GSRow *row in fSection.rowArray) {
        if(!row.isHidden) count++;
    }
    
    return count;
}

- (void)tableView:(UITableView *)tableView
         didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    !row.didSelectBlock ?: row.didSelectBlock(indexPath, row.value);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    !row.didSelectCellBlock ?: row.didSelectCellBlock(indexPath, row.value, cell);
}

#pragma mark - private methods
// 初始化控制器的一些初始参数、状态等
- (void)normalSetup
{
    self.view.backgroundColor = [UIColor whiteColor];
}

// 配置视图
- (void)configureSubview
{
    [self.view addSubview:self.tableView];
}

- (void)handleEnableForCell:(UITableViewCell *)cell gsRow:(GSRow *)row atIndexPath:(NSIndexPath *)indexPath {
    BOOL enable = YES;
    
    if (self.form.disableBlock) {  // 如果全局禁用
        enable = NO;
        if (row.enableValidateBlock) {
            NSNumber *number = row.enableValidateBlock(row.value, NO)[kValidateRetKey];
            enable = number.boolValue;
        }
    } else if (row.disableValidateBlock) {
        NSNumber *number = row.disableValidateBlock(row.value, NO)[kValidateRetKey];
        enable = number.boolValue;
    }
    
    [cell gs_updateEnable:indexPath target:self action:@selector(disableClick:) enable:enable];
}

#pragma mark - getters/setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 88.f;
    }
    
    return _tableView;
}

- (GSForm *)form {
    if (!_form) {
        _form = [[GSForm alloc] init];
    }
    
    return _form;
}

@end

@implementation UITableViewCell (GSAddLine)

#define kTopLineViewTag 200001
#define kBottomLineViewTag 200002

/// 考虑到2x/3x屏幕的像素值设置
#define kScreenScale					[[UIScreen mainScreen] scale]
#define PIXEL_INTEGRAL(pointValue) (round(pointValue * kScreenScale) / kScreenScale)
#define kSeparatorLineWidth PIXEL_INTEGRAL(1)

- (void)gs_updateCellLine:(BOOL)isTop isBottom:(BOOL)isBottom {
    UILabel *topLine = [self viewWithTag:kTopLineViewTag];
    UILabel *bottomLine = [self viewWithTag:kBottomLineViewTag];
    
    if (!topLine) {
        UIColor *color = [UIColor colorWithRed:0.929412 green:0.929412 blue:0.929412 alpha:1];
        topLine = [[UILabel alloc] init];
        topLine.backgroundColor = color;
        topLine.tag = kTopLineViewTag;
    }
    [self.contentView addSubview:topLine];
    
    if (!bottomLine) {
        UIColor *color = [UIColor colorWithRed:0.929412 green:0.929412 blue:0.929412 alpha:1];
        bottomLine = [[UILabel alloc] init];
        bottomLine.backgroundColor = color;
        bottomLine.tag = kBottomLineViewTag;
    }
    [self.contentView addSubview:bottomLine];
    
    CGFloat offset = 13;
    topLine.frame = CGRectMake(0, 0, self.frame.size.width, kSeparatorLineWidth);
    bottomLine.frame = CGRectMake(offset, self.frame.size.height - kSeparatorLineWidth, self.frame.size.width - offset, kSeparatorLineWidth);
    topLine.hidden = !isTop;
    bottomLine.hidden = !isBottom;
}

- (void)gs_updateEnable:(NSIndexPath *)indexPath target:(id)target action:(SEL)action enable:(BOOL)enable {
    NSInteger tag = 7876434;
    UIButton *button = [self viewWithTag:tag];
    if (!button) {
        button = [[UIButton alloc] initWithFrame:self.bounds];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        button.tag = tag;
        [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    button.userInteractionEnabled = !enable;
}

@end
